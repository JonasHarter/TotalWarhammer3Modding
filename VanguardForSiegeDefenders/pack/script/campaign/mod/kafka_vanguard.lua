core:add_listener("kafka_vanguard_settlement_defender", "PendingBattle", function(context)
	return context:pending_battle():siege_battle()
end, function(context)
	local battle = context:pending_battle()
	local garrison_residence = battle:contested_garrison()
	local garrison_commander = cm:get_garrison_commander_of_region(garrison_residence:region())
	if not garrison_commander then
		return
	end
	if not battle:siege_battle() then
		return
	end
	local army = garrison_commander:military_force()
	local army_cqi = army:command_queue_index()
	local defending_char_cqi = context:pending_battle():defender()
	local armylord = defending_char_cqi:military_force()
	local army_cqi_lord = armylord:command_queue_index()
	cm:apply_effect_bundle_to_force("kafka_vanguard", army_cqi, 1)
	cm:apply_effect_bundle_to_force("kafka_vanguard", army_cqi_lord, 1)
end, true)
