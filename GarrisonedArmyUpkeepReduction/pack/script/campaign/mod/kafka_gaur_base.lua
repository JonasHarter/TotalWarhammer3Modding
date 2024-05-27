local gaur = core:get_static_object("gaur")

-- Tracks the latest settlement and bonus of armies
gaur.latest_settlement = {}
gaur.latest_bonus = {}

core:add_listener(
	"kafka_garrisoned_army_upkeep_turn_start",
	"FactionTurnStart",
	true,
	function(context)
		if not gaur.settings.apply_to_ai and not context:faction():is_human() then
			return
		end
		--- Upkeep reduction is positive in config, but negative in db
		local characters = context:faction():character_list()
		for i = 0, characters:num_items() - 1 do
			local character = characters:item_at(i)
			gaur:updateEffect(character)
		end
	end,
	true
)

function gaur:updateEffect(character)
	local cqi = character:command_queue_index()
	if not cm:char_is_mobile_general_with_army(character) then
		gaur.latest_settlement[cqi] = ""
		gaur.latest_bonus[cqi] = 0
		return
  	end
	-- Fill empty values
	if not gaur.latest_settlement[cqi] then
		gaur.latest_settlement[cqi] = ""
	end
	if not gaur.latest_bonus[cqi] then
		gaur.latest_bonus[cqi] = 0
	end
	--- Check for garrison status
	local force = character:military_force()
	if not force:has_garrison_residence() then
		gaur:removeEffect(cqi, force)
		return
	end
	--- Check current settlement
	local currentRegionName = force:garrison_residence():settlement_interface():region():name()
	if gaur.latest_settlement[cqi] ~= "" then
		local previousRegionName = gaur.latest_settlement[cqi]
		if previousRegionName ~= currentRegionName then
			gaur:removeEffect(cqi, force)
			return
		end
	end
	--- Adjust value
	local effectValue = gaur.latest_bonus[cqi]
	effectValue = effectValue + gaur.settings.step_size_increase
	local upperBound = gaur.settings.upper_bound
	if effectValue > upperBound then
		effectValue = upperBound
	end
	--- Apply anew with new value
	local effectBundleNew = cm:create_new_custom_effect_bundle("kafka_garrisoned_army_upkeep_bundle")
	local effectNew = gaur:getEffectFromEffectBundle(effectBundleNew)
	effectBundleNew:set_effect_value(effectNew, -1 * effectValue)
	cm:apply_custom_effect_bundle_to_force(effectBundleNew, force)
	--- Update table
	gaur.latest_settlement[cqi] = currentRegionName
	gaur.latest_bonus[cqi] = effectValue
end

function gaur:removeEffect(cqi, force)
	gaur.latest_settlement[cqi] = ""
	gaur.latest_bonus[cqi] = 0
	cm:remove_effect_bundle_from_force("kafka_garrisoned_army_upkeep_bundle", force:command_queue_index())
end

function gaur:getEffectFromEffectBundle(effectBundle)
	local effectsList = effectBundle:effects()
	for i = 0, effectsList:num_items() - 1 do
		local effect = effectsList:item_at(i)
		if effect:key() == "kafka_garrisoned_army_upkeep_effect" then
			return effect
		end
	end
	return nil
end