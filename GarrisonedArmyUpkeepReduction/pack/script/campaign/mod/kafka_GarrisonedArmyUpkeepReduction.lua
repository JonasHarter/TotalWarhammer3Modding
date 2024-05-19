local kafka_garrisoned_army_upkeep = {};
-- Default settings
local settings = {
	upper_bound = 80,
	step_size_increase = 10,
	step_size_decrease = 20,
	apply_to_ai = false
}

-- Load setting from mct when available
core:add_listener(
	"kafka_garrisoned_army_upkeep_settings_init",
	"MctInitialized",
	true,
	function(context)
        kafka_garrisoned_army_upkeep:updateSettings()
	end,
	true
)

-- Edit setting during campaign
core:add_listener(
    "kafka_garrisoned_army_upkeep_settings_changed",
    "MctOptionSettingFinalized",
    true,
    function(context)
        kafka_garrisoned_army_upkeep:updateSettings()
    end,
    true
)

function kafka_garrisoned_army_upkeep:updateSettings()
	if not get_mct then
		return
	end
	local mct = get_mct();
	if not mct then
		return
	end
	local my_mod = mct:get_mod_by_key("kafka_garrisoned_army_upkeep")
	settings.upper_bound = my_mod:get_option_by_key("upper_bound"):get_finalized_setting()
	settings.step_size_increase = my_mod:get_option_by_key("step_size_increase"):get_finalized_setting()
	settings.step_size_decrease = my_mod:get_option_by_key("step_size_decrease"):get_finalized_setting()
	settings.apply_to_ai = my_mod:get_option_by_key("apply_to_ai"):get_finalized_setting()
end

core:add_listener(
	"kafka_garrisoned_army_upkeep",
	"FactionTurnStart",
	true,
	function(context)
		out("Kafka-run")	
		if not settings.apply_to_ai and not context:faction():is_human() then
			return
		end
		--- local forcesList = context:faction():military_force_list()
		local characters = context:faction():character_list();
		for i = 0, characters:num_items() - 1 do
			local character = characters:item_at(i);
		  	if cm:char_is_mobile_general_with_army(character) then
				out("Kafka-run-2")	
				--- Check for garrison status
				local force = character:military_force()
				local valueMod = settings.step_size_increase
				local forceIsInGarrison = force:has_garrison_residence()
				if not forceIsInGarrison then
					valueMod = -1 * settings.step_size_decrease
				end
				out("valueMod " .. valueMod)
				--- Read effect bundle value
				local effectValueOld = 0
				local effectBundleOld = kafka_garrisoned_army_upkeep:getEffectBundle(force)
				if effectBundleOld then
					local effectOld = kafka_garrisoned_army_upkeep:getEffect(effectBundleOld)
					effectValueOld = effectOld:value()
				end
				out("effectValueOld " .. effectValueOld)
				--- Adjust value and apply
				local effectValueNew = -1 * effectValueOld
				local effectValueNew = effectValueNew + valueMod
				if effectValueNew > settings.upper_bound then
					effectValueNew = settings.upper_bound
				end
				if effectValueNew < 0 then
					effectValueNew = 0
				end
				effectValueNew = -1 * effectValueNew
				out("effectValueNew " .. effectValueNew)
				local effectBundleNew = cm:create_new_custom_effect_bundle("kafka_garrisoned_army_upkeep")
				local effectNew = kafka_garrisoned_army_upkeep:getEffect(effectBundleNew)
				effectBundleNew:set_effect_value(effectNew, effectValueNew)
				cm:apply_custom_effect_bundle_to_force(effectBundleNew, force)
				out("Kafka-done")
			end
		end
	end,
	true
);

function kafka_garrisoned_army_upkeep:getEffectBundle(force)
	local effectBundleList = force:effect_bundles()
	for i = 0, effectBundleList:num_items() - 1 do
		local effectBundle = effectBundleList:item_at(i)
		if effectBundle:key() == "kafka_garrisoned_army_upkeep" then
			return effectBundle
		end
	end
	return nil
end

function kafka_garrisoned_army_upkeep:getEffect(effectBundle)
	local effectsList = effectBundle:effects()
	for i = 0, effectsList:num_items() - 1 do
		local effect = effectsList:item_at(i)
		if effect:key() == "kafka_garrisoned_army_upkeep" then
			return effect
		end
	end
	return nil
end