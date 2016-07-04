local AngryBossReminders = LibStub("AceAddon-3.0"):GetAddon("AngryBossReminders")
if not AngryBossReminders then
	print("Failed to load Boss Detection, can't find AngryBossReminders")
	return
end

local plugin = AngryBossReminders:NewModule("BossDetection", "AceEvent-3.0")
plugin.Callbacks = plugin.Callbacks or LibStub:GetLibrary("CallbackHandler-1.0"):New(plugin)

local  MYTHIC_DIFFICULTY = 16 
local encounterIDOverrides = { ["Tectus, The Living Mountain"] = 1722, ["Oregorger the Devourer"] = 1696, ["Hans'gar & Franzok"] = 1693, ["Kromog, Legend of the Mountain"] = 1713 }
local deadBosses = {}
ABRDeadBosses = deadBosses

function plugin:OnInitialize()
	self:RegisterEvent("UPDATE_INSTANCE_INFO", "CheckSavedInstanceData")
	self:RegisterEvent("ENCOUNTER_END", "EncounterEnd")
end

function plugin:OnEnable()
	RequestRaidInfo()
end

function plugin:IsBossKilled(encounterID)
	local difficultyID = select(3, GetInstanceInfo())
	if self:IsInLockedRaid(difficultyID) then
		return deadBosses[difficultyID] and deadBosses[difficultyID][encounterID]
	else
		return false
	end
end

function plugin:IsInLockedRaid(difficultyID)
	if not difficultyID then
		difficultyID = select(3, GetInstanceInfo())
	end
	return difficultyID and difficultyID == MYTHIC_DIFFICULTY
end

function plugin:EncounterEnd(event, encounterID, encounterName, difficultyID, raidSize, endStatus)
	if endStatus == 1 and self:IsInLockedRaid(difficultyID) then
		if not deadBosses[ difficultyID ] then deadBosses[ difficultyID ] = {} end
		deadBosses[ difficultyID ][ encounterID ] = true
		self.Callbacks:Fire("OnBossKill", encounterID)
	end
end

function plugin:GetEncounterId(instanceName, bossName)
	if encounterIDOverrides[ bossName ] then
		return encounterIDOverrides[ bossName ]
	end
	for _, instance in pairs(AngryBossReminders.Instances) do
		if instanceName == EJ_GetInstanceInfo(instance.journalID) then
			for _, boss in ipairs(instance.bosses) do
				if bossName == EJ_GetEncounterInfo( boss.journalID ) then
					return boss.encounterID
				end
			end
		end
	end
end

function plugin:CheckSavedInstanceData()
	wipe(deadBosses)
	for i = 1, GetNumSavedInstances() do
		local instanceName, raidID, reset, difficultyID, locked, extended, instanceIDMostSig, isRaid, maxPlayers, difficultyName, numEncounters, encounterProgress = GetSavedInstanceInfo(i)
		
		if difficultyID == MYTHIC_DIFFICULTY and locked then
			if not deadBosses[ difficultyID ] then deadBosses[ difficultyID ] = {} end
			local index = 1
			local bossName, _, dead = GetSavedInstanceEncounterInfo(i, index)
			while bossName do
				if dead then
					local encounterID = self:GetEncounterId(instanceName, bossName)
					if encounterID then
						deadBosses[ difficultyID ][ encounterID ] = true
					end
				end

				index = index + 1
				bossName, _, dead = GetSavedInstanceEncounterInfo(i, index)
		  end
		end
	end
end
