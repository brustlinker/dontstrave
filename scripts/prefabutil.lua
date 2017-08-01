function MakePlacer(name, bank, build, anim, onground, snap, metersnap, scale)
	
	local function fn(Sim)
		local inst = CreateEntity()
		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		inst.AnimState:SetBank(bank)
		inst.AnimState:SetBuild(build)
		inst.AnimState:PlayAnimation(anim, true)
        inst.AnimState:SetLightOverride(1)
		
		inst:AddComponent("placer")
		inst.persists = false
		inst.components.placer.snaptogrid = snap
		inst.components.placer.snap_to_meters = metersnap
		
		if scale then
			inst.Transform:SetScale(scale, scale, scale)
		end

		if onground then
			inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround )
		end
		
		return inst
	end
	
	return Prefab(name, fn)
end
