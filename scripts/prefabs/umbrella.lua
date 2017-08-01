local assets=
{
	Asset("ANIM", "anim/umbrella.zip"),
	Asset("ANIM", "anim/swap_umbrella.zip"),
}
  
local function UpdateSound(inst)
    local soundShouldPlay = GetSeasonManager():IsRaining() and inst.components.equippable:IsEquipped()
    if soundShouldPlay ~= inst.SoundEmitter:PlayingSound("umbrellarainsound") then
        if soundShouldPlay then
		    inst.SoundEmitter:PlaySound("dontstarve/rain/rain_on_umbrella", "umbrellarainsound") 
        else
		    inst.SoundEmitter:KillSound("umbrellarainsound")
		end
    end
end  

local function onfinished(inst)
    inst:Remove()
end
    
local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_umbrella", "swap_umbrella")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
    UpdateSound(inst)
end

local function onunequip(inst, owner) 
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal") 
    UpdateSound(inst)
end
    
    
local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()    
    MakeInventoryPhysics(inst)
    
    anim:SetBank("umbrella")
    anim:SetBuild("umbrella")
    anim:PlayAnimation("idle")
    
    inst:AddTag("sharp")

    inst:AddComponent("dapperness")
    inst.components.dapperness.mitigates_rain = true
    -------
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.UMBRELLA_USES)
    inst.components.finiteuses:SetUses(TUNING.UMBRELLA_USES)
    inst.components.finiteuses:SetOnFinished( onfinished) 
    --inst.components.finiteuses:SetConsumption(ACTIONS.TERRAFORM, .125)
    -------

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.UMBRELLA_DAMAGE)
    
    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )
    
    inst:ListenForEvent("rainstop", function() UpdateSound(inst) end, GetWorld()) 
	inst:ListenForEvent("rainstart", function() UpdateSound(inst) end, GetWorld()) 
    
    
    return inst
end



return Prefab( "common/inventory/umbrella", fn, assets) 

