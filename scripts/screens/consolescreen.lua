require "util"
local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local NumericSpinner = require "widgets/numericspinner"
local TextEdit = require "widgets/textedit"
local Widget = require "widgets/widget"

local VALID_CHARS = [[ abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,:;[]\@!#$%&()'*+-/=?^_{|}~"]]
-- fix syntax highlighting due to above list: "'

local CONSOLE_HISTORY = {}

local ConsoleScreen = Class(Screen, function(self)
	Screen._ctor(self, "ConsoleScreen")
	self:DoInit()
end)

function ConsoleScreen:OnBecomeActive()
	ConsoleScreen._base.OnBecomeActive(self)
	TheFrontEnd:ShowConsoleLog()

	self.console_edit:SetFocus()
	self.console_edit:SetEditing(true)
	TheFrontEnd:LockFocus(true)
end

function ConsoleScreen:OnControl(control, down)
	if ConsoleScreen._base.OnControl(self, control, down) then return true end

	if not down and (control == CONTROL_CANCEL or control == CONTROL_OPEN_DEBUG_CONSOLE) then 
		self:Close()
		return true
	end
end

function ConsoleScreen:OnRawKey( key, down)
	if ConsoleScreen._base.OnRawKey(self, key, down) then return true end
	
	if down then return end
	
	if key == KEY_TAB then
		self:AutoComplete()
	elseif key == KEY_UP then
		local len = #CONSOLE_HISTORY
		if len > 0 then
			if self.history_idx ~= nil then
				self.history_idx = math.max( 1, self.history_idx - 1 )
			else
				self.history_idx = len
			end
			self.console_edit:SetString( CONSOLE_HISTORY[ self.history_idx ] )
		end
	elseif key == KEY_DOWN then
		local len = #CONSOLE_HISTORY
		if len > 0 then
			if self.history_idx ~= nil then
				if self.history_idx == len then
					self.console_edit:SetString( "" )
				else
					self.history_idx = math.min( len, self.history_idx + 1 )
					self.console_edit:SetString( CONSOLE_HISTORY[ self.history_idx ] )
				end
			end
		end
	else
		self.autocompletePrefix = nil
		self.autocompleteObjName = ""
		self.autocompleteObj = nil
		self.autocompleteOffset = -1
		return false
	end
	
	return true
end

function ConsoleScreen:Run()
	local fnstr = self.console_edit:GetString()

    SuUsedAdd("console_used")
	
	if fnstr ~= "" then
		table.insert( CONSOLE_HISTORY, fnstr )
	end
	
	local status, r = pcall( loadstring( fnstr ) )
	if not status then
		nolineprint(r)
	end	
end

function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

-- For this to be improved, you really need to start knowing about the language that's
-- being autocompleted and the string must be tokenized and fed into a lexer.
--
-- For instance, what should you autocomplete here:
--		print(TheSim:Get<tab>
--
-- Given understanding of the language, we know that the object to get is TheSim and
-- it's the metatable from that to autocomplete from. However, you need to know that
-- "print(" is not part of that object.
--
-- Conversely, if I have "SomeFunction().GetTheSim():Get<tab>" then I need to include
-- "SomeFunction()." as opposed to stripping it off. Again, we're back to understanding
-- the language.
--
-- Something that might work is to cheat by starting from the last token, then iterating
-- backwards evaluating pcalls until you don't get an error or you reach the front of the
-- string.
function ConsoleScreen:AutoComplete()
	local str = self.console_edit:GetString()

	if self.autocompletePrefix == nil and self.autocompleteObj == nil then
		local autocomplete_obj_name = nil
		local autocomplete_prefix = str
		
		local rev_str = string.reverse( str )
		local idx = string.find( rev_str, ".", 1, true )
		if idx == nil then
			idx = string.find( rev_str, ":", 1, true )
		end
		if idx ~= nil then
			autocomplete_obj_name = string.sub( str, 1, string.len( str ) - idx )
			autocomplete_prefix = string.sub( str, string.len( str ) - idx + 2, string.len( str ) - 1 )
		end
		
		self.autocompletePrefix = autocomplete_prefix

		if autocomplete_obj_name ~= nil then
			local status, r = pcall( loadstring( "__KLEI_AUTOCOMPLETE=" .. autocomplete_obj_name ) )
			if status then
				self.autocompleteObjName = string.sub( str, 1, string.len( str ) - idx + 1 ) -- must include that last character!
				self.autocompleteObj = getmetatable( __KLEI_AUTOCOMPLETE )
				if self.autocompleteObj == nil then
					self.autocompleteObj = __KLEI_AUTOCOMPLETE
				end
			end
		end
	end
	
	local autocomplete_obj = self.autocompleteObj or _G
	local len = string.len( self.autocompletePrefix )
	
	local found = false
	local counter = 0
	for k, v in pairs( autocomplete_obj ) do
		if string.starts( k, self.autocompletePrefix ) then
			if self.autocompleteOffset == -1 or self.autocompleteOffset < counter then
				self.console_edit:SetString( self.autocompleteObjName .. k )
				self.autocompleteOffset = counter
				found = true
				break
			end	
			counter = counter + 1
		end
	end

	if not found then
		self.autocompleteOffset = -1
		for k, v in pairs( autocomplete_obj ) do
			if string.starts( k, self.autocompletePrefix ) then
				self.console_edit:SetString( self.autocompleteObjName .. k )
				self.autocompleteOffset = 0
			end
		end		
	end
end

function ConsoleScreen:Close()
	SetPause(false)
	TheInput:EnableDebugToggle(true)
	TheFrontEnd:PopScreen()
end

function ConsoleScreen:OnTextEntered()
	self:Run()
	self:Close()
    if TheFrontEnd.consoletext.closeonrun then
        TheFrontEnd:HideConsoleLog()
        TheFrontEnd.consoletext.closeonrun = nil
    end
end

function GetConsoleHistory()
    return CONSOLE_HISTORY
end

function SetConsoleHistory(history)
    if type(history) == "table" and type(history[1]) == "string" then
        CONSOLE_HISTORY = history
    end
end

function ConsoleScreen:DoInit()
	SetPause(true,"console")
	TheInput:EnableDebugToggle(false)

	local label_width = 200
	local label_height = 50
	local label_offset = 450

	local space_between = 30
	local height_offset = -270

	local fontsize = 30
	
	local edit_width = 900
	local edit_bg_padding = 100
	
	self.autocompleteOffset = -1	
	self.autocompletePrefix = nil
	self.autocompleteObj = nil
	self.autocompleteObjName = ""
	
	
	self.root = self:AddChild(Widget(""))
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    self.root:SetVAnchor(ANCHOR_BOTTOM)
    --self.root:SetMaxPropUpscale(MAX_HUD_SCALE)
	self.root = self.root:AddChild(Widget(""))
	self.root:SetPosition(0,120,0)
	
    self.edit_bg = self.root:AddChild( Image() )
	self.edit_bg:SetTexture( "images/ui.xml", "textbox_long.tex" )
	self.edit_bg:SetPosition( 0,0,0)
	self.edit_bg:ScaleToSize( edit_width + edit_bg_padding, label_height )

	self.console_edit = self.root:AddChild( TextEdit( DEFAULTFONT, fontsize, "" ) )
	self.console_edit:SetPosition( 0,0,0)
	self.console_edit:SetRegionSize( edit_width, label_height )
	self.console_edit:SetHAlign(ANCHOR_LEFT)

	self.console_edit.OnTextEntered = function() self:OnTextEntered() end
	--self.console_edit:SetLeftMouseDown( function() self:SetFocus( self.console_edit ) end )
	self.console_edit:SetFocusedImage( self.edit_bg, "images/ui.xml", "textbox_long_over.tex", "textbox_long.tex" )
	self.console_edit:SetCharacterFilter( VALID_CHARS )

	self.console_edit:SetString("")
	self.history_idx = nil

	self.console_edit.validrawkeys[KEY_TAB] = true
	self.console_edit.validrawkeys[KEY_UP] = true
	self.console_edit.validrawkeys[KEY_DOWN] = true
	self.console_edit:SetAllowClipboardPaste( true )

end

return ConsoleScreen
