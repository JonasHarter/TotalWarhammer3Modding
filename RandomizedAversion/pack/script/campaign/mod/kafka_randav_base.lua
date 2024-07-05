local ranav = core:get_static_object("kafka_randomized_aversion")

-- Default settings
ranav.settings = {
	lower_bound = -100,
	upper_bound = 100,
	debug_internal = false
}

-- Savegame marker
ranav.applied_key = "kafka_ranav_applied"

-- Load setting from mct when available
core:add_listener("kafka_ranav_settings_init",
	"MctInitialized",
	true,
	function(context)
        ranav:updateSettings()
	end,
	true
)

function ranav:updateSettings()
	if not get_mct then
		return
	end
	local mct = get_mct();
	if not mct then
		return
	end
	local my_mod = mct:get_mod_by_key("kafka_randomized_aversion")
	local option_lower_bound = my_mod:get_option_by_key("lower_bound")
	local lower_bound_setting = option_lower_bound:get_finalized_setting()
	option_lower_bound:set_read_only(true)
	local option_upper_bound = my_mod:get_option_by_key("upper_bound")
	local upper_bound_setting = option_upper_bound:get_finalized_setting()
	option_upper_bound:set_read_only(true)
	ranav.settings.lower_bound = lower_bound_setting
	ranav.settings.upper_bound = upper_bound_setting
end

core:add_listener(
	"kafka_ranav_onstart",
	"FirstTickAfterNewCampaignStarted",
	true,
	function(context)
		ranav:applyAversionRandomizer()
	end,
	true
);

function ranav:applyAversionRandomizer()
	ranav:log("Starting")
	local applied = cm:get_saved_value(ranav.applied_key);
	if applied then
		ranav:log("Already applied")
		return
	end
	ranav:log("Applying")
	local lowerBound = ranav.settings.lower_bound
	local upperBound = ranav.settings.upper_bound
	local maxBoundAdjusted = upperBound - lowerBound
	local factionList = cm:model():world():faction_list()
	for i = 0, factionList:num_items() - 1 do
		local faction = factionList:item_at(i)
		local custom_eb = cm:create_new_custom_effect_bundle("kafka_generic_diplomod_effect_bundle")
		for j = 0, custom_eb:effects():num_items() - 1 do
			local custom_effect = custom_eb:effects():item_at(j)
			local rand = cm:random_number(maxBoundAdjusted, 0)
			rand = rand + lowerBound
			custom_eb:set_effect_value(custom_effect, rand)
		end
		cm:apply_custom_effect_bundle_to_faction(custom_eb, faction)
	end
	cm:set_saved_value(ranav.applied_key, true);
	ranav:log("Done")
end