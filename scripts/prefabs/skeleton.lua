local assets = 
{
	Asset("ANIM", "anim/skeletons.zip"),
}

local animstates = {1, 3, 4, 5, 6} --not going to use the spear skeleton until anim to take spear is made

local function onsave(inst, data)
	data.anim = inst.animnum
end

local function onload(inst, data)
	if data then
		if data.anim then
			inst.animnum = data.anim
			inst.AnimState:PlayAnimation("idle"..inst.animnum)
		end
	end
end

local function fn()

	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()

	MakeObstaclePhysics(inst, 0.25)

	inst.animnum = animstates[math.random(#animstates)]
	anim:SetBank("skeleton")
	anim:SetBuild("skeletons")
	anim:PlayAnimation("idle"..inst.animnum)

	inst:AddComponent("inspectable")
	inst.components.inspectable:RecordViews()
	inst.OnLoad = onload
	inst.OnSave = onsave
	return inst
end

return Prefab("common/objects/skeleton", fn, assets) 
