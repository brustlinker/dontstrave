local Screen = require "widgets/screen"
local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local PopupDialogScreen = require "screens/popupdialog"

local SubmittingBugReportPopup = Class(Screen, function(self)
    Screen._ctor(self, "SubmittingBugReportPopup")

    --darken everything behind the dialog
    self.black = self:AddChild(Image("images/global.xml", "square.tex"))
    self.black:SetVRegPoint(ANCHOR_MIDDLE)
    self.black:SetHRegPoint(ANCHOR_MIDDLE)
    self.black:SetVAnchor(ANCHOR_MIDDLE)
    self.black:SetHAnchor(ANCHOR_MIDDLE)
    self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.black:SetTint(0,0,0,.75)

    self.proot = self:AddChild(Widget("ROOT"))
    self.proot:SetVAnchor(ANCHOR_MIDDLE)
    self.proot:SetHAnchor(ANCHOR_MIDDLE)
    self.proot:SetPosition(0,0,0)
    self.proot:SetScaleMode(SCALEMODE_PROPORTIONAL)

    --throw up the background
    self.bg = self.proot:AddChild(Image("images/globalpanels.xml", "small_dialog.tex"))
    self.bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg:SetHRegPoint(ANCHOR_MIDDLE)
	self.bg:SetScale(1.2,1.2,1.2)

    --text
    self.text = self.proot:AddChild(Text(BUTTONFONT, 55))
    local text = STRINGS.UI.BUGREPORTSCREEN.SUBMITTING_TEXT
    self.text:SetPosition(0, 5, 0)
    self.text:SetSize(35)
    self.text:SetString(text)
    -- self.text:SetRegionSize(140, 100)
    self.text:SetHAlign(ANCHOR_LEFT)
    self.text:SetColour(1,1,1,1)

    self.time = 0
    self.progress = 0

    SetPause(true, "bugreportres")
end)

function SubmittingBugReportPopup:OnUpdate( dt )
    self.time = self.time + dt
    if self.time > 0.75 then
        self.progress = self.progress + 1
        if self.progress > 3 then
            self.progress = 1
        end

        local text = STRINGS.UI.BUGREPORTSCREEN.SUBMITTING_TEXT
        for k = 1, self.progress, 1 do
            text = text .. "."
        end
        self.text:SetString(text)
        self.time = 0
    end

    if not TheSystemService:IsBugReportRunning() then

		local title = STRINGS.UI.BUGREPORTSCREEN.SUBMIT_FAILURE_TITLE
		local text = STRINGS.UI.BUGREPORTSCREEN.SUBMIT_FAILURE_TEXT

        if TheSystemService:DidBugReportSucceed() then
			title = STRINGS.UI.BUGREPORTSCREEN.SUBMIT_SUCCESS_TITLE
			text = string.format(STRINGS.UI.BUGREPORTSCREEN.SUBMIT_SUCCESS_TEXT, TheSystemService:GetBugReportUserCode())
        end

        local popup = PopupDialogScreen(title, text,
            {
                {text=STRINGS.UI.BUGREPORTSCREEN.OK, cb = 
                    function() 
                        SetPause(false, "bugreportres")
                        TheFrontEnd:PopScreen()
                    end
                },
            }
        )

        TheFrontEnd:PopScreen()
        TheFrontEnd:PushScreen(popup)
    end
end

return SubmittingBugReportPopup
