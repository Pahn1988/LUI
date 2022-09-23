-- ####################################################################################################################
-- ##### Setup and Locals #############################################################################################
-- ####################################################################################################################

---@type string, Opt
local optName, Opt = ...
local L, module, db = Opt:GetLUIModule("Auras")
if not module or not module.registered then return end

-- ####################################################################################################################
-- ##### Utility Functions ############################################################################################
-- ####################################################################################################################


-- ####################################################################################################################
-- ##### Options Table ################################################################################################
-- ####################################################################################################################

Opt.options.args.Auras = Opt:Group("Buffs/Debuffs", nil, nil, "tab", true, nil, Opt.GetSet(db))
Opt.options.args.Auras.handler = module
local Auras = {

}

Opt.options.args.Auras.args = Auras