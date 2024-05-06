-- damages walls when character besieges settlement
core:add_listener(
	"kafka_damage_settlement_wall",
	"CharacterBesiegesSettlement",
	function(context)
		return true
	end,
	function(context)
		local region = context:region()
		local settlement = region:settlement()
		local character = region:garrison_residence():besieging_character()
		if not settlement:is_walled_settlement() then
            return
        end
        local breaches = 5
        out("Character " .. character:get_forename() .. " has besieged " .. context:region():name() .. " and damaged " .. breaches .. " walls of this settlement!")	
        cm:set_settlement_wall_health(settlement, breaches)
	end,
	true
);