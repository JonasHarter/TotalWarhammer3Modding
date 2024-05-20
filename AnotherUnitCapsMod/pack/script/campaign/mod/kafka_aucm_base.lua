local aucm = core:get_static_object("aucm");

local config = {
	army_limit_player = 50,
	army_limit_ai_bonus = 10,
	mpcost_per_point = 200,
	hero_cap = 2,
	upgrade_ai_armies = false,
	upgrade_grace_period = 20
};

-- Retrieves a value from the configuration
function aucm:getConfig(config_key)
	return config[config_key];
end

-- Calculates the cost for the unit
function aucm:getUnitCost(unit)
	-- TODO check for free unit
	return math.floor(unit:get_unit_custom_battle_cost() / aucm:getConfig("mpcost_per_point"))
end

-- Calculates the hero count for the unit
function aucm:getHeroCount(unit)
	-- TODO check for free hero
	if aucm:is_hero(unit:unit_key()) then
		return 1;
	end
	return 0;
end

-- Check if unit is a hero
function aucm:isHero(unit_key)
	return string.find(unit_key, "_cha_")
end

-- Calculates the cost of the units in the army
function aucm:getArmyCost(character)
	if not character:has_military_force() then
		return -1;
	end
	local armyCost = 0;
	local unitList = character:military_force():unit_list();
	for i = 0, unitList:num_items() - 1 do
		armyCost = armyCost + aucm:getUnitCost(unitList:item_at(i));
	end
	return armyCost;
end

-- Calculates the cost limit of the army
function aucm:getArmyLimit(character)
	local armyLimit;
	armyLimit = aucm:getConfig("army_limit_player");
	if not character:faction():is_human() then
		armyLimit = armyLimit + aucm:getConfig("army_limit_ai_bonus");
	end
	-- TODO dynamic limit, faction leader bonus?
	return armyLimit;
end

-- Counts the number of heroes embedded in the army
function aucm:getArmyHeroCount(character)
	if not character:has_military_force() then
		return -1;
	end

	local heroCount = -1;
	local unitList = character:military_force():unit_list();
	for i = 0, unitList:num_items() - 1 do
		heroCount = heroCount + aucm:getHeroCount(unitList:item_at(i));
	end

	return heroCount;
end
