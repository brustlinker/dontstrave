
USE_SETTINGS_FILE = PLATFORM ~= "PS4" and PLATFORM ~= "NACL"

PlayerProfile = Class(function(self)
    self.persistdata = 
    {
        xp = 0,
        unlocked_worldgen = {},
        unlocked_characters = {},        
        render_quality = RENDER_QUALITY.DEFAULT,
        characterinthrone = "waxwell",
        -- Controlls should be a seperate file
        controls = {},
        starts = 0,
        saw_display_adjustment_popup = false,
        device_caps_a = 0,
        device_caps_b = 20,
        customizationpresets = {},
    }

  	--we should migrate the non-gameplay stuff to a separate file, so that we can save them whenever we want
  
 	if not USE_SETTINGS_FILE then
        self.persistdata.volume_ambient = 7
        self.persistdata.volume_sfx = 7
        self.persistdata.volume_music = 7
        self.persistdata.HUDSize = 5
        self.persistdata.vibration = true
        self.persistdata.autosave = true
        self.persistdata.wathgrithrfont = true
        self.persistdata.screenshake = true
        self.persistdata.warneddifficultyrog = false
        self.persistdata.sendstats = true
        self.persistdata.controller_popup = false
	end

    self.dirty = true

end)


function PlayerProfile:Reset()
	
    self.persistdata.xp = 0
	self.persistdata.unlocked_worldgen = {}
	self.persistdata.unlocked_characters = {}
	self.persistdata.characterinthrone = "waxwell"
    self.persistdata.saw_display_adjustment_popup = false
    self.persistdata.device_caps_a = 0
    self.persistdata.device_caps_b = 20
    self.persistdata.customizationpresets = {}
	
 	if not USE_SETTINGS_FILE then
        self.persistdata.volume_ambient = 7
        self.persistdata.volume_sfx = 7
        self.persistdata.volume_music = 7
        self.persistdata.HUDSize = 5
        self.persistdata.vibration = true
        self.persistdata.autosave = true
        self.persistdata.wathgrithrfont = true
        self.persistdata.screenshake = true
        self.persistdata.warneddifficultyrog = false
        self.persistdata.sendstats = true
        self.persistdata.controller_popup = false
	end
	
    --self.persistdata.starts = 0 -- save starts?
	self.dirty = true
	self:Save()
end

function PlayerProfile:SoftReset()
    self.persistdata.xp = 0
	self.persistdata.unlocked_worldgen = {}
	self.persistdata.unlocked_characters = {}
	self.persistdata.characterinthrone = "waxwell"
    self.persistdata.saw_display_adjustment_popup = false
    self.persistdata.device_caps_a = 0
    self.persistdata.device_caps_b = 20
    self.persistdata.customizationpresets = {}
	
 	if not USE_SETTINGS_FILE then
        self.persistdata.volume_ambient = 7
        self.persistdata.volume_sfx = 7
        self.persistdata.volume_music = 7
        self.persistdata.HUDSize = 5
        self.persistdata.vibration = true
        self.persistdata.autosave = true
        self.persistdata.wathgrithrfont = true
        self.persistdata.screenshake = true
        self.persistdata.warneddifficultyrog = false
        self.persistdata.sendstats = true
        self.persistdata.controller_popup = false
	end
    -- and apply these values
    local str = json.encode(self.persistdata)
    self:Set(str, nil)
end


function PlayerProfile:UnlockEverything()
    self.persistdata.xp = 0
	self.persistdata.unlocked_characters = {}
	local characters = {'willow', 'wendy', 'wolfgang', 'wilton', 'wx78', 'wickerbottom', 'wes', 'waxwell', 'woodie', 'wathgrithr', 'webber', 'walani', 'warly', 'wilbur', 'woodlegs'}
	for k,v in pairs(characters) do
		self:UnlockCharacter(v)
	end
	self.dirty = true
	self:Save()
end

function PlayerProfile:SetValue(name, value)
    self.dirty = true
    self.persistdata[name] = value
end

function PlayerProfile:GetValue(name)
	return self.persistdata[name]
end

function PlayerProfile:SetVolume(ambient, sfx, music)
 	if USE_SETTINGS_FILE then
		TheSim:SetSetting("audio", "volume_ambient", tostring(math.floor(ambient))) 
		TheSim:SetSetting("audio", "volume_sfx", tostring(math.floor(sfx)))
		TheSim:SetSetting("audio", "volume_music", tostring(math.floor(music))) 		
	else
	    self:SetValue("volume_ambient", ambient) 
	    self:SetValue("volume_sfx", sfx) 
	    self:SetValue("volume_music", music) 
	    self.dirty = true
	end
end

function PlayerProfile:SetBloomEnabled(enabled)
 	if USE_SETTINGS_FILE then
		TheSim:SetSetting("graphics", "bloom", tostring(enabled)) 
	else
		self:SetValue("bloom", enabled)
		self.dirty = true
	end
end

function PlayerProfile:GetBloomEnabled()
 	if USE_SETTINGS_FILE then
		return TheSim:GetSetting("graphics", "bloom") == "true"
	else
		return self:GetValue("bloom")
	end
end

function PlayerProfile:SetHUDSize(size)
 	if USE_SETTINGS_FILE then
		TheSim:SetSetting("graphics", "HUDSize", tostring(size)) 
	else
		self:SetValue("HUDSize", size)
		self.dirty = true
	end
end

function PlayerProfile:GetHUDSize()
 	if USE_SETTINGS_FILE then
		return TheSim:GetSetting("graphics", "HUDSize") or 5
	else
		return self:GetValue("HUDSize") or 5
	end
end

function PlayerProfile:SetDistortionEnabled(enabled)
 	if USE_SETTINGS_FILE then
		TheSim:SetSetting("graphics", "distortion", tostring(enabled)) 
	else
		self:SetValue("distortion", enabled)
		self.dirty = true
	end
end

function PlayerProfile:GetDistortionEnabled()
 	if USE_SETTINGS_FILE then
		return TheSim:GetSetting("graphics", "distortion") == "true"
	else
		return self:GetValue("distortion")
	end
end

function PlayerProfile:SetScreenShakeEnabled(enabled)
 	if USE_SETTINGS_FILE then
		TheSim:SetSetting("graphics", "screenshake", tostring(enabled)) 
	else
		self:SetValue("screenshake", enabled)
		self.dirty = true
	end
end

function PlayerProfile:IsScreenShakeEnabled()
 	if USE_SETTINGS_FILE then
 		if TheSim:GetSetting("graphics", "screenshake") ~= nil then
			return TheSim:GetSetting("graphics", "screenshake") == "true"
		else
			return true -- Default to true this value hasn't been created yet
		end
	else
		if self:GetValue("screenshake") ~= nil then
			return self:GetValue("screenshake")
		else
			return true -- Default to true this value hasn't been created yet
		end
	end
end

function PlayerProfile:SetWathgrithrFontEnabled(enabled)
 	if USE_SETTINGS_FILE then
		TheSim:SetSetting("misc", "wathgrithrfont", tostring(enabled)) 
	else
		self:SetValue("wathgrithrfont", enabled)
		self.dirty = true
	end
end

function PlayerProfile:IsWathgrithrFontEnabled()
 	if USE_SETTINGS_FILE then
 		if TheSim:GetSetting("misc", "wathgrithrfont") ~= nil then
			return TheSim:GetSetting("misc", "wathgrithrfont") == "true"
		else
			return true -- Default to true this value hasn't been created yet
		end
	else
		if self:GetValue("wathgrithrfont") ~= nil then
			return self:GetValue("wathgrithrfont")
		else
			return true -- Default to true this value hasn't been created yet
		end
	end
end

function PlayerProfile:SetHaveWarnedDifficultyRoG()
	if USE_SETTINGS_FILE then
		TheSim:SetSetting("misc", "warneddifficultyrog", "true") 
	else
		self:SetValue("warneddifficultyrog", true)
		self.dirty = true
	end
end

function PlayerProfile:HaveWarnedDifficultyRoG()
	if USE_SETTINGS_FILE then
		return TheSim:GetSetting("misc", "warneddifficultyrog") == "true"
	else
		return self:GetValue("warneddifficultyrog")
	end
end

function PlayerProfile:SetVibrationEnabled(enabled)
 	if USE_SETTINGS_FILE then
		TheSim:SetSetting("misc", "vibration", tostring(enabled)) 
	else
		self:SetValue("vibration", enabled)
		self.dirty = true
	end
end

function PlayerProfile:GetVibrationEnabled()
 	if USE_SETTINGS_FILE then
		return TheSim:GetSetting("misc", "vibration") == "true"
	else
		return self:GetValue("vibration")
	end
end

function PlayerProfile:SetSendStatsEnabled(enabled)
	if USE_SETTINGS_FILE then
		TheSim:SetSetting("misc", "sendstats", tostring(enabled)) 
	else
		self:SetValue("sendstats", enabled)
		self.dirty = true
	end
end

function PlayerProfile:GetSendStatsEnabled()
 	if USE_SETTINGS_FILE then
 		if TheSim:GetSetting("misc", "sendstats") ~= nil then
			return TheSim:GetSetting("misc", "sendstats") == "true"
		else
			return true -- Default to true this value hasn't been created yet
		end
	else
		if self:GetValue("sendstats") ~= nil then
			return self:GetValue("sendstats")
		else
			return true -- Default to true this value hasn't been created yet
		end
	end
end

function PlayerProfile:SetAutosaveEnabled(enabled)
 	if not USE_SETTINGS_FILE then
		self:SetValue("autosave", enabled)
		self.dirty = true
	end
end

function PlayerProfile:GetAutosaveEnabled()
 	if not USE_SETTINGS_FILE then
		return self:GetValue("autosave")
	end
end

function PlayerProfile:GetWorldCustomizationPresets()
	local presets_string = self:GetValue("customizationpresets")

	if presets_string ~= nil and type(presets_string) == "string" then
		local success, presets = RunInSandbox(presets_string)
		if success then
			return presets
		else
			return {}
		end
	else
		return {}
	end
end

function PlayerProfile:AddWorldCustomizationPreset(preset, index)
	local presets_string = self:GetValue("customizationpresets")
	
	local success = nil
	local presets = nil
	if presets_string ~= nil and type(presets_string) == "string" then
		success, presets = RunInSandbox(presets_string)
		if not success then
			presets = {}
		end
	else
		presets = {}
	end

	if index then
		presets[index] = preset
	else
		table.insert(presets, preset)
	end
	local data = DataDumper(presets, nil, false)

	self:SetValue("customizationpresets", data)
	self.dirty = true
end

function PlayerProfile:GetVolume()
 	if USE_SETTINGS_FILE then
		local amb = TheSim:GetSetting("audio", "volume_ambient")
		if amb == nil then
			amb = 10
		end
		local sfx = TheSim:GetSetting("audio", "volume_sfx")
		if sfx == nil then
			sfx = 10
		end
		local music = TheSim:GetSetting("audio", "volume_music") 
		if music == nil then
			music = 10
		end

		return amb, sfx, music
	else
    	return self.persistdata.volume_ambient or 10, self.persistdata.volume_sfx or 10, self.persistdata.volume_music or 10
	end
end


function PlayerProfile:SetRenderQuality(quality)
	self:SetValue("render_quality", quality)
	self.dirty = true
end

function PlayerProfile:GetRenderQuality()
	return self:GetValue("render_quality")
end

----------------------------

function PlayerProfile:IsCharacterUnlocked(character)
    if character == "wilson" then
		return true
    end
    
    if self.persistdata.unlocked_characters[character] then
        return true
	end

	if not table.contains(GetOfficialCharacterList(), character) then
		return true -- mod character
	end

	return false
end

local cheevos = {
	willow = "achievement_1",
	wolfgang = "achievement_2",
	wendy = "achievement_3",
	wx78 = "achievement_4",
	wickerbottom = "achievement_5",
	woodie = "achievement_6",
	wes = "achievement_7",
	waxwell = "achievement_8",
}

function PlayerProfile:UnlockCharacter(character)

	if cheevos[character] then
		TheGameService:AwardAchievement(cheevos[character])
	end

    self.persistdata.unlocked_characters[character] = true
    self.dirty = true
end

function PlayerProfile:GetUnlockedCharacters()
    return self.persistdata.unlocked_characters
end
----------------------------

function PlayerProfile:IsWorldGenUnlocked(area, item)
	if self.persistdata.unlocked_worldgen == nil then
		return false
	end
	
	if self.persistdata.unlocked_worldgen[area] == nil then
		return false
	end
	
    if item == nil or self.persistdata.unlocked_worldgen[area][item] then
        return true
    end
    
    return false
end

function PlayerProfile:UnlockWorldGen(area, item)
	if self.persistdata.unlocked_worldgen == nil then
		self.persistdata.unlocked_worldgen = {}
	end
	
	if self.persistdata.unlocked_worldgen[area] == nil then
		self.persistdata.unlocked_worldgen[area] = {}
	end
	
    self.persistdata.unlocked_worldgen[area][item] = true
    self.dirty = true
end

function PlayerProfile:GetUnlockedWorldGen()
    return self.persistdata.unlocked_worldgen
end


----------------------------


function PlayerProfile:GetSaveName()
    return BRANCH == "release" and "profile" or "profile_"..BRANCH
end

function PlayerProfile:GetXP()
    return self.persistdata.xp
end

function PlayerProfile:SetXP(xp)
    self:SetValue("xp", xp)
end

function PlayerProfile:Save(callback)
	Print( VERBOSITY.DEBUG, "SAVING" )
    if self.dirty then
        local str = json.encode(self.persistdata)
        local insz, outsz = SavePersistentString(self:GetSaveName(), str, ENCODE_SAVES, callback)
    else
		if callback then
			callback(true)
		end
    end
end

function PlayerProfile:Load(callback)
    TheSim:GetPersistentString(self:GetSaveName(),
        function(load_success, str) 
			self:Set( str, callback )
        end, false)    
	SaveGameIndex:GuaranteeMinNumSlots(NUM_SAVE_SLOTS)
end

local function GetValueOrDefault( value, default )
	if value ~= nil then
		return value
	else
		return default
	end
end

function PlayerProfile:Set(str, callback)
	if not str or string.len(str) == 0 then
		print ("could not load ".. self:GetSaveName())

		if callback then
			self:SoftReset()	-- this is purposely inside the if
			callback(false)
		end
	else
		print ("loaded ".. self:GetSaveName())
		self.dirty = false

		self.persistdata = TrackedAssert("TheSim:GetPersistentString profile",  json.decode, str)
		    
        if self.persistdata.saw_display_adjustment_popup == nil then
            self.persistdata.saw_display_adjustment_popup = false
        end
        
		if self.persistdata.autosave == nil then
		    self.persistdata.autosave = true
		end
		    
 	    if USE_SETTINGS_FILE then
			-- Copy over old settings
			if self.persistdata.volume_ambient ~= nil and self.persistdata.volume_sfx ~= nil and self.persistdata.volume_music ~= nil then
				print("Copying audio settings from profile to settings.ini")

				self:SetVolume(self.persistdata.volume_ambient, self.persistdata.volume_sfx, self.persistdata.volume_music)
				self.persistdata.volume_ambient = nil 
				self.persistdata.volume_sfx = nil
				self.persistdata.volume_music = nil
				self.dirty = true
			end
		else
		    if self.persistdata.volume_ambient == nil and self.persistdata.volume_sfx == nil and self.persistdata.volume_music == nil then
                self.persistdata.volume_ambient = 7
                self.persistdata.volume_sfx = 7
                self.persistdata.volume_music = 7
                self.persistdata.HUDSize = 5
                self.persistdata.vibration = true
		    end		    
		end

		local amb, sfx, music = self:GetVolume()
		Print(VERBOSITY.DEBUG, "volumes", amb, sfx, music )
		
		TheMixer:SetLevel("set_sfx", sfx / 10)
		TheMixer:SetLevel("set_ambience", amb / 10)
		TheMixer:SetLevel("set_music", music / 10)
		
		TheInputProxy:EnableVibration(self:GetVibrationEnabled())

		if TheFrontEnd then
			local bloom_enabled = GetValueOrDefault( self.persistdata.bloom, true )
			local distortion_enabled = GetValueOrDefault( self.persistdata.distortion, true )

 	        if USE_SETTINGS_FILE then
				-- Copy over old settings
				if self.persistdata.bloom ~= nil and self.persistdata.distortion ~= nil and self.persistdata.HUDSize ~= nil then
					print("Copying render settings from profile to settings.ini")
					
					self:SetBloomEnabled(bloom_enabled)
					self:SetDistortionEnabled(distortion_enabled)
					self:SetHUDSize(self.persistdata.HUDSize)
					self.persistdata.bloom = nil
					self.persistdata.distortion = nil
					self.persistdata.HUDSize = nil
					self.dirty = true
				else
					bloom_enabled = self:GetBloomEnabled()
					distortion_enabled = self:GetDistortionEnabled()
				end
			end
			print("bloom_enabled",bloom_enabled)
			TheFrontEnd:GetGraphicsOptions():SetBloomEnabled( bloom_enabled )
			TheFrontEnd:GetGraphicsOptions():SetDistortionEnabled( distortion_enabled )
		end
		
		-- old save data will not have the controls section so create it
		if nil == self.persistdata.controls then
		    self.persistdata.controls = {}
		end
		
	    for idx,entry in pairs(self.persistdata.controls) do
	        
	        local enabled = true
			if entry.enabled == nil then
				enabled = false
			else 
				enabled = entry.enabled
			end
	        TheInputProxy:LoadControls(entry.guid, entry.data, enabled)
	    end
	    
		if nil == self.persistdata.device_caps_a then
            self.persistdata.device_caps_a = 0
            self.persistdata.device_caps_b = 20
		end
		
		self.persistdata.device_caps_a, self.persistdata.device_caps_b = TheSim:UpdateDeviceCaps(self.persistdata.device_caps_a, self.persistdata.device_caps_b)
        self.dirty = true

		if callback then
			callback(true)
		end
	end
end

function PlayerProfile:SetDirty(dirty)
	self.dirty = dirty
end

function PlayerProfile:GetControls(guid)  
    local controls = nil
    local enabled = false
    for idx, entry in pairs(self.persistdata.controls) do
        if entry.guid == guid then
            controls = entry.data
            enabled = entry.enabled
        end
    end  
    return controls, enabled
end

function PlayerProfile:SetControls(guid, data, enabled)  
	
	-- check if this device is already in the list and update if found
	local found = false
    for idx, entry in pairs(self.persistdata.controls) do
        if entry.guid == guid then
            entry.data = data
            entry.enabled = enabled
            found = true
        end
    end  
    
    -- not an existing device so add it
    if not found then
        table.insert(self.persistdata.controls, {["guid"]=guid, ["data"]=data, ["enabled"] = enabled})
    end

    self.dirty = true
end

function PlayerProfile:SawDisplayAdjustmentPopup()
    return self.persistdata.saw_display_adjustment_popup
end

function PlayerProfile:ShowedDisplayAdjustmentPopup()
    self.persistdata.saw_display_adjustment_popup = true
	self.dirty = true
end

function PlayerProfile:SawControllerPopup()
    local sawPopup
 	if USE_SETTINGS_FILE then
		sawPopup = TheSim:GetSetting("misc", "controller_popup") 
		if nil == sawPopup then
		    sawPopup = false
		end
	else
	    if nil == self.persistdata.controller_popup then
	        sawPopup = false
	    else
		    sawPopup = self.persistdata.controller_popup
		end
	end
	
	return sawPopup
end

function PlayerProfile:ShowedControllerPopup()
 	if USE_SETTINGS_FILE then
		TheSim:SetSetting("misc", "controller_popup", tostring(true)) 
	else
		self:SetValue("controller_popup", true)
		self.dirty = true
	end
end


return PlayerProfile
