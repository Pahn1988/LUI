-- ####################################################################################################################
-- ##### Setup and Locals #############################################################################################
-- ####################################################################################################################

---@class LUIAddon
local LUI = select(2, ...)
local L = LUI.L

---@class LUI.ExperienceBars
local module = LUI:GetModule("Experience Bars")

local SHORT_REPUTATION_NAMES = {
	L["ExpBar_ShortName_Hatred"],		-- Ha
	L["ExpBar_ShortName_Hostile"],		-- Ho
	L["ExpBar_ShortName_Unfriendly"],	-- Un
	L["ExpBar_ShortName_Neutral"],		-- Ne
	L["ExpBar_ShortName_Friendly"],		-- Fr
	L["ExpBar_ShortName_Honored"],		-- Hon
	L["ExpBar_ShortName_Revered"],		-- Rev
	L["ExpBar_ShortName_Exalted"],		-- Ex
}

local C_Reputation = C_Reputation

-- Positive chat messages establish the direction of a change; the structured
-- standing event supplies its faction ID. Do not compare its standing with
-- GetFactionDataByID: these can update at different times and use different
-- values for renown/paragon. No faction headers or reputation filters are changed.
local gainPatterns

local function MakeGainPattern(text)
	local pattern, index, argument, captures = "^", 1, 0, 0
	while index <= #text do
		local rest = text:sub(index)
		local token, position, kind = rest:match("^(%%(%d+)%$[-+ #0]*%d*%.?%d*([sdifgu]))")
		if not token then token, kind = rest:match("^(%%[-+ #0]*%d*%.?%d*([sdifgu]))") end
		if token then
			argument = argument + 1
			local number = tonumber(position) or argument
			if number == 1 and kind == "s" then
				pattern = pattern .. "(.+)"
				captures = captures + 1
			else
				pattern = pattern .. ".-"
			end
			index = index + #token
		elseif rest:sub(1, 2) == "%%" then
			pattern = pattern .. "%%"
			index = index + 2
		else
			pattern = pattern .. text:sub(index, index):gsub("(%W)", "%%%1")
			index = index + 1
		end
	end
	if captures == 1 then return pattern .. "$" end
end

local function GetGainFaction(message)
	if issecretvalue(message) or type(message) ~= "string" then return end
	if not gainPatterns then
		gainPatterns = {}
		-- Blizzard provides localized formats, including account-wide and bonus
		-- variants. Only INCREASED messages qualify; losses and rank notices do not.
		for key, value in pairs(_G) do
			if type(key) == "string" and key:match("^FACTION_STANDING_INCREASED")
				and type(value) == "string" then
				local pattern = MakeGainPattern(value)
				if pattern then gainPatterns[#gainPatterns + 1] = pattern end
			end
		end
	end
	for _, pattern in ipairs(gainPatterns) do
		local name = message:match(pattern)
		if name then return name end
	end
end

function module:ResetAutoReputation()
	if self.autoReputationTimer then self.autoReputationTimer:Cancel() end
	self.autoReputationTimer = nil
	self.autoReputationBatch = nil
end

local function AddFaction(batch, data)
	if not data or issecretvalue(data.factionID) or issecretvalue(data.name) then return end
	if type(data.factionID) ~= "number" or data.factionID <= 0 or type(data.name) ~= "string" then return end
	if data.isHeader and not data.isHeaderWithRep then return end
	-- Ambiguous localized names must not silently select a different faction.
	local previous = batch.factions[data.name]
	if previous == nil or previous == data.factionID then
		batch.factions[data.name] = data.factionID
	else
		batch.factions[data.name] = false
	end
end

local function ApplyAutoReputation(batch)
	if module.autoReputationBatch ~= batch then return end
	module.autoReputationTimer = nil
	if not module:IsEnabled() or module.db.profile ~= batch.profile
		or not module.db.profile.AutoWatchReputation then
		module:ResetAutoReputation()
		return
	end
	batch.factions = {}
	for id in pairs(batch.ids) do AddFaction(batch, C_Reputation.GetFactionDataByID(id)) end
	-- This also handles gains for an already listed faction if its standing
	-- event was not emitted. Collapsed factions are resolved by their event ID.
	for index = 1, C_Reputation.GetNumFactions() do
		AddFaction(batch, C_Reputation.GetFactionDataByIndex(index))
	end
	local id = batch.factions[batch.names[#batch.names]]
	if id then
		module.autoReputationBatch = nil
		local watched = C_Reputation.GetWatchedFactionData()
		if not watched or watched.factionID ~= id then C_Reputation.SetWatchedFactionByID(id) end
		module:UpdateMainBarVisibility()
	elseif #batch.names > 0 and batch.attempt < 3 then
		batch.attempt = batch.attempt + 1
		module.autoReputationTimer = C_Timer.NewTimer(.15, function() ApplyAutoReputation(batch) end)
	else
		module.autoReputationBatch = nil
	end
end

function module:HandleAutoReputationEvent(event, value)
	if event == "PLAYER_ENTERING_WORLD" then self:ResetAutoReputation(); return end
	if not self:IsEnabled() or not self.db.profile.AutoWatchReputation then
		self:ResetAutoReputation()
		return
	end
	local name, id
	if event == "CHAT_MSG_COMBAT_FACTION_CHANGE" then
		name = GetGainFaction(value)
		if not name then return end
	elseif event == "FACTION_STANDING_CHANGED" then
		if issecretvalue(value) or type(value) ~= "number" or value <= 0 then return end
		id = value
	else
		return
	end
	local batch = self.autoReputationBatch
	if not batch or batch.profile ~= self.db.profile then
		self:ResetAutoReputation()
		batch = { profile = self.db.profile, names = {}, ids = {}, attempt = 1 }
		self.autoReputationBatch = batch
	end
	if name then batch.names[#batch.names + 1] = name end
	if id then batch.ids[id] = true end
	if not self.autoReputationTimer then
		self.autoReputationTimer = C_Timer.NewTimer(.15, function() ApplyAutoReputation(batch) end)
	end
end

local function GetWatchedFactionInfo()
	local data = C_Reputation.GetWatchedFactionData()
	if not data then return end

	return data.name, data.reaction, data.currentReactionThreshold, data.nextReactionThreshold, data.currentStanding, data.factionID
end

-- ####################################################################################################################
-- ##### ReputationDataProvider #######################################################################################
-- ####################################################################################################################
-- Blizzard store reputation in an interesting way.
-- barMin represents the minimum bound for the current standing, barMax represents the maximum bound.
-- For example, barMin for revered is 21000 (3000+6000+12000 from Neutral to Honored), barMax is 42000.
-- To get a 0 / 21000 representation, we have to reduce all three values by barMin.
-- Patch 7.2 changed barMin to be equal to barMax at Exalted, so we need to handle that too.
local ReputationDataProvider = module:CreateBarDataProvider("Reputation")

ReputationDataProvider.BAR_EVENTS = {
	"QUEST_LOG_UPDATE",
	"UPDATE_FACTION",
	"MAJOR_FACTION_RENOWN_LEVEL_CHANGED",
}

function ReputationDataProvider:ShouldBeVisible()
	local name = GetWatchedFactionInfo()
	return name and name ~= ""
end

function ReputationDataProvider:GetParagonValues(factionID)
	-- currentValue is the total amount of paragon a character accrued.
	-- Need to remove threshold value out of currentValue for every reward already received.

	local currentValue, rewardThreshold, _, rewardPending = C_Reputation.GetFactionParagonInfo(factionID)
	if not currentValue or not rewardThreshold or rewardThreshold <= 0 then return 0, 1 end
	currentValue = currentValue % rewardThreshold

	if rewardPending then
		-- If there's a reward pending, the bar should be full, adjust percent value to be above 100%
		self.repText = L["ExpBar_ShortName_Reward"]
		return currentValue + rewardThreshold, rewardThreshold
	else
		self.repText = L["ExpBar_ShortName_Paragon"]
		return currentValue, rewardThreshold
	end
end

function ReputationDataProvider:GetMajorValues(factionID)
	local majorFactionData = C_MajorFactions.GetMajorFactionData(factionID)
	if not majorFactionData then return 0, 1 end
	
	self.repText = "R+" .. majorFactionData.renownLevel
	return majorFactionData.renownReputationEarned, majorFactionData.renownLevelThreshold
end

function ReputationDataProvider:GetFriendshipValues(factionID)
	local reputationInfo = C_GossipInfo.GetFriendshipReputation(factionID)
	if not reputationInfo then return 0, 1 end
	self.repText = reputationInfo.reaction
	-- If the friendship is maxed, there will not be a next threshold, so we can just return a full bar.
	if not reputationInfo.nextThreshold then return 1, 1 end

	-- reactionThreshold is the amount that was needead to get to the current friendship rank.
	-- nextThreshold is the amount needed to get to the next threshold
	-- Standing is the current total reputation. 
	local barMax = reputationInfo.nextThreshold - reputationInfo.reactionThreshold
	local barValue = reputationInfo.standing - reputationInfo.reactionThreshold

	return barValue, barMax
end

function ReputationDataProvider:Update()
	local name, standing, barMin, barMax, barValue, factionID = GetWatchedFactionInfo()
	if not factionID or not standing or not barMin or not barMax or not barValue then
		self.repName = nil
		self.repText = ""
		self.barMin, self.barValue, self.barMax = 0, 0, 1
		return
	end

	self.repName = name
	self.repText = SHORT_REPUTATION_NAMES[standing]
	local friendshipInfo = C_GossipInfo.GetFriendshipReputation(factionID)

	-- Check for the various types of reputations
	if C_Reputation.IsFactionParagonForCurrentPlayer(factionID) then
		barValue, barMax = self:GetParagonValues(factionID)

	elseif C_Reputation.IsMajorFaction(factionID) then
		barValue, barMax = self:GetMajorValues(factionID)

	elseif friendshipInfo and friendshipInfo.friendshipFactionID > 0 then
		barValue, barMax = self:GetFriendshipValues(factionID)
		
	elseif barMin == barMax then
		barValue, barMax = 1, 1
	else
		-- For regular reputations, barValue is the cumulative of all ranks.
		-- barMin is the value for all ranks before the current one.
		barMax = barMax - barMin
		barValue = barValue - barMin
	end
	
	self.barMin = 0
	self.barMax = barMax
	self.barValue = barValue
end

function ReputationDataProvider:GetDataText(style)
	if style == "None" then return "" end
	local status = self.repText or ""
	if style == "Full" then
		local name = self.repName or "Reputation"
		return status ~= "" and format("%s (%s)", name, status) or name
	end
	return status ~= "" and format("Rep %s", status) or "Rep"
end
