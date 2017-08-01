local Mood = Class(function(self, inst)
    self.inst = inst
    self.moodtimeindays = {length = nil, wait = nil}
    self.isinmood = false
    self.daystomoodchange = nil
    self.onentermood = nil
    self.onleavemood = nil
    self.moodseasons = {}
    self.firstseasonadded = false

    inst:ListenForEvent("daycomplete", function(inst, data)
        if self.daystomoodchange and self.daystomoodchange > 0 then
            self.daystomoodchange = self.daystomoodchange - 1
            self:CheckForMoodChange()
        end
    end, GetWorld())
end)

function Mood:GetDebugString()
    return string.format("inmood:%s, days till change:%s", tostring(self.isinmood), tostring(self.daystomoodchange) )
end

function Mood:SetMoodTimeInDays(length, wait)
    self.moodtimeindays.length = length
    self.moodtimeindays.wait = wait
    self.daystomoodchange = wait
    self.isinmood = false
end

function Mood:SetMoodSeason(activeseason)
    if self.moodseasons == nil then
        return
    end


    if not self.moodtimeindays.wait or self.moodtimeindays.wait >= 0 then
        table.insert(self.moodseasons, activeseason)
        if not self.firstseasonadded then

            self.inst:ListenForEvent("seasonChange", function(it, data)

                local active = false
                for i, s in pairs(self.moodseasons) do
                    if s == data.season then
                        active = true
                        break
                    end
                end
                if active then
                    self:SetIsInMood(true, true)
                else
                    self:ResetMood()
                end        
            end, GetWorld())
            self.firstseasonadded = true
        end
    end
end

function Mood:CheckForMoodChange()
    if self.daystomoodchange == 0 then
        self:SetIsInMood(not self:IsInMood() )
    end
end

function Mood:SetInMoodFn(fn)
    self.onentermood = fn
end

function Mood:SetLeaveMoodFn(fn)
    self.onleavemood = fn
end

function Mood:ResetMood()
    if self.moodseasons == nil then
        return
    end

    if self.seasonmood then
        self.seasonmood = false
        self.isinmood = false
        self.daystomoodchange = self.moodtimeindays.wait
        if self.onleavemood then
            self.onleavemood(self.inst)
        end
    end
end

function Mood:SetIsInMood(inmood, entireseason)
    if self.isinmood ~= inmood or entireseason then
    
        self.isinmood = inmood
        if self.isinmood then
            if entireseason then
                self.seasonmood = true
                self.daystomoodchange = GetSeasonManager() and GetSeasonManager():GetSeasonLength() or self.moodtimeindays.length
            else
                self.seasonmood = false
                self.daystomoodchange = self.moodtimeindays.length
            end
            if self.onentermood then
                self.onentermood(self.inst)
            end
        else
            if not entireseason then
                self.seasonmood = false
                self.daystomoodchange = self.moodtimeindays.wait
            end
            if self.onleavemood then
                self.onleavemood(self.inst)
            end
        end
    end
end

function Mood:IsInMood()
    return self.isinmood
end

function Mood:OnSave()
    return {inmood = self.isinmood, daysleft = self.daystomoodchange, moodseasons = self.moodseasons }
end

function Mood:OnLoad(data)
    if data.moodseasons then
        self.moodseasons = data.moodseasons
    end

    self.isinmood = not data.inmood
    local active = false
    if self.moodseasons ~= nil then
        --print("Loading through here for some reason!")
        local season = GetSeasonManager() and GetSeasonManager():GetSeason()
        for i, s in pairs(self.moodseasons) do
            if season and s == season then
                active = true
                break
            end
        end
    end
    self:SetIsInMood(data.inmood, active)
    self.daystomoodchange = data.daysleft
end

return Mood