AngryBossReminders = LibStub("AceAddon-3.0"):NewAddon("AngryBossReminders", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
local ABR = AngryBossReminders

BINDING_HEADER_AngryBossReminders = "Angry Boss Reminders"
_G["BINDING_NAME_CLICK AngryBossRemindersButton1:LeftButton"] = "Automate talent/glyph/gear switch"

local AngryBossReminders_Version = 'v0.6'
local BossDetection

local currentlyEditing = -1
local currentlyEditingIndex = -1
local currentlyEditingSpec = nil
local itemSlots = { 'HeadSlot', 'NeckSlot', 'ShoulderSlot', 'BackSlot', 'ChestSlot', 'WristSlot', 'HandsSlot', 'WaistSlot', 'LegsSlot', 'FeetSlot', 'Finger0Slot', 'Finger1Slot', 'Trinket0Slot', 'Trinket1Slot', 'MainHandSlot', 'SecondaryHandSlot' }

local NUM_TALENT_COLS = 3
local NUM_TALENT_TIERS = 7

local unknownTexture = "Interface\\Icons\\INV_Misc_QuestionMark"

local baseButtonSize = 64

ABR.Instances = {
  {  -- The Emerald Nightmare
    type = "raid",
    journalID = 768,
    mapID = 1094,
    bosses = {
      {  -- Nythendra
        journalID = 1703,
        encounterID = 1853,
        coords = { 0.44, 0.333, 1, 1, 1 }
      },
      {  -- Il'gynoth, Heart of Corruption
        journalID = 1738,
        encounterID = 1873,
        coords = { 0, 0, 1, 1, 4 }
      },
      {  -- Elerethe Renferal
        journalID = 1744,
        encounterID = 1876,
        coords = { 0, 0, 0.74, 0.84, 3 }
      },
      {  -- Ursoc
        journalID = 1667,
        encounterID = 1841,
        coords = { 0, 0, 1, 0.6, 10 }
      },
      {  -- Dragons of Nightmare
        journalID = 1704,
        encounterID = 1854,
        coords = { 0, 0, 1, 1, 5 }
      },
      {  -- Cenarius
        journalID = 1750,
        encounterID = 1877,
        coords = { 0, 0, 1, 0.48, 11 }
      },
      {  -- Xavius
        journalID = 1726,
        encounterID = 1864,
        coords = { 0, 0, 1, 1, 12 }
      },
    }
  },
  {  -- The Nighthold
    type = "raid",
    journalID = 786,
    mapID = 1088,
    bosses = {
      {  -- Skorpyron
        journalID = 1706,
        encounterID = 1849,
        coords = { 0.27, 0.58, 0.35, 0.68, 1 }
      },
      {  -- Chronomatic Anomaly
        journalID = 1725,
        encounterID = 1865,
        coords = { 0.47, 0.26, 1, 0.58, 1 }
      },
      {  -- Trilliax
        journalID = 1731,
        encounterID = 1867,
        coords = { 0.37, 0.13, 0.46, 0.26, 1 }
      },
      {  -- Spellblade Aluriel
        journalID = 1751,
        encounterID = 1871,
        coords = { 0.32, 0.28, 0.43, 0.45, 3 }
      },
      {  -- Tichondrius
        journalID = 1762,
        encounterID = 1862,
        coords = { 0.21, 0.349, 0.48, 0.75, 5 }
      },
      {  -- Krosus  -- Boss is out of map bounds (pull range should reach into map)
        journalID = 1713,
        encounterID = 1842,
        coords = { 0.74, 0.90, 1, 1, 3 }
      },
      {  -- High Botanist Tel'arn
        journalID = 1761,
        encounterID = 1886,
        coords = { 0.466, 0, 0.63, 0.6, 4 }
      },
      {  -- Star Augur Etraeus  -- TODO: Improve coordinates
        journalID = 1732,
        encounterID = 1863,
        coords = { 0, 0, 0.50, 0.58, 6 }
      },
      {  -- Grand Magistrix Elisandre
        journalID = 1743,
        encounterID = 1872,
        coords = { 0, 0, 1, 1, 7 }
      },
      {  -- Gul'dan
        journalID = 1737,
        encounterID = 1866,
        coords = { 0, 0, 1, 1, 9 }
      },
    }
  },
  {  -- Legion dungeons
    type = "group",
    name = "Legion Dungeons",
    maps = {
      {  -- Blackrook Hold
        journalID = 740,
        mapID = 1081
      },
      {  -- Court of Stars
        journalID = 800,
        mapID = 1087
      },
      {  -- Darkheart Thicket
        journalID = 762,
        mapID = 1067
      },
      {  -- Eye of Azshara
        journalID = 716,
        mapID = 1046
      },
      {  -- Halls of Valor
        journalID = 721,
        mapID = 1041
      },
      {  -- Neltharion's Lair
        journalID = 767,
        mapID = 1065
      },
      {  -- The Arcway
        journalID = 726,
        mapID = 1079
      },
      {  -- Maw of Soul
        journalID = 727,
        mapID = 1042
      },
      {  -- The Violet Hold
        journalID = 777,
        mapID = 1066
      },
      {  -- Vault of the Wardens
        journalID = 707,
        mapID = 1045
      },
    },
  },
  {  -- Outland Timewalking
    type = "group",
    name = "Outland Timewalking Dungeons",
    maps = {
      {  -- The Arcatraz
        journalID = 254,
        mapID = 731
      },
      {  -- The Black Morass
        journalID = 255,
        mapID = 733
      },
      {  -- Mana-Tombs
        journalID = 250,
        mapID = 732
      },
      {  -- The Shattered Halls
        journalID = 259,
        mapID = 710
      },
      {  -- Slave Pens
        journalID = 260,
        mapID = 728
      },
      {  -- Magister's Terrace
        journalID = 249,
        mapID = 798
      },
    }
  },
  {  -- Northrend Timewalking
    type = "group",
    name = "Northrend Timewalking Dungeons",
    maps = {
    }
  }
}

function ABR:Error(text) self:Print( RED_FONT_COLOR_CODE.."Error:|r "..text ) end

ABR.missing = {}

local function ItemStringFromLink(link)
	return link and strmatch(link, '(item:[0-9:]+)')
end

local function MissingButton_PreClick(button, mbutton, down)
	if InCombatLockdown() then return end
	
	local missing = ABR.missing[ button.ABRIndex ]

	if not missing then
		button:SetAttribute("type", "macro")
		button:SetAttribute("macrotext", "/run AngryBossReminders:Print('All set!')")
	elseif missing[1] == "set" then
		button:SetAttribute("type", "macro")
		button:SetAttribute("macrotext", string.format("/run UseEquipmentSet('%s')", missing[2]))
	elseif missing[1] == "talent" then
		local tier = missing[2]
		local column = missing[3]
		local old_column = 0
		local talentID, name, texture, selected, available = GetTalentInfo(tier, column, GetActiveSpecGroup())
		for iter_column = 1, NUM_TALENT_COLS do
			local _, _, _, iter_selected, _ = GetTalentInfo(tier, iter_column, GetActiveSpecGroup())
			if iter_selected then
				old_column = iter_column
				break
			end
		end
		local number = (tier-1)*3+column
		button:SetAttribute("type", "macro")
		if old_column > 0 then
			local found = false
			for index = 1, STATICPOPUP_NUMDIALOGS, 1 do
				local frame = _G["StaticPopup"..index]
				if frame and frame:IsShown() then
					found = true
				end
			end
			if found then
				button:SetAttribute("macrotext", "/run AngryBossReminders:Print('You must close all popup dialogs to use automatic talent selection.')")
			else
				if PlayerTalentFrame then
					button:SetAttribute("macrotext", string.format([=[
/click PlayerTalentFrameTab2
/click PlayerSpecTab%d
/click PlayerTalentFrameTalentsTalentRow%dTalent%d
/click StaticPopup1Button1
/run AngryBossReminders:LearnTalent(%d)
]=], GetActiveSpecGroup(), tier, column, talentID))
				else
					button:SetAttribute("macrotext", string.format([=[
/run TalentFrame_LoadUI()
/run ShowUIPanel(PlayerTalentFrame)
/click PlayerTalentFrameTab2
/click PlayerSpecTab%d
/click PlayerTalentFrameTalentsTalentRow%dTalent%d
/click StaticPopup1Button1
/run HideUIPanel(PlayerTalentFrame)
/run AngryBossReminders:LearnTalent(%d)
]=], GetActiveSpecGroup(), tier, column, talentID))
				end
			end
		else
			button:SetAttribute("macrotext", string.format("/run LearnTalent(%d)", talentID))
		end
	elseif missing[1] == "item" then
		local slotName, itemStrirng = missing[2], missing[3]

		button:SetAttribute("type", "macro")
		button:SetAttribute("macrotext", string.format("/equipslot %d %s", GetInventorySlotInfo(slotName), itemStrirng))
	end
end

local function MissingButton_OnEnter(button)
	local missing = ABR.missing[ button.ABRIndex ]
	local text = "Unknown"

	if missing[1] == "talent" then
		text = select(2, GetTalentInfo(missing[2], missing[3], GetActiveSpecGroup()))
	elseif missing[1] == "item" then
		text = GetItemInfo(missing[3])
	elseif missing[1] == "set" then
		text = "Equipment Set: "..missing[2]
	end

	GameTooltip:SetOwner(button, "ANCHOR_BOTTOMRIGHT")
	GameTooltip:SetText(text)
	GameTooltip:Show()
end

local function MissingButton_OnLeave(button)
	GameTooltip:Hide()
end

function ABR:LearnTalentDelayed(number) LearnTalent(number) end
function ABR:LearnTalent(number) self:ScheduleTimer('LearnTalentDelayed', 0.5, number) end

local function Frame_SaveState(frame)
	local fX, fY = frame:GetCenter()
	local fS = frame:GetEffectiveScale()
	fX, fY = fX*fS, fY*fS

	local uiX, uiY = frame:GetParent():GetCenter()
	local uiS = frame:GetParent():GetEffectiveScale()
	uiX, uiY = uiX*uiS, uiY*uiS

	AngryBossReminders_State.x, AngryBossReminders_State.y = (fX - uiX)/fS, (fY - uiY)/fS

	AngryBossReminders_State.size = frame:GetWidth()
end

local function Frame_RestoreState(frame)
	local x = AngryBossReminders_State.x or 0
	local y = AngryBossReminders_State.y or 0
	frame:ClearAllPoints()
	frame:SetPoint("CENTER", x, y)

	local size = AngryBossReminders_State.size or baseButtonSize
	frame:SetSize(size, size)
end

local function DragHandle_MouseDown(drag)
	local frame = drag:GetParent():GetParent()
	
	local fX, fY = frame:GetCenter()
	local fS = frame:GetEffectiveScale()
	fX, fY = fX*fS, fY*fS

	local cX, cY = GetCursorPosition()
	local offsetX, offsetY = frame:GetWidth() * fS / 2 - ( cX - fX ), frame:GetHeight() * fS / 2 - ( fY - cY )

	local min = 32
	local max = 128

	frame:SetScript("OnUpdate", function(frame)
		local cX, cY = GetCursorPosition()
		local fS = frame:GetEffectiveScale()

		local new = math.max(cX - fX + offsetX, fY - cY + offsetY) * 2 / fS
		new = math.min(max, math.max(new, min))
		
		frame:SetSize(new, new)
		ABR:UpdateDisplay()
	end)
end
local function DragHandle_MouseUp(drag)
	local frame = drag:GetParent():GetParent()
	frame:SetScript("OnUpdate", nil)
	Frame_SaveState(frame)
end

local function Mover_MouseDown(mover)
	local frame = mover:GetParent()

	local cX, cY = GetCursorPosition()
	local iX, iY = frame:GetCenter()
	local iS = frame:GetEffectiveScale()
	iX, iY = iX*iS, iY*iS


	local uiX, uiY = frame:GetParent():GetCenter()
	local uiS = frame:GetParent():GetEffectiveScale()
	uiX, uiY = uiX*uiS, uiY*uiS

	local xOffset, yOffset = (iX - cX), (iY - cY)

	local stickyness = 7

	frame:SetScript("OnUpdate", function(frame)
		local cX, cY = GetCursorPosition()
		local fS = frame:GetEffectiveScale()

		local frameX, frameY = cX + xOffset, cY + yOffset

		if frameX <= uiX + stickyness and frameX >= uiX - stickyness then
			frameX = uiX
		end
		if frameY <= uiY + stickyness and frameY >= uiY - stickyness then
			frameY = uiY
		end

		frame:ClearAllPoints()
		frame:SetPoint("CENTER", (frameX - uiX)/fS, (frameY - uiY)/fS)
	end)
end
local function Mover_MouseUp(mover)
	local frame = mover:GetParent()
	frame:SetScript("OnUpdate", nil)
	Frame_SaveState(frame)
end

local function CreateABRFrame()
	if not AngryBossRemindersFrame then
		local frame = CreateFrame("Frame", "AngryBossRemindersFrame", UIParent)
		Frame_RestoreState(frame)
		frame:SetClampedToScreen(true)
		frame:Show()

		local label = frame:CreateFontString("AngryBossRemindersLabel")
		label:SetFontObject("GameFontNormalLarge")
		label:SetPoint("BOTTOM", frame, "TOP", 0, 10)
		label:SetJustifyH("CENTER")
		label:Hide()

		local mover = CreateFrame("Frame", nil, frame)
		mover:SetAllPoints(frame)
		mover:SetFrameLevel( 10 )
		mover:EnableMouse(true)
		mover:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background" })
		mover:SetBackdropColor( 0.616, 0.149, 0.114, 0.9)
		mover:SetScript("OnMouseDown", Mover_MouseDown)
		mover:SetScript("OnMouseUp", Mover_MouseUp)
		mover:Hide()
		frame.mover = mover

		local moverlabel = mover:CreateFontString()
		moverlabel:SetFontObject("GameFontNormal")
		moverlabel:SetJustifyH("CENTER")
		moverlabel:SetPoint("CENTER", 0, 0)
		moverlabel:SetText("Angry\nBoss\nReminders")

		local drag = CreateFrame("Frame", nil, mover)
		drag:SetFrameLevel(mover:GetFrameLevel() + 10)
		drag:SetWidth(16)
		drag:SetHeight(16)
		drag:SetPoint("BOTTOMRIGHT", 0, 0)
		drag:EnableMouse(true)
		drag:SetScript("OnMouseDown", DragHandle_MouseDown)
		drag:SetScript("OnMouseUp", DragHandle_MouseUp)
		drag:SetAlpha(0.5)
		local dragtex = drag:CreateTexture(nil, "OVERLAY")
		dragtex:SetTexture("Interface\\AddOns\\AngryBossReminders\\Textures\\draghandle")
		dragtex:SetWidth(16)
		dragtex:SetHeight(16)
		dragtex:SetBlendMode("ADD")
		dragtex:SetPoint("CENTER", drag)
	end
	return AngryBossRemindersFrame
end

local function MissingButton_PostClick(button)
	if InCombatLockdown() then return end
	text = string.format("/run AngryBossReminders:Error('You must leave combat first')")
	button:SetAttribute("type", "macro")
	button:SetAttribute("macrotext", text)
	button:SetAttribute("slot", nil)
end

local function GetMissingButton(index)
	return _G['AngryBossRemindersButton'..index]
end

local function CreateMissingButton(index)
	CreateABRFrame()
	
	local button = CreateFrame("Button", "AngryBossRemindersButton"..index, AngryBossRemindersFrame, "SecureActionButtonTemplate,UIPanelButtonTemplate")
	if index == 1 then
		button:SetAllPoints(AngryBossRemindersFrame)
	else
		button:SetSize(32, 32)
	end

	button:SetAttribute("type2", "macro")
	button:SetAttribute("macrotext2", string.format("/run AngryBossReminders:IgnoreMissing(%d)", index))

	button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	button.ABRIndex = index
	button:SetPoint("CENTER",0,0)
	button:SetScript("PreClick", MissingButton_PreClick)
	button:SetScript("PostClick", MissingButton_PostClick)
	button:SetScript("OnEnter", MissingButton_OnEnter)
	button:SetScript("OnLeave", MissingButton_OnLeave)
	MissingButton_PostClick(button)
	button:SetNormalTexture(unknownTexture)
	button:Hide()
	
	local highlight = button:CreateTexture(nil, "HIGHLIGHT")
	highlight:SetAllPoints(button)
	highlight:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-Tab-Highlight")
	highlight:SetTexCoord(0, 1, 0.23, 0.77)
	highlight:SetBlendMode("ADD")
	
	return button
end

local function GetOrCreateMissingButton(index)
	return _G['AngryBossRemindersButton'..index] or CreateMissingButton(index)
end

function ABR:ToggleMover()
	local frame = CreateABRFrame()
	local mover = frame.mover
	if mover:IsShown() then
		mover:Hide()
	else
		mover:Show()
	end
end


local updateDisplayNeeded = false
function ABR:UpdateDisplay()
	if InCombatLockdown() then
		updateDisplayNeeded = true
		return
	end

	CreateABRFrame()
	
	local buttonSize = math.max(24, AngryBossRemindersFrame:GetHeight() / 2)
	local buttonSpacing = 6
	local perRow = 4

	for index, missing in ipairs(self.missing) do
		local button = GetOrCreateMissingButton(index)
		local texture
		
		button:Hide()
		if missing[1] == "talent" then
			texture = select(3, GetTalentInfo(missing[2], missing[3], GetActiveSpecGroup()))
		elseif missing[1] == "item" then
			texture = select(10, GetItemInfo(missing[3]))
		elseif missing[1] == "set" then
			texture = select(1, GetEquipmentSetInfoByName(missing[2]))
			if texture then texture = "Interface\\Icons\\"..texture end
		end
		
		if not texture then texture = unknownTexture end
		
		if index > 1 then
			button:SetSize(buttonSize, buttonSize)
			button:ClearAllPoints()
			
			local col = (index - 2) % perRow
			local row = math.floor( (index - 2) / perRow )

			if col == 0 then
				local offset = math.min(#self.missing - index, perRow - 1) / (perRow - 1)
				button:SetPoint("TOP", GetMissingButton( 1 ), "BOTTOM", (buttonSize + buttonSpacing) * -offset * (perRow - 1) / 2, (buttonSize + buttonSpacing) * -row - buttonSpacing )
			else
				button:SetPoint("LEFT", GetMissingButton( index-1 ), "RIGHT", buttonSpacing, 0)
			end
		end
		
		button:SetNormalTexture( texture )
		button:Show()
	end
	
	local index = #self.missing + 1
	local button = GetMissingButton( index )
	while button do
		button:ClearAllPoints()
		button:Hide()
	
		index = index + 1
		button = GetMissingButton( index )
	end

	if #self.missing > 0 then
		local path, _, flags = AngryBossRemindersLabel:GetFont()
		local ratio = AngryBossRemindersFrame:GetHeight() / baseButtonSize

		AngryBossRemindersLabel:SetFont(path, math.floor(15*ratio), flags)
		
		AngryBossRemindersLabel:SetText( string.format("Needed for %s", self:ActiveBossName()) )
		AngryBossRemindersLabel:Show()
	elseif AngryBossRemindersLabel then
		AngryBossRemindersLabel:Hide()
	end
end

function ABR:HideDisplay()
	if AngryBossRemindersFrame then
		AngryBossRemindersFrame:Hide()
	end
end

function ABR:ShowDisplay()
	if AngryBossRemindersFrame then
		AngryBossRemindersFrame:Show()
	end
end

function ABR:ActiveBossName()
	return self.journalID and (type(self.journalID) == "number" and EJ_GetEncounterInfo( self.journalID ) or type(self.journalID) == "string" and self.journalID) or ""
end

function ABR:CheckGlyphsTalentsGear()
	wipe(self.missing)
	if self.journalID then
		local specID = GetSpecializationInfo( GetSpecialization() or 1 )
    if specID then
      for tier = 1, NUM_TALENT_TIERS do
        local selectedTalent = self:GetConfig( "talent"..tier, self.journalID, specID ) or self:GetConfig( "talent"..tier, -1, specID )
        local ignoredTalent = self:GetIgnore( "talent"..tier, self.journalID, specID )

        if selectedTalent and ignoredTalent ~= selectedTalent then
          local talentID, name, texture, selected, available = GetTalentInfo(tier, selectedTalent, GetActiveSpecGroup())

          if not selected then
            table.insert(self.missing, {"talent", tier, selectedTalent})
          end
        end
      end
    
      for _, slotName in ipairs(itemSlots) do
        local inventoryID = GetInventorySlotInfo(slotName)
        local currentItem = ItemStringFromLink(GetInventoryItemLink("player", inventoryID))
        local selectedItem = ItemStringFromLink(self:GetConfig( slotName, self.journalID, specID ) or self:GetConfig( slotName, -1, specID ))
        local ignoredItem = ItemStringFromLink(self:GetIgnore( slotName, self.journalID, specID ))
        
        if selectedItem and (not currentItem or selectedItem ~= currentItem) and ignoredItem ~= selectedItem then
          table.insert(self.missing, {"item", slotName, selectedItem })
        end
      end

      local currentSet = self:GetConfig("set", self.journalID, specID) or self:GetConfig("set", -1, specID)
      local ignoredSet = ItemStringFromLink(self:GetIgnore( slotName, self.journalID, specID ))
      if currentSet and ignoredSet ~= currentSet then
        local icon, _, _, numItems, numEquipped, _, _, _ = GetEquipmentSetInfoByName(currentSet)
        if icon and numEquipped < numItems then
          table.insert(self.missing, {"set", currentSet })
        end
      end
    end
  end
	self:UpdateDisplay()
end

function ABR:ActivateBoss(journalID)
	if self.journalID ~= journalID then
		self.journalID = journalID
		self:CheckGlyphsTalentsGear()
	end
end

function ABR:DeactivateBoss()
	if self.journalID then
		self.journalID = nil
		self:CheckGlyphsTalentsGear()
	end
end

function ABR:GetPlayerPosition()
	local mapID, floor = GetCurrentMapAreaID(), GetCurrentMapDungeonLevel()
	SetMapToCurrentZone()
	local playerMapID = GetCurrentMapAreaID()
	local playerX, playerY = GetPlayerMapPosition('player')
	local playerFloor = GetCurrentMapDungeonLevel()
	SetMapByID(mapID)
	if floor then SetDungeonMapLevel(floor) end

	return playerMapID, playerFloor, playerX, playerY
end

function ABR:CheckLocation()
	local playerMapID, playerFloor, playerX, playerY = self:GetPlayerPosition()

	for _, instance in ipairs(self.Instances) do
    if instance.type == "group" then
      for _, dungeon in ipairs(instance.maps) do
        if playerMapID == dungeon.mapID then          
          self:ActivateBoss(instance.name)
          return
        end
      end
      
		elseif instance.type == "raid" then
      if playerMapID == instance.mapID then
        for _, boss in ipairs(instance.bosses) do
          local x1, y1, x2, y2, floor = unpack( boss.coords )
          if (playerFloor == nil or playerFloor == floor) and playerX >= x1 and playerY >= y1 and playerX < x2 and playerY < y2 then
            if not (BossDetection:IsBossKilled(boss.encounterID) and BossDetection:IsInLockedRaid()) then
              self:ActivateBoss(boss.journalID)
              return
            end
          end
        end
      end
      
		end
	end
	self:DeactivateBoss()
end

local specializationOptions = nil
local function SpecializationOptions()
	if specializationOptions == nil then
		local ret = { }
		local found = false
	
		for i = 1, 4 do
			local specID, name = GetSpecializationInfo(i)
			if specID then
				ret[specID] = name
				found = true
			end
		end
		if found then
			specializationOptions = ret
		end
	end
	return specializationOptions or {}
end

local editingOptions = nil
local function EditingOptions()
	if editingOptions == nil then
		local ret = { }
		local found = false
	
		for index1, instance in ipairs(ABR.Instances) do
      if instance.type == "group" then
        ret[index1*100] = instance.name
        found = true
        
      elseif instance.type == "raid" then
        for index2, boss in ipairs(instance.bosses) do
          ret[index1*100 + index2] = EJ_GetEncounterInfo( boss.journalID )
          found = true
        end
        
      end
		end
		if found then
			ret[-1] = "Default"
			editingOptions = ret
		end
	end
	return editingOptions or {}
end

local talentOptions = {}
local function TalentOptions(talent_tier)
	if type(talent_tier) == "table" then
		talent_tier = tonumber(strsub(talent_tier[#talent_tier], -1))
	end
	if talentOptions[talent_tier] == nil then
		local ret = { }
		local found = false

		for column = 1, NUM_TALENT_COLS do
			local talentID, name, texture, selected, available = GetTalentInfo(talent_tier, column, GetActiveSpecGroup())
			if name then
				ret[column] = name
				found = true
			end
		end
		if found then
			ret[-1] = ""
			talentOptions[talent_tier] = ret
		end
	end
	return talentOptions[talent_tier] or {}
end

function ABR:IgnoreMissing(index)
	if not self.journalID then self:Error("Can't ignore, no boss is currently activated") end
	if not #self.missing then self:Error("Can't ignore, nothing is missing") end
	if not self.missing[index] then self:Error("Can't ignore, index doesn't exist") end

	local missing = self.missing[index]

	local name

	if missing[1] == 'talent' then
		local talentID, talentName = GetTalentInfo(missing[2], missing[3], GetActiveSpecGroup())
		self:SetIgnore('talent'..missing[2], missing[3], self.journalID, -1)
		name = talentName
	elseif missing[1] == 'item' then
		self:SetIgnore(missing[2], missing[3], self.journalID, -1)
		name = GetItemInfo(missing[3])
	elseif missing[1] == 'set' then
		self:SetIgnore('set', missing[2], self.journalID, -1)
		name = GetItemInfo(missing[3])
	end

	self:Print(string.format('Temporarily ignoring %s for %s', name, self:ActiveBossName()))
end

ABR.ignore = {}
function ABR:SetIgnore(key, value, encounterID, specializationID)
	if specializationID == -1 then specializationID = GetSpecializationInfo( GetSpecialization() or 1 ) end
	if not self.ignore[specializationID] then self.ignore[specializationID] = {} end
	if not self.ignore[specializationID][encounterID] then self.ignore[specializationID][encounterID] = {} end
	
	self.ignore[specializationID][encounterID][key] = value
end

function ABR:GetIgnore(key, encounterID, specializationID)
	if not self.ignore[specializationID] then
    self.ignore[specializationID] = {}
  end
	if specializationID == -1 then
    specializationID = GetSpecializationInfo( GetSpecialization() or 1 )
  end
	if not self.ignore[specializationID][encounterID] then
    self.ignore[specializationID][encounterID] = {}
  end
	return self.ignore[specializationID][encounterID][key]
end

function ABR:GetConfig(key, encounterID, specializationID)
	if type(key) == "table" then key = key[#key] end
	if not encounterID then encounterID = currentlyEditing end
	if not specializationID then specializationID = currentlyEditingSpec end
	
	ABR:EnsureConfig(specializationID, encounterID)

	return AngryBossReminders_Config[specializationID][encounterID][key]
end

function ABR:SetConfig(key, value, encounterID, specializationID)
	if type(key) == "table" then key = key[#key] end
	if not encounterID then encounterID = currentlyEditing end
	if value == -1 or value == "" then value = nil end
	if not specializationID then specializationID = currentlyEditingSpec end

	ABR:EnsureConfig(specializationID, encounterID)
	AngryBossReminders_Config[specializationID][encounterID][key] = value
end


local equipmentSetOptions = nil
local function EquipmentSetOptions()
	if equipmentSetOptions == nil then
		local ret = { "" }

		for i = 1, GetNumEquipmentSets() do
			local name, icon, setID, isEquipped, numItems, numEquipped, numInventory, numMissing, numIgnored = GetEquipmentSetInfo(i)
			table.insert(ret, name)
		end

		equipmentSetOptions = ret
	end
	return equipmentSetOptions or {}
end

function ABR:GetEquipmentSet(key, encounterID, specializationID)
	local val = self:GetConfig(key, encounterID, specializationID)
	local ret = nil
	for i = 1, GetNumEquipmentSets() do
		local name, icon, setID, isEquipped, numItems, numEquipped, numInventory, numMissing, numIgnored = GetEquipmentSetInfo(i)
		if name == val then
			ret = i + 1
		end
	end
	return ret
end

function ABR:SetEquipmentSet(key, value, encounterID, specializationID)
	local name, icon, setID, isEquipped, numItems, numEquipped, numInventory, numMissing, numIgnored = GetEquipmentSetInfo(value - 1)
	return self:SetConfig(key, name, encounterID, specializationID)
end

function ABR:EnsureConfig(specializationID, encounterID)
	if not AngryBossReminders_Config[specializationID] then
		AngryBossReminders_Config[specializationID] = {}
	end
	if not AngryBossReminders_Config[specializationID][encounterID] then
		AngryBossReminders_Config[specializationID][encounterID] = {}
	end
end

function ABR:RestoreDefaults()
	AngryBossReminders_Config = {}
	LibStub("AceConfigRegistry-3.0"):NotifyChange("AngryBossReminders")
end

local blizOptionsPanel
function ABR:OnInitialize()
	if AngryBossReminders_Config == nil then
		AngryBossReminders_Config = {}
	end
	if AngryBossReminders_State == nil then
		AngryBossReminders_State = {}
	end

	local ver = AngryBossReminders_Version
	if ver:sub(1,1) == "@" then ver = "dev" end

	local options = {
		name = "Angry Boss Reminders "..ver,
		handler = self,
		type = "group",
		args = {

			activate = {
				type = "execute",
				name = "Activate Boss",
				hidden = true,
				func = function(info)
					self:ActivateBoss( tonumber(strmatch(info.input, '^activate%s+(%d+)%s*$')) )
				end
			},
			deactivate = {
				type = "execute",
				name = "Deactivate Boss",
				hidden = true,
				func = function()
					self:DeactivateBoss()
				end
			},


			lock = {
				type = "execute",
				name = "Toggle Lock",
				desc = "Shows/hides the display mover for moving/resizing",
				order = 1,
				func = function()
					self:ToggleMover()
				end
			},
			resetposition = {
				type = "execute",
				order = 2,
				name = "Reset Position",
				desc = "Resets position for the display",
				hidden = true,
				cmdHidden = false,
				func = function()
					AngryBossReminders_State = {}
					Frame_RestoreState( CreateABRFrame() )
				end
			},

			defaults = {
				type = "execute",
				name = "Restore Defaults",
				desc = "Restore configuration values to their default settings",
				order = 98,
				hidden = true,
				cmdHidden = false,
				confirm = true,
				func = function()
					self:RestoreDefaults()
				end
			},
			help = {
				type = "execute",
				order = 99,
				name = "Help",
				hidden = true,
				func = function()
					LibStub("AceConfigCmd-3.0").HandleCommand(self, "ABR", "AngryBossReminders", "")
				end
			},

			editing = { type = "header", order = 10, name = "Currently Editing" },
			editingBoss = {
				type = "select",
				order = 11,
				cmdHidden = true,
				name = "Boss",
				width = "double",
				values = EditingOptions,
				get = function(info) return currentlyEditingIndex end,
				set = function(info, val)
					currentlyEditingIndex = tonumber(val)
					if val == -1 then
						currentlyEditing = currentlyEditingIndex
					else
						local index1 = math.floor(currentlyEditingIndex / 100)
						local index2 = currentlyEditingIndex % 100
            
            local instance = self.Instances[index1]
            if instance.type == "group" then
              currentlyEditing = instance.name
            elseif instance.type == "raid" then
              currentlyEditing = instance.bosses[index2].journalID
            end
					end

					LibStub("AceConfigRegistry-3.0"):NotifyChange("AngryBossReminders")
				end
			},
			editingSpec = {
				type = "select",
				order = 12,
				cmdHidden = true,
				name = "Spec",
				values = SpecializationOptions,
				get = function(info) return currentlyEditingSpec end,
				set = function(info, val)
					currentlyEditingSpec = val
					LibStub("AceConfigRegistry-3.0"):NotifyChange("AngryBossReminders")
				end
			},
		}
	}
	
	options.args["talents"] = { type = "header", order = 20, name = "Talents" }
	for i = 1, NUM_TALENT_TIERS do
		options.args["talent"..i] = {
			type = "select",
			order = 20 + i,
			cmdHidden = true,
			name = "Level "..CLASS_TALENT_LEVELS.DEFAULT[i],
			values = TalentOptions,
			handler = self,
			get = 'GetConfig',
			set = 'SetConfig',
		}
	end

	options.args["gear"] = { type = "header", order = 40, name = "Gear" }

	options.args["set"] = {
		type = "select",
		order = 41,
		cmdHidden = true,
		name = "Equipment Set",
		handler = self,
		values = EquipmentSetOptions,
		get = 'GetEquipmentSet',
		set = 'SetEquipmentSet',
	}

	for i, slot in ipairs(itemSlots) do
		options.args[slot] = {
			name = _G[strupper(slot).."_UNIQUE"] or _G[strupper(slot)],
			type = 'input',
			control = 'ABRActionSlotItem',
			order = 41 + i,
			cmdHidden = true,
			width = 'half',
			handler = self,
			get = 'GetConfig',
			set = 'SetConfig',
		}
	end
	
	self:RegisterChatCommand("abr", "ChatCommand")
	self:RegisterChatCommand("angrybossreminders", "ChatCommand")
	LibStub("AceConfig-3.0"):RegisterOptionsTable("AngryBossReminders", options)
	blizOptionsPanel = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("AngryBossReminders", "Angry Boss Reminders")
	blizOptionsPanel.default = function() self:RestoreDefaults() end
end

function ABR:OnEnable()
	BossDetection = self:GetModule("BossDetection")
	BossDetection.RegisterCallback(self, "OnBossKill", "CheckLocation")

	currentlyEditingSpec = GetSpecializationInfo( GetSpecialization() or 1 )
	LibStub("AceConfigRegistry-3.0"):NotifyChange("AngryBossReminders")
	
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "CheckZone")
	self:RegisterEvent("PLAYER_TALENT_UPDATE", "CheckGlyphsTalentsGear")
	self:RegisterEvent("UNIT_INVENTORY_CHANGED", "CheckGlyphsTalentsGear")
	self:RegisterEvent("EQUIPMENT_SETS_CHANGED", "ChangedEquipmentSets")
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", "ChangedSpecialization")
	self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", "ChangedSpecialization")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "EnterCombat")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "LeaveCombat")
	self:CheckZone()
end

function ABR:EnterCombat()
	self:HideDisplay()
end

function ABR:LeaveCombat()
	if updateDisplayNeeded then
		self:UpdateDisplay()
		updateDisplayNeeded = false
	end
	self:ShowDisplay()
end

function ABR:ChangedEquipmentSets()
	equipmentSetOptions = nil
	self:CheckGlyphsTalentsGear()
	LibStub("AceConfigRegistry-3.0"):NotifyChange("AngryBossReminders")
end

function ABR:ChangedSpecialization()
	talentOptions = {}
	currentlyEditingSpec = GetSpecializationInfo( GetSpecialization() or 1 )
	self:CheckGlyphsTalentsGear()
	LibStub("AceConfigRegistry-3.0"):NotifyChange("AngryBossReminders")
end

function ABR:ChatCommand(input)
  if not input or input:trim() == "" then
	  InterfaceOptionsFrame_OpenToCategory(blizOptionsPanel)
	  InterfaceOptionsFrame_OpenToCategory(blizOptionsPanel)
  else
	  LibStub("AceConfigCmd-3.0").HandleCommand(self, "abr", "AngryBossReminders", input)
  end
end

local locationTimer = nil
function ABR:CheckZone()
	local playerMapID, playerFloor, playerX, playerY = self:GetPlayerPosition()

	for _, instance in ipairs(self.Instances) do
    if instance.type == "raid" then
      if playerMapID == instance.mapID then
        if not locationTimer then
          locationTimer = self:ScheduleRepeatingTimer("CheckLocation", 5)
        end
        return
      end
    end
	end
	if locationTimer then
		self:CancelTimer(locationTimer)
		locationTimer = nil
	end
	self:CheckLocation()
end
