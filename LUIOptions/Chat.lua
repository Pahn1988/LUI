-- ####################################################################################################################
-- ##### Setup and Locals #############################################################################################
-- ####################################################################################################################

---@type string, Opt
local optName, Opt = ...
local L, module, db = Opt:GetLUIModule("Chat")
if not module or not module.registered then return end

-- ####################################################################################################################
-- ##### Utility Functions ############################################################################################
-- ####################################################################################################################


-- ####################################################################################################################
-- ##### Options Tables ###############################################################################################
-- ####################################################################################################################

Opt.options.args.Chat = Opt:Group("Chat", nil, nil, "tab", true, nil, Opt.GetSet(db))
Opt.options.args.Chat.handler = module
local Chat = {

}

Opt.options.args.Chat.args = Chat