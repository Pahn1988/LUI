-- Memory Infotext

-- ####################################################################################################################
-- ##### Setup and Locals #############################################################################################
-- ####################################################################################################################

---@type string, LUIAddon
local _, LUI = ...
local L = LUI.L

---@type InfotextModule
local module = LUI:GetModule("Infotext")
local element = module:NewElement("Memory")

local format = format
local collectgarbage = collectgarbage
local UpdateAddOnMemoryUsage = _G.UpdateAddOnMemoryUsage
local GetAddOnMemoryUsage = _G.GetAddOnMemoryUsage
local IsAddOnLoaded = _G.IsAddOnLoaded
local GetNumAddOns = _G.GetNumAddOns
local GetAddOnInfo = _G.GetAddOnInfo
local C_Timer = C_Timer

local totalMemory = 0
local addonMemory = {} --contains addonTitle, memoryUsage
local sortedAddons = {} -- Sorting table for addonMemory

-- Everything is too green without this multiplier
local GRADIENT_MULTIPLIER = 1.4
local MEMORY_UPDATE_TIME = 20
local USAGE_UPDATE_TIME = 600
local KB_PER_MB = 1024

-- ####################################################################################################################
-- ##### Module Functions #############################################################################################
-- ####################################################################################################################

local function addonSort(a, b)
	return addonMemory[a] > addonMemory[b]
end

local function formatMemory(kb)
	if kb > KB_PER_MB then
		return format("%.2fmb", kb / KB_PER_MB)
	else
		return format("%.1fkb", kb)
	end
end

function element:UpdateMemory()
	totalMemory = 0

	for i = 1, GetNumAddOns() do
		local _, addonTitle = GetAddOnInfo(i)
		if IsAddOnLoaded(i) then
			addonMemory[addonTitle] = GetAddOnMemoryUsage(i)
			totalMemory = totalMemory + addonMemory[addonTitle]
		else
			addonMemory[addonTitle] = nil
		end
	end

	--sort table
	LUI:SortTable(sortedAddons, addonMemory, addonSort)
	element.text = format("%.1fmb", totalMemory / KB_PER_MB)

	element:UpdateTooltip()
end

function element.OnClick(frame, button)
	if button == "RightButton" then
		UpdateAddOnMemoryUsage()
	end
	collectgarbage("collect")
	element:UpdateMemory()
end

-- ####################################################################################################################
-- ##### Infotext Display #############################################################################################
-- ####################################################################################################################

function element.OnTooltipShow(GameTooltip)
	element:TooltipHeader(L["InfoMemory_Header"])
	for i = 1, #sortedAddons do
		local addonTitle = sortedAddons[i]
		local r, g, b = LUI:InverseGradient((addonMemory[addonTitle] / totalMemory) * GRADIENT_MULTIPLIER)
		GameTooltip:AddDoubleLine(addonTitle, formatMemory(addonMemory[addonTitle]), 1,1,1, r, g, b)
	end

	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(L["InfoMemory_TotalMemory"], formatMemory(totalMemory), 1,1,1, .8,.8,.8)

	element:AddHint(L["InfoMemory_Hint_Any"])
end

-- ####################################################################################################################
-- ##### Framework Events #############################################################################################
-- ####################################################################################################################

function element:OnCreate()
	element:AddUpdate("UpdateMemory", MEMORY_UPDATE_TIME)

	-- This ensures that all addons are loaded at the time of updating memory usage.
	C_Timer.After(1, function()
		UpdateAddOnMemoryUsage()
		element:UpdateMemory()
	end)
	-- Update usage once every 10 minutes, outside of combat.
	C_Timer.NewTicker(USAGE_UPDATE_TIME, function()
		if not _G.InCombatLockdown() then
			UpdateAddOnMemoryUsage()
		end
	end)
end
