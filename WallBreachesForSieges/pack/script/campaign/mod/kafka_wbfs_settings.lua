local wbfs = core:get_static_object("kafka_wbfs")

-- Default settings
wbfs.settings = {
	apply_to_player = true,
	apply_to_ai = false,
	breaches_count = 6,
	logging_enabled = false
}

function wbfs:getConfigApplyToPlayer()
	return wbfs.settings.apply_to_player
end

function wbfs:getConfigApplyToAi()
	return wbfs.settings.apply_to_ai
end

function wbfs:getConfigBreachesCount()
	return wbfs.settings.breaches_count
end

function wbfs:getConfigEnableLogging()
	return wbfs.settings.logging_enabled
end

function wbfs:updateSettings()
	if not get_mct then
		return
	end
	local mct = get_mct()
	if not mct then
		return
	end
	local my_mod = mct:get_mod_by_key("kafka_wbfs")
	local option_apply_to_player = my_mod:get_option_by_key("apply_to_player")
	local apply_to_player_setting = option_apply_to_player:get_finalized_setting()
	local option_apply_to_ai = my_mod:get_option_by_key("apply_to_ai")
	local apply_to_ai_setting = option_apply_to_ai:get_finalized_setting()
	local option_breaches_count = my_mod:get_option_by_key("breaches_count")
	local breaches_count_setting = option_breaches_count:get_finalized_setting()
	wbfs.settings.apply_to_player = apply_to_player_setting
	wbfs.settings.apply_to_ai = apply_to_ai_setting
	wbfs.settings.breaches_count = breaches_count_setting
end

-- Load setting from mct when available
core:add_listener(
	"kafka_wbfs_settings_init",
	"MctInitializedSDf",
	true,
	function(context)
        wbfs:updateSettings()
	end,
	true
)

-- Edit setting during campaign
core:add_listener(
    "kafka_wbfs_settings_changed",
    "MctOptionSettingFinalized",
    true,
    function(context)
        wbfs:updateSettings()
    end,
    true
)