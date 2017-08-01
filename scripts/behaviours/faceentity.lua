


FaceEntity = Class(BehaviourNode, function(self, inst, getfn, keepfn, timeout)
    BehaviourNode._ctor(self, "FaceEntity")
    self.inst = inst
    self.getfn = getfn
    self.keepfn = keepfn
    
    self.timeout = timeout
    self.starttime = nil
    
end)

function FaceEntity:HasLocomotor()
    return self.inst.components.locomotor ~= nil
end

function FaceEntity:Visit()

    if self.status == READY then
        self.target = self.getfn(self.inst)
        
        if self.target then
            self.status = RUNNING

            if self:HasLocomotor() then
                self.inst.components.locomotor:Stop()
            end

            self.starttime = GetTime()
        else
            self.status = FAILED
        end
        
    end

    if self.status == RUNNING then

        --uhhhh....
        if self.inst.sg:HasStateTag("idle") and self.inst.sg.currentstate.name ~= "alert" and self.inst.sg.sg.states.alert then
            self.inst.sg:GoToState("alert")
        end
        
        if self.timeout and self.starttime then
            local totaltime = GetTime() - self.starttime
            if totaltime > self.timeout then
                self.status = SUCCESS
                return
            end
        end
        
        if self.keepfn(self.inst, self.target) then
            if self.inst.sg:HasStateTag("canrotate") then
                self.inst:FacePoint(self.target.Transform:GetWorldPosition())
            end
            
        else
            self.status = FAILED
        end
        self:Sleep(.5)
    end
    
end

