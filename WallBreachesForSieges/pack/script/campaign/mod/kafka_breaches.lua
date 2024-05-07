local kafka = {};
-- Default settings
local settings = {
	apply_to_player = true,
	apply_to_ai = false,
	breaches_count = 5
}

-- Load setting from mct when available
core:add_listener("kafka_breaches_settings_init",
	"MctInitialized",
	true,
	function(context)
        kafka:updateSettings()
	end,
	true
)

-- Edit setting during campaign
core:add_listener(
    "kafka_breaches_settings_changed",
    "MctOptionSettingFinalized",
    true,
    function(context)
        kafka:updateSettings()
    end,
    true
)

function kafka:updateSettings()
	if not get_mct then
		return
	end
	local mct = get_mct();
	if not mct then
		return
	end
	local my_mod = mct:get_mod_by_key("kafka_breaches")
	local option_apply_to_player = my_mod:get_option_by_key("apply_to_player")
	local apply_to_player_setting = option_apply_to_player:get_finalized_setting()
	local option_apply_to_ai = my_mod:get_option_by_key("apply_to_ai")
	local apply_to_ai_setting = option_apply_to_ai:get_finalized_setting()
	local option_breaches_count = my_mod:get_option_by_key("breaches_count")
	local breaches_count_setting = option_breaches_count:get_finalized_setting()
	settings.apply_to_player = apply_to_player_setting
	settings.apply_to_ai = apply_to_ai_setting
	settings.breaches_count = breaches_count_setting
end

-- Damages walls when character besieges settlement
core:add_listener(
	"kafka_breaches_damage",
	"CharacterBesiegesSettlement",
	true,
	function(context)
		local settlement = context:region():settlement()
		if not settlement:is_walled_settlement() then
			return
		end
		local isHuman = context:character():faction():is_human()
		if settings.apply_to_player and not isHuman then
			return
		end
		if settings.apply_to_ai and isHuman then
			return
		end
		local breaches = settings.breaches_count
		if settlement:number_of_wall_breaches() < breaches then
			cm:set_settlement_wall_health(settlement, settings.breaches_count)
		end
	end,
	true
);