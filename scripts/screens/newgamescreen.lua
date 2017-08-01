local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local ImageButton = require "widgets/imagebutton"
local Spinner = require "widgets/spinner"
local Menu = require "widgets/menu"
local Text = require "widgets/text"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
require "os"

local WorldGenScreen = require "screens/worldgenscreen"
local CustomizationScreen = require "screens/customizationscreen"
local CharacterSelectScreen = require "screens/characterselectscreen"
local BigPopupDialogScreen = require "screens/bigpopupdialog"
local ComingSoonScreen = require "screens/comingsoonscreen"

local REIGN_OF_GIANTS_DIFFICULTY_WARNING_XP_THRESHOLD = 20*32 --20 xp per day, 32 days

local NewGameScreen = Class(Screen, function(self, slotnum)
	Screen._ctor(self, "NewGameScreen")
    self.profile = Profile
    self.saveslot = slotnum
    self.character = "wilson"

   	self.scaleroot = self:AddChild(Widget("scaleroot"))
    self.scaleroot:SetVAnchor(ANCHOR_MIDDLE)
    self.scaleroot:SetHAnchor(ANCHOR_MIDDLE)
    self.scaleroot:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.root = self.scaleroot:AddChild(Widget("root"))
    self.root:SetScale(.9)

    self.bg = self.root:AddChild(Image("images/fepanels.xml", "panel_saveslots.tex"))
    
	--[[self.cancelbutton = self.root:AddChild(ImageButton())
	self.cancelbutton:SetScale(.8,.8,.8)
    self.cancelbutton:SetText(STRINGS.UI.NEWGAMESCREEN.CANCEL)
    self.cancelbutton:SetOnClick( function() TheFrontEnd:PopScreen(self) end )
    self.cancelbutton:SetFont(BUTTONFONT)
    self.cancelbutton:SetTextSize(35)
    self.cancelbutton.text:SetVAlign(ANCHOR_MIDDLE)
    self.cancelbutton.text:SetColour(0,0,0,1)
    self.cancelbutton:SetPosition( 0, -235, 0)
    --]]

    self.title = self.root:AddChild(Text(TITLEFONT, 60))
    self.title:SetPosition( 75, 135, 0)
    self.title:SetRegionSize(250,60)
    self.title:SetHAlign(ANCHOR_LEFT)
	self.title:SetString(STRINGS.UI.NEWGAMESCREEN.TITLE)

	self.portraitbg = self.root:AddChild(Image("images/saveslot_portraits.xml", "background.tex"))
	self.portraitbg:SetPosition(-120, 135, 0)	
	self.portraitbg:SetClickable(false)	

	self.portrait = self.root:AddChild(Image())
	self.portrait:SetClickable(false)		
	local atlas = (table.contains(MODCHARACTERLIST, self.character) and "images/saveslot_portraits/"..self.character..".xml") or "images/saveslot_portraits.xml"
	self.portrait:SetTexture(atlas, self.character..".tex")
	self.portrait:SetPosition(-120, 135, 0)
  
  	local menuitems = {}
  	if IsDLCInstalled(REIGN_OF_GIANTS) or IsDLCInstalled(CAPY_DLC) then
		local dlc_buttons = {}

		if IsDLCInstalled(REIGN_OF_GIANTS) then table.insert(dlc_buttons, self:MakeReignOfGiantsButton()) end		
		if IsDLCInstalled(CAPY_DLC) then table.insert(dlc_buttons, self:MakeCapyButton()) end

		table.insert(menuitems, {text = STRINGS.UI.NEWGAMESCREEN.START, cb = function() self:Start() end, offset = Vector3(0,10,0)})

		local xOffset = #dlc_buttons == 2 and -80 or 0
		local yOffset = #dlc_buttons == 2 and 5 or 0
		local yIncrement = #dlc_buttons == 2 and 70 or 0

		for i = 1, #dlc_buttons do
			table.insert(menuitems, {widget = dlc_buttons[i], offset = Vector3(xOffset, yOffset, 0)})
			xOffset = xOffset * -1
			yOffset = yOffset + yIncrement
		end

	--   menuitems = 
	--   {
	-- 		{widget = self.RoGbutton, offset = Vector3(-80, 5, 0)},
	-- 		{widget = self.Capybutton, offset = Vector3(80, 75, 0)},
	--   }

		table.insert(menuitems, {text = STRINGS.UI.NEWGAMESCREEN.CHANGECHARACTER, cb = function() self:ChangeCharacter() end, offset = Vector3(0, yIncrement, 0)})
		table.insert(menuitems, {text = STRINGS.UI.NEWGAMESCREEN.CUSTOMIZE, cb = function() self:Customize() end, offset = Vector3(0, yIncrement, 0)})
		table.insert(menuitems, {text = STRINGS.UI.NEWGAMESCREEN.CANCEL, cb = 
			-- Added this to fix the wrong character portrait bug when players cancel a new game
			function()
				if IsDLCInstalled(REIGN_OF_GIANTS) then
					EnableDLC(REIGN_OF_GIANTS)
				end

				if IsDLCInstalled(CAPY_DLC) then
					EnableDLC(CAPY_DLC)
				end

				TheFrontEnd:PopScreen(self) 
			end,
		offset = Vector3(0, yIncrement, 0)})
  	else
  		menuitems = 
	    {
			{text = STRINGS.UI.NEWGAMESCREEN.START, cb = function() self:Start() end, offset = Vector3(0,10,0)},
			{text = STRINGS.UI.NEWGAMESCREEN.CHANGECHARACTER, cb = function() self:ChangeCharacter() end},
			{text = STRINGS.UI.NEWGAMESCREEN.CUSTOMIZE, cb = function() self:Customize() end},
			{text = STRINGS.UI.NEWGAMESCREEN.CANCEL, cb = 
				function()
					if IsDLCInstalled(REIGN_OF_GIANTS) then
						EnableDLC(REIGN_OF_GIANTS)
					end

					if IsDLCInstalled(CAPY_DLC) then
						EnableDLC(CAPY_DLC)
					end

					TheFrontEnd:PopScreen(self) 
				end
			},
	    }
  	end

    self.menu = self.root:AddChild(Menu(menuitems, -70))
	self.menu:SetPosition(0, 30, 0)

	self.default_focus = self.menu
    
end)

function NewGameScreen:OnGainFocus()
	NewGameScreen._base.OnGainFocus(self)
	self.menu:SetFocus()
end

function NewGameScreen:OnControl(control, down)
    if Screen.OnControl(self, control, down) then return true end
    if not down and control == CONTROL_CANCEL then
        TheFrontEnd:PopScreen(self)
        return true
    end
end

function NewGameScreen:SetSavedCustomOptions(options)
	if self.savedcustomoptions == nil then
		self.savedcustomoptions = {}
	end

	local currentdlc = MAIN_GAME
	local dlcs = {CAPY_DLC, REIGN_OF_GIANTS, MAIN_GAME}
	for _, dlc in ipairs(dlcs) do
		if IsDLCInstalled(dlc) and IsDLCEnabled(dlc) then
			currentdlc = dlc
		end
	end
	self.savedcustomoptions[currentdlc] = options
end

function NewGameScreen:GetSavedCustomOptions()
	if self.savedcustomoptions == nil then
		self.savedcustomoptions = {}
	end

	local currentdlc = MAIN_GAME
	local dlcs = {CAPY_DLC, REIGN_OF_GIANTS, MAIN_GAME}
	for _, dlc in ipairs(dlcs) do
		if IsDLCInstalled(dlc) and IsDLCEnabled(dlc) then
			currentdlc = dlc
		end
	end
	return self.savedcustomoptions[currentdlc]
end

function NewGameScreen:Customize( )
	
	local function onSet(options, dlc)
		TheFrontEnd:PopScreen()
		if options then
			self:SetSavedCustomOptions(options)
			self.customoptions = options
		end
	end

	--if self.CapyDLC and IsDLCInstalled(CAPY_DLC) then
	--	TheFrontEnd:PushScreen(ComingSoonScreen())
	--	return
	--end

	self.customoptions = self:GetSavedCustomOptions()
	package.loaded["map/customise"] = nil

	--[[if (self.prevworldcustom ~= self.RoG and IsDLCInstalled(REIGN_OF_GIANTS)) or (self.prevworldcustom ~= self.CapyDLC and IsDLCInstalled(CAPY_DLC)) then
		local prev = self.prevcustomoptions
		self.prevcustomoptions = self.customoptions
		self.customoptions = prev
		package.loaded["map/customise"] = nil
	end

	self.prevworldcustom = self.RoG]]

	-- Clean up the preset setting since we're going back to customization screen, not to worldgen
	if self.customoptions and self.customoptions.actualpreset then
		self.customoptions.preset = self.customoptions.actualpreset
		self.customoptions.actualpreset = nil
	end
	-- Clean up the tweak table since we're going back to customization screen, not to worldgen
	if self.customoptions and self.customoptions.faketweak and self.customoptions.tweak and #self.customoptions.faketweak > 0 then
		for i,v in pairs(self.customoptions.faketweak) do
			for m,n in pairs(self.customoptions.tweak) do
				for j,k in pairs(n) do
					if v == j then -- Found the fake tweak setting, now remove it from the table
						self.customoptions.tweak[m][j] = nil
						break
					end
				end
			end
		end
	end

	TheFrontEnd:PushScreen(CustomizationScreen(Profile, onSet, self.customoptions, self.RoG))--self.customization)
end

function NewGameScreen:ChangeCharacter(  )
	
	local function onSet(character, random)
		TheFrontEnd:PopScreen()
		if character and (IsDLCInstalled(REIGN_OF_GIANTS) or IsDLCInstalled(CAPY_DLC)) then
			package.loaded["map/customise"] = nil
			--self.prevworldcustom = self.RoG
			--self.customoptions = nil
			self.prevcharacter = nil
			self.characterreverted = false
			self.character = character

			local atlas = (table.contains(MODCHARACTERLIST, character) and "images/saveslot_portraits/"..character..".xml") or "images/saveslot_portraits.xml"
			self.portrait:SetTexture(atlas, self.character..".tex")
			if random then
				atlas = "images/saveslot_portraits.xml"
				self.portrait:SetTexture(atlas, "random.tex")
			end
		elseif character then
			self.character = character			
			local atlas = (table.contains(MODCHARACTERLIST, character) and "images/saveslot_portraits/"..character..".xml") or "images/saveslot_portraits.xml"
			self.portrait:SetTexture(atlas, self.character..".tex")
			if random then
				atlas = "images/saveslot_portraits.xml"
				self.portrait:SetTexture(atlas, "random.tex")
			end
		end

		if IsDLCInstalled(CAPY_DLC) and self.RoG then
			DisableDLC(CAPY_DLC)
			EnableDLC(REIGN_OF_GIANTS)
		end

	end

	if IsDLCInstalled(CAPY_DLC) and self.RoG then
		DisableDLC(REIGN_OF_GIANTS)
		EnableDLC(CAPY_DLC)
	end

	TheFrontEnd:PushScreen(CharacterSelectScreen(Profile, onSet, false, self.character, self.RoG))
end



function NewGameScreen:Start()
	local function onsaved()
	    StartNextInstance({reset_action=RESET_ACTION.LOAD_SLOT, save_slot = self.saveslot})
	end

	local function GetEnabledDLCs()
		local dlc = {REIGN_OF_GIANTS = self.RoG, CAPY_DLC = self.CapyDLC}
		return dlc
	end

	local function CleanupTweakTable()
		-- Clean up the tweak table since we don't want "default" overrides
		if self.customoptions and self.customoptions.faketweak and self.customoptions.tweak and #self.customoptions.faketweak > 0 then
			for i,v in pairs(self.customoptions.faketweak) do
				for m,n in pairs(self.customoptions.tweak) do
					for j,k in pairs(n) do
						if v == j and k == "default" then -- Found the fake tweak setting for "default", now remove it from the table
							self.customoptions.tweak[m][j] = nil
							break
						end
					end
				end
			end
		end
	end

	local function StartGame(mode)
		self.customoptions = self:GetSavedCustomOptions()
		--if self.prevworldcustom ~= self.RoG then
		--	self.customoptions = self.prevcustomoptions
		--end

		CleanupTweakTable()
		self.root:Disable()

		local enabled_dlc = GetEnabledDLCs()

		local function SetForSWGeneration(enable_rog)
			EnableDLC(CAPY_DLC)
			enabled_dlc = {REIGN_OF_GIANTS = false, CAPY_DLC = true}
    
	        if self.customoptions == nil then
	        	self.customoptions = {}
	        end
	        self.customoptions.ROGEnabled = enable_rog
		end

		local function FadeAndStart()
			TheFrontEnd:Fade(false, 1, function()
				SaveGameIndex:StartSurvivalMode(self.saveslot, self.character, self.customoptions, onsaved, enabled_dlc, mode)
			end )
		end

		local function PromptPlayerWithSWCompatibility(enable_rog)

			local string = STRINGS.UI.SAVEINTEGRATION.SW_COMP_DESCRIPTION

			if enable_rog then
				string = STRINGS.UI.SAVEINTEGRATION.SW_COMP_ROG_DESCRIPTION
			end

			TheFrontEnd:PushScreen(BigPopupDialogScreen(STRINGS.UI.SAVEINTEGRATION.SW_COMP, string,
				{{text=STRINGS.UI.SAVEINTEGRATION.YES,
					cb = function()
						SetForSWGeneration(enable_rog)
						FadeAndStart()
					end
				},
				{text=STRINGS.UI.SAVEINTEGRATION.NO,
					cb = function()
						DisableDLC(CAPY_DLC)

						if enable_rog then
							EnableDLC(REIGN_OF_GIANTS)
						end

						FadeAndStart()
					end
				},
				{text=STRINGS.UI.SAVEINTEGRATION.CANCEL,
					cb=function()
						TheFrontEnd:PopScreen()
						TheFrontEnd:PopScreen(self)
					end
				},
				}, nil, 165, Vector3(0, 155, 0))
			)
		end

		if mode == "survival" then
			if IsDLCInstalled(CAPY_DLC) then
				if self.RoG then
					DisableDLC(REIGN_OF_GIANTS)
					PromptPlayerWithSWCompatibility(true)
					return
				else
					PromptPlayerWithSWCompatibility(false)
					return
				end
			end
		end

		TheFrontEnd:Fade(false, 1, function()
			SaveGameIndex:StartSurvivalMode(self.saveslot, self.character, self.customoptions, onsaved, enabled_dlc, mode)
		end )
	end

	local xp = Profile:GetXP()
	if IsDLCInstalled(REIGN_OF_GIANTS) and self.RoG and xp <= REIGN_OF_GIANTS_DIFFICULTY_WARNING_XP_THRESHOLD and not Profile:HaveWarnedDifficultyRoG() then
		TheFrontEnd:PushScreen(BigPopupDialogScreen(STRINGS.UI.NEWGAMESCREEN.ROG_WARNING_TITLE, STRINGS.UI.NEWGAMESCREEN.ROG_WARNING_BODY, 
			{{text=STRINGS.UI.NEWGAMESCREEN.YES, 
				cb = function() 
					Profile:SetHaveWarnedDifficultyRoG()
					TheFrontEnd:PopScreen()
					self:Start()
				end},
			{text=STRINGS.UI.NEWGAMESCREEN.NO, 
				cb = function() 
					TheFrontEnd:PopScreen() 
				end}  
			})
		)
	elseif IsDLCInstalled(CAPY_DLC) and self.CapyDLC then
		StartGame("shipwrecked")
		-- TheFrontEnd:PushScreen(BigPopupDialogScreen("Shipwrecked", "Start in Shipwrecked or RoG?",
		-- 	{{text="Shipwrecked",
		-- 		cb = function()
		-- 			TheFrontEnd:PopScreen()
		-- 			StartGame("shipwrecked")
		-- 		end},
		-- 	{text="RoG",
		-- 		cb = function()
		-- 			TheFrontEnd:PopScreen()
		-- 			StartGame("survival")
		-- 		end}
		-- 	})
		-- )
	else
		StartGame("survival")
		--[[if self.prevworldcustom ~= self.RoG then
			self.customoptions = self.prevcustomoptions
		end

		CleanupTweakTable()

		self.root:Disable()
		TheFrontEnd:Fade(false, 1, function() SaveGameIndex:StartSurvivalMode(self.saveslot, self.character, self.customoptions, onsaved, GetEnabledDLCs()) end )]]
	end
end


function NewGameScreen:GetHelpText()
	local controller_id = TheInput:GetControllerID()
	return TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK
end

function NewGameScreen:MakeReignOfGiantsButton()
	--EnableAllDLC()
	DisableAllDLC()
	self.RoG = IsDLCEnabled(REIGN_OF_GIANTS)
	--self.prevworldcustom = true

	self.RoGbutton = self:AddChild(Widget("option"))
	self.RoGbutton.image = self.RoGbutton:AddChild(Image("images/ui.xml", "DLCicontoggle.tex"))
	self.RoGbutton.image:SetPosition(25,0,0)
	self.RoGbutton.image:SetTint(1,1,1,.3)

	self.RoGbutton.checkbox = self.RoGbutton:AddChild(Image("images/ui.xml", "button_checkbox1.tex"))
	self.RoGbutton.checkbox:SetPosition(-35,0,0)
	self.RoGbutton.checkbox:SetScale(0.5,0.5,0.5)
	self.RoGbutton.checkbox:SetTint(1.0,0.5,0.5,1)

	self.RoGbutton.bg = self.RoGbutton:AddChild(UIAnim())
	self.RoGbutton.bg:GetAnimState():SetBuild("savetile_small")
	self.RoGbutton.bg:GetAnimState():SetBank("savetile_small")
	self.RoGbutton.bg:GetAnimState():PlayAnimation("anim")
	self.RoGbutton.bg:SetPosition(-75,0,0)
	self.RoGbutton.bg:SetScale(1.12,1,1)

	self.RoGbutton.OnGainFocus = function()
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_mouseover")
			self.RoGbutton:SetScale(1.1,1.1,1)
			self.RoGbutton.bg:GetAnimState():PlayAnimation("over")
		end

	self.RoGbutton.OnLoseFocus = function()
			self.RoGbutton:SetScale(1,1,1)
			self.RoGbutton.bg:GetAnimState():PlayAnimation("anim")
		end

	self.RoGbutton.OnControl = function(_, control, down) 
		if Widget.OnControl(self.RoGbutton, control, down) then return true end
		if control == CONTROL_ACCEPT and not down then
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
			self.RoG = not self.RoG
			if self.RoG == true then
				self.RoGbutton.enable()
				if self.Capybutton then
					self.Capybutton.disable()
				end
			elseif self.RoG == false then
				self.RoGbutton.disable()
			end
			return true
		end
	end

	self.RoGbutton.enable = function()
		self.RoG = true
		self.RoGbutton.checkbox:SetTint(1,1,1,1)
		self.RoGbutton.image:SetTint(1,1,1,1)
		if self.characterreverted == true and self.prevcharacter ~= nil then --Switch back to DLC character if possible
			self.character = self.prevcharacter
			self.prevcharacter = nil
			self.characterreverted = false
			local atlas = (table.contains(MODCHARACTERLIST, self.character) and "images/saveslot_portraits/"..self.character..".xml") or "images/saveslot_portraits.xml"
			self.portrait:SetTexture(atlas, self.character..".tex")
		end
		self.RoGbutton.checkbox:SetTexture("images/ui.xml", "button_checkbox2.tex")
		EnableDLC(REIGN_OF_GIANTS)
	end 

	self.RoGbutton.disable = function()
		self.RoG = false
		self.RoGbutton.checkbox:SetTint(1.0,0.5,0.5,1)
		self.RoGbutton.image:SetTint(1,1,1,.3)
		if self.character == "wathgrithr" or self.character == "webber" then --Switch to Wilson if currently have DLC char selected
			self.characterreverted = true
			self.prevcharacter = self.character
			self.character = "wilson"
			local atlas = (table.contains(MODCHARACTERLIST, self.character) and "images/saveslot_portraits/"..self.character..".xml") or "images/saveslot_portraits.xml"
			self.portrait:SetTexture(atlas, self.character..".tex")
		end
		self.RoGbutton.checkbox:SetTexture("images/ui.xml", "button_checkbox1.tex")
		DisableDLC(REIGN_OF_GIANTS)
	end

	

	self.RoGbutton.GetHelpText = function()
		local controller_id = TheInput:GetControllerID()
		local t = {}
	    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_ACCEPT) .. " " .. STRINGS.UI.HELP.TOGGLE)	
		return table.concat(t, "  ")
	end

	return self.RoGbutton
end


function NewGameScreen:MakeCapyButton()
	--EnableAllDLC()
	DisableAllDLC()
	self.CapyDLC = IsDLCEnabled(CAPY_DLC)
	--self.prevworldcustom = true

	self.Capybutton = self:AddChild(Widget("capybutton"))
	self.Capybutton.image = self.Capybutton:AddChild(Image("images/ui.xml", "SWicontoggle.tex"))
	self.Capybutton.image:SetPosition(25,0,0)
	self.Capybutton.image:SetTint(1,1,1,.3)


	self.Capybutton.checkbox = self.Capybutton:AddChild(Image("images/ui.xml",  "button_checkbox1.tex"))
	self.Capybutton.checkbox:SetPosition(-35,0,0)
	self.Capybutton.checkbox:SetScale(0.5,0.5,0.5)
	self.Capybutton.checkbox:SetTint(1.0,0.5,0.5,1)

	self.Capybutton.bg = self.Capybutton:AddChild(UIAnim())
	self.Capybutton.bg:GetAnimState():SetBuild("savetile_small")
	self.Capybutton.bg:GetAnimState():SetBank("savetile_small")
	self.Capybutton.bg:GetAnimState():PlayAnimation("anim")
	self.Capybutton.bg:SetPosition(-75,0,0)
	self.Capybutton.bg:SetScale(1.12,1,1)

	self.Capybutton.OnGainFocus = function()
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_mouseover")
			self.Capybutton:SetScale(1.1,1.1,1)
			self.Capybutton.bg:GetAnimState():PlayAnimation("over")
		end

	self.Capybutton.OnLoseFocus = function()
			self.Capybutton:SetScale(1,1,1)
			self.Capybutton.bg:GetAnimState():PlayAnimation("anim")
		end

	self.Capybutton.OnControl = function(_, control, down) 
		if Widget.OnControl(self.Capybutton, control, down) then return true end
		if control == CONTROL_ACCEPT and not down then
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
			self.CapyDLC = not self.CapyDLC
			if self.CapyDLC == true then
				self.Capybutton.enable()

				if self.RoGbutton then
					self.RoGbutton.disable()
				end
			elseif self.CapyDLC == false then
				self.Capybutton.disable()

			end
			return true
		end
	end

	self.Capybutton.enable = function()
		self.CapyDLC = true 
		self.Capybutton.checkbox:SetTint(1,1,1,1)
		self.Capybutton.image:SetTint(1,1,1,1)
		self.Capybutton.checkbox:SetTexture("images/ui.xml", "button_checkbox2.tex")
		EnableDLC(CAPY_DLC)
	end 

	self.Capybutton.disable = function()
		self.CapyDLC = false
		self.Capybutton.checkbox:SetTint(1.0,0.5,0.5,1)
		self.Capybutton.image:SetTint(1,1,1,.3)
		self.Capybutton.checkbox:SetTexture("images/ui.xml", "button_checkbox1.tex")
		DisableDLC(CAPY_DLC)
	end

	self.Capybutton.GetHelpText = function()
		local controller_id = TheInput:GetControllerID()
		local t = {}
	    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_ACCEPT) .. " " .. STRINGS.UI.HELP.TOGGLE)	
		return table.concat(t, "  ")
	end

	return self.Capybutton
end

return NewGameScreen
