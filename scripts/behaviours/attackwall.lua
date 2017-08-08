AttackWall = Class(BehaviourNode, function(self, inst)
    BehaviourNode._ctor(self, "AttackWall")
    self.inst = inst
end)

function AttackWall:__tostring()
    return string.format("target %s", tostring(self.target))
end

function AttackWall:Visit()

    if self.status == READY then
        --不可以的tag
        local notags = {"FX", "NOCLICK","INLIMBO"}

        --可以的tag
        local yestags = {"wall"}
        local radius = 1.5 + (self.inst.Physics and self.inst.Physics:GetRadius() or 0)
		self.target = FindEntity(self.inst, radius,
			function(guy)
				if  self.inst.components.combat:CanTarget(guy) then
					local angle = anglediff(self.inst.Transform:GetRotation(), self.inst:GetAngleToPoint(Vector3(guy.Transform:GetWorldPosition() )))
					return math.abs(angle) < 30
				end

			end, yestags, notags)

		if self.target then
			self.status = RUNNING
			self.inst.components.locomotor:Stop()
			self.done = false
		else
			self.status = FAILED
		end

    end

    if self.status == RUNNING then
        --local is_attacking = self.inst.sg:HasStateTag("attack")
        --如果目标存在
        if not self.target or not self.target:IsValid() or (self.target.components.health and self.target.components.health:IsDead())then
            self.status = FAILED
            self.inst.components.locomotor:Stop()
        else
            --攻击成功
			if self.inst.components.combat:TryAttack(self.target) then
				self.status = SUCCESS
			else
				self.status = FAILED
			end
			self:Sleep(1)
        end
    end
end
