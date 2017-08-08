Panic = Class(BehaviourNode, function(self, inst)
    BehaviourNode._ctor(self, "Panic")
    self.inst = inst
    self.waittime = 0
end)

function Panic:Visit()
    if self.status == READY then
        self:PickNewDirection()
        self.status = RUNNING
    else
        if GetTime() > self.waittime then
            self:PickNewDirection()
        end
        self:Sleep(self.waittime - GetTime())
    end
end

--选择一个新方向奔跑
function Panic:PickNewDirection()
    self.inst.components.locomotor:RunInDirection(math.random()*360)
    --设置下一次更新方向时间
    self.waittime = GetTime() + 0.25 + math.random()*0.25
end
