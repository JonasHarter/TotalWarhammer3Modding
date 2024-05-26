local aucm = core:get_static_object("aucm")

-- Set army cost tooltip
core:add_listener(
	"kafka_aucm_setArmyCostTooltip",
	"CharacterSelected", 
    function(context)
      return context:character():has_military_force()
    end,
	function(context)
		local character = context:character()
		cm:set_saved_value("aucm_last_selected_char_cqi", character:command_queue_index())
		cm:callback( function()
			aucm:setArmyCostToolTip(character)
			aucm:setUnitCostBreakdownTooltip(character)
		end, 0.1)
	end,
	true
)

core:add_listener(
	"kafka_aucm_clearLastSelectedCharacter",
	"CharacterSelected",
	function(context)
		return not context:character():has_military_force()
	end,
	function()
		cm:set_saved_value("aucm_last_selected_char_cqi", "")
	end,
	true
)

-- Catch all clicks to refresh the army cost tt if the units_panel is open
-- Fires also when player cancels recruitment of a unit, adds a unit to the queue etc
core:add_listener(
	"kafka_aucm_setArmyCostTooltip_clicked",
	"ComponentLClickUp",
	function(context)
		return cm.campaign_ui_manager:is_panel_open("units_panel")
	end,
	function(context)
		cm:callback(function()
			local savedCqi = cm:get_saved_value("aucm_last_selected_char_cqi")
			if not savedCqi then
				return
			end
			local lastSelectedCharacter = cm:get_character_by_cqi(cm:get_saved_value("aucm_last_selected_char_cqi"))
			if not(lastSelectedCharacter and lastSelectedCharacter ~= "") then
				return
			end
			if lastSelectedCharacter:is_wounded() then
				return
			end
			if not cm:char_is_mobile_general_with_army(lastSelectedCharacter) then
				return
			end
			aucm:setArmyCostToolTip(lastSelectedCharacter)
			aucm:setUnitCostBreakdownTooltip(lastSelectedCharacter)
		end, 0.3)
	end,
	true
)

-- Shows the army cost in the army name tooltip
function aucm:setArmyCostToolTip(character)
  local zoom_component = find_uicomponent(core:get_ui_root(), "main_units_panel", "button_focus")
	if not zoom_component then
		return
	end

	local tt_text = ""
	if character:has_military_force() then
		local armyCost = aucm:getArmyCost(character)
		local armyLimit = aucm:getArmyLimit(character)
		local armyQueueCost = aucm:getArmyQueuedUnitsCost()
		tt_text = "Current Cost: " .. armyCost .. "/" .. armyLimit
		tt_text = tt_text .. "\n"
		if armyQueueCost > 0 then
			tt_text = tt_text .. "Expected Cost: " .. (armyCost + armyQueueCost) .. "/" .. armyLimit
			tt_text = tt_text .. "\n"
		end
		local armyHeroCount = aucm:getArmyHeroCount(character)
		local armyHeroLimit = aucm:getConfigArmyLimitHeroCap()
		tt_text = tt_text .. "Heroes: " .. armyHeroCount .. "/" .. armyHeroLimit
	end
	zoom_component:SetTooltipText(tt_text, true)
end

-- Sets the breakdown tooltip to the army info button
function aucm:setUnitCostBreakdownTooltip(character)
	local infoButton = find_uicomponent(core:get_ui_root(), "units_panel", "main_units_panel", "tr_element_list", "button_info_holder", "button_info")
	if not infoButton then
		return
	end

	local unitCosts = {}
	local unitList = character:military_force():unit_list()
	for i = 0, unitList:num_items() - 1 do
		local unit = unitList:item_at(i)
		unitCosts[unit:unit_key()] = aucm:getUnitCost(unit)
	end

	infoButton:SetTooltipText(aucm:getUnitListCostTooltip(unitCosts), true)
end

-- Creates a tooltip with the unit types in the army and their cost
function aucm:getUnitListCostTooltip(unitCosts)
	local tt_text = "Unit costs breakdown:\n"
	local unitCostsKeys = aucm:getTableKeys(unitCosts)
	table.sort(unitCostsKeys, function(keyLhs, keyRhs)
		return unitCosts[keyLhs] < unitCosts[keyRhs]
	end)
	for _, unitKey in pairs(unitCostsKeys) do
		local unitCost = unitCosts[unitKey]
		local unitName = common.get_localised_string("land_units_onscreen_name_" .. unitKey)
		if not aucm:isHero(unitKey) then
			tt_text = tt_text .. unitName .. ": " .. unitCost .. "\n"
		end
	end

	return tt_text
end
