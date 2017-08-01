local ComplexProjectile = Class(function(self, inst)
	self.inst = inst

	self.velocity = Vector3(0,0,0)
	self.gravity = -9.81

	self.hoizontalSpeed = 4

	self.onlaunchfn = nil
	self.onhitfn = nil
	self.onmissfn = nil

end)

function ComplexProjectile:GetDebugString()
	return tostring(self.velocity)
end

function ComplexProjectile:SetOnLaunch(fn)
	self.onlaunchfn = fn
end

function ComplexProjectile:SetOnHit(fn)
	self.onhitfn = fn
end

function ComplexProjectile:GetVerticalVelocity(distance)
	return ((self.gravity * distance)/2)/self.hoizontalSpeed
end

function ComplexProjectile:Launch(targetPos)
	local pos = self.inst:GetPosition()

	--We assume that the pos.y - targetPos.y == 0.
	pos.y = 0
	targetPos.y = 0

	local toTarget = targetPos - pos
	local vertVel = self:GetVerticalVelocity(pos:Dist(targetPos))

	toTarget = toTarget:Normalize()
	self.velocity = toTarget * self.hoizontalSpeed
	self.velocity.y = -vertVel

	if self.onlaunchfn then
		self.onlaunchfn(self.inst)
	end

	self.inst:StartUpdatingComponent(self)
end

function ComplexProjectile:Hit()
	self.inst:StopUpdatingComponent(self)

	self.inst.Physics:SetMotorVel(0,0,0)
	self.inst.Physics:Stop()
	self.velocity = Vector3(0,0,0)

	if self.onhitfn then
		self.onhitfn(self.inst)
	end
end

function ComplexProjectile:OnUpdate(dt)
	self.inst.Physics:SetMotorVel(self.velocity.x, self.velocity.y, self.velocity.z)
	self.velocity.y = self.velocity.y + (self.gravity * dt)
	local pos = self.inst:GetPosition()
	if pos.y <= 0 and self.velocity.y < 0 then
		self:Hit()
	end
end

return ComplexProjectile