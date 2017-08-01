--- Tracks the herd that the object belongs to, and creates one if missing
local HerdMember = Class(function(self, inst)
    self.inst = inst
    self.herd = nil
    self.herdprefab = "beefaloherd"
    
    self.inst:DoTaskInTime(5, function() self:CreateHerd() end)
end)

function HerdMember:SetHerd(herd)
    self.herd = herd
end

function HerdMember:SetHerdPrefab(prefab)
    self.herdprefab = prefab
end

function HerdMember:GetHerd()
    return self.herd
end

function HerdMember:CreateHerd()
    if not self.herd then
        local herd = SpawnPrefab(self.herdprefab)
        if herd then
            herd.Transform:SetPosition(self.inst.Transform:GetWorldPosition() )
            if herd.components.herd then
                herd.components.herd:GatherNearbyMembers()
            end
        end
    end
end

function HerdMember:GetDebugString()
    return string.format("herd: %s", tostring(self.herd))
end


return HerdMember
