local aucm = core:get_static_object("aucm");

-- Generates a list, with all unit types, the faction currently possesses
function aucm:generateRecuitmentPool(faction)
	-- TODO also pull garrisons?
	local recruitmentPool = {};
	local characters = faction:character_list();
	for i = 0, characters:num_items() - 1 do
		local character = characters:item_at(i);
		if cm:char_is_mobile_general_with_army(character) then
			aucm:addUnitsToRecruitmentPool(character:military_force():unit_list(), recruitmentPool);
		end
	end
	return recruitmentPool;
end

function aucm:addUnitsToRecruitmentPool(unitList, recruitmentPool)
	for i = 1, unitList:num_items() - 1 do
		local unit = unitList:item_at(i);
		local unitKey = unit:unit_key();

		if recruitmentPool[unitKey] == nil and not aucm:is_hero(unitKey) then
			local unitCost = aucm:getUnitCost(unit);
			if unitCost > 0 then
				recruitmentPool[unitKey] = unitCost;
			end
		end
	end
end
