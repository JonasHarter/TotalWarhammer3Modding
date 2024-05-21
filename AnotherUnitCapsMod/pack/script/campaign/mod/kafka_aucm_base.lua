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
	local cost = unit:get_unit_custom_battle_cost()
	return aucm:calculateCost(cost)
end

-- Calculates the cost for the unit 
function aucm:getUnitCostFromKey(unitKey)
	-- TODO check for free unit
	local cost = cco("CcoMainUnitRecord", unitKey):Call("Cost");
	return aucm:calculateCost(cost)
end

-- Calculates the cost via the base mp cost
function aucm:calculateCost(cost)
	return math.floor(cost / aucm:getConfig("mpcost_per_point"))
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

-- Calculates the cost of units in a garrison
function aucm:getGarrisonCost(cqi)
	local garrison_cost = 0;
	local unit_list = cm:get_military_force_by_cqi(cqi):unit_list();
	for i = 0, unit_list:num_items() - 1 do
		garrison_cost = garrison_cost + aucm:getUnitCost(unit_list:item_at(i));
	end

	return garrison_cost;
end

-- Calculates the cost of the unit in the recruitment queue of the army
function aucm:getArmyQueuedUnitsCost()
	-- Fetches all the data from the ui
	local army = find_uicomponent_from_table(core:get_ui_root(), {"units_panel", "main_units_panel", "units"})
	if not army then
		return
	end

	local queuedUnitsCost = 0;
	for i = 0, army:ChildCount() - 1 do
		local unitCard = UIComponent(army:Find(i));
		if unitCard:Id():find("Queued") or unitCard:Id():find("temp_merc") then
			queuedUnitsCost = queuedUnitsCost + aucm:getUnitCostFromUnitCard(unitCard);
		end
	end

	return queuedUnitsCost;
end

-- Reads the unit's cost from the unit card
function aucm:getUnitCostFromUnitCard(unit_card)
	local unitCost = 0;

	unit_card:SimulateMouseOn();
	local ok, err = pcall(function()
		local unitInfo = find_uicomponent(core:get_ui_root(), "hud_campaign", "unit_information_parent", "unit_info_panel_holder_parent", "unit_info_panel_holder");
		local unitKey = string.gsub(string.gsub(unitInfo:GetContextObjectId("CcoUnitDetails"), "RecruitmentUnit_", ""), "_%d+_%d+_%d+_%d+$", "");
		unitCost = aucm:getUnitCostFromKey(unitKey);
	end);
	unit_card:SimulateMouseOff();

	return unitCost;
end

