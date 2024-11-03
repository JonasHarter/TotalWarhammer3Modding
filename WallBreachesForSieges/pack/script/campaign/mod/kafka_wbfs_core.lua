local wbfs = core:get_static_object("kafka_wbfs")

-- Damages walls when character besieges settlement
core:add_listener(
	"kafka_wbfs_damage",
	"CharacterBesiegesSettlement",
	true,
	function(context)
		local settlement = context:region():settlement()
		if not settlement:is_walled_settlement() then
			return
		end
		local isHuman = context:character():faction():is_human()
		if wbfs:getConfigApplyToPlayer() and not isHuman then
			return
		end
		if wbfs:getConfigApplyToAi() and isHuman then
			return
		end
		local totalBreaches = wbfs:getConfigBreachesCount()
		if settlement:number_of_wall_breaches() >= totalBreaches then
			return
		end
		-- Cannot be called repeatedly to create multiple clusters
		cm:set_settlement_wall_health(settlement, totalBreaches)
	end,
	true
);