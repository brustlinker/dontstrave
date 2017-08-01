local FrostyBreather = Class(function(self, inst)
	self.inst = inst
    self.breath = nil

	self.inst:ListenForEvent("animover", function(inst, data)
		if self.inst.sg:HasStateTag("idle") then
			self:EmitOnce()
		end
	end)

	self.inst:StartUpdatingComponent(self)
end)

function FrostyBreather:OnUpdate(dt)
	if GetSeasonManager() then
		local temp = GetWorld().components.seasonmanager:GetCurrentTemperature()
		if not self.breath and temp < TUNING.FROSTY_BREATH then
			self:Enable()
		elseif self.breath and temp > TUNING.FROSTY_BREATH then
			self:Disable()
		end
	end
end

function FrostyBreather:Enable()
	if not self.breath then
		self.breath = SpawnPrefab( "frostbreath" )
		self.inst:AddChild(self.breath)
		self.breath.Transform:SetPosition(0.3, 1.15, 0)
	end
end

function FrostyBreather:Disable()
	if self.breath then
		self.inst:RemoveChild(self.breath)
		self.breath:Remove()
		self.breath = nil
	end
end

function FrostyBreather:EmitOnce()
	if self.breath and self.inst.AnimState:GetCurrentFacing() ~= FACING_UP then
		self.breath.Emit(self.breath)
	end
end


return FrostyBreather
