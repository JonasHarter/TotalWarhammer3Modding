local aucm = core:get_static_object("aucm");

-- Default settings
aucm.settings = {
	army_limit_point_divider = 200,
	army_limit_base = 50,
	army_limit_ai_adjust = 10,
	army_limit_hero_cap = 2,
	logging_enabled = false
};

function aucm:getConfigArmyLimitDivider()
	return self.settings.army_limit_point_divider
end

function aucm:getConfigArmyLimit()
	return self.settings.army_limit_base
end

function aucm:getConfigArmyLimitAiAdjust()
	return self.settings.army_limit_ai_adjust
end

function aucm:getConfigArmyLimitHeroCap()
	return self.settings.army_limit_hero_cap
end

function aucm:getConfigEnableLogging()
	return self.settings.enable_logging
end

-- Load setting at campaign start
core:add_listener(
	"kafka_aucm_settings_init",
	"MctInitialized",
	true,
	function(context)
        aucm:updateSettings()
	end,
	true
)

-- Edit setting during campaign
core:add_listener(
    "kafka_aucm_settings_changed",
    "MctOptionSettingFinalized",
    true,
    function(context)
        aucm:updateSettings()
    end,
    true
)

function aucm:updateSettings()
	if not get_mct then
		return
	end
	local mct = get_mct();
	if not mct then
		return
	end
	local my_mod = mct:get_mod_by_key("kafka_another_unit_caps_mod")
	aucm.settings.army_limit_point_divider = my_mod:get_option_by_key("army_limit_point_divider"):get_finalized_setting()
	aucm.settings.army_limit_base = my_mod:get_option_by_key("army_limit_base"):get_finalized_setting()
	aucm.settings.army_limit_ai_adjust = my_mod:get_option_by_key("army_limit_ai_adjust"):get_finalized_setting()
	aucm.settings.army_limit_hero_cap = my_mod:get_option_by_key("army_limit_hero_cap"):get_finalized_setting()
	aucm.settings.enable_logging = my_mod:get_option_by_key("logging_enabled"):get_finalized_setting()
	out("[kafka][aucm] Settings loaded. Logging: " .. tostring(aucm:getConfigEnableLogging()))
	aucm:log("Settings:")
	aucm:log(tostring(aucm:getConfigArmyLimitDivider()))
	aucm:log(tostring(aucm:getConfigArmyLimit()))
	aucm:log(tostring(aucm:getConfigArmyLimitAiAdjust()))
	aucm:log(tostring(aucm:getConfigArmyLimitHeroCap()))
	aucm:log(tostring(aucm:getConfigEnableLogging()))
end