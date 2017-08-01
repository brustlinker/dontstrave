local Plantable = Class(function(self, inst)
    self.inst = inst
    self.growtime = 120
    self.product = nil
    self.minlevel = 1
end)



function Plantable:CollectUseActions(doer, target, actions)
    if target.components.grower and target.components.grower:IsEmpty() and target.components.grower:IsFertile() and target.components.grower.level >= self.minlevel then
        table.insert(actions, ACTIONS.PLANT)
    end
end


return Plantable
