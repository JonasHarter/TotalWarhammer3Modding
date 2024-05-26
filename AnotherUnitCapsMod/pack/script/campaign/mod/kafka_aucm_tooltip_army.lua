local aucm = core:get_static_object("aucm");

-- Set army cost tooltip
core:add_listener(
	"kafka_aucm_setArmyCostTooltip",
	"CharacterSelected", 
    function(context)
      return context:character():has_military_force();
    end,
	function(context)
		local character = context:character();
		cm:set_saved_value("aucm_last_selected_char_cqi", character:command_queue_index());
		cm:callback( function()
			aucm:setArmyCostToolTip(character);
		end, 0.1)
	end,
	true
);

core:add_listener(
	"kafka_aucm_clearLastSelectedCharacter",
	"CharacterSelected",
	function(context)
		return not context:character():has_military_force();
	end,
	function()
		cm:set_saved_value("aucm_last_selected_char_cqi", "");
	end,
	true
);

-- Catch all clicks to refresh the army cost tt if the units_panel is open
-- Fires also when player cancels recruitment of a unit, adds a unit to the queue etc
core:add_listener(
	"kafka_aucm_setArmyCostTooltip_clicked",
	"ComponentLClickUp",
	function(context)
		return cm.campaign_ui_manager:is_panel_open("units_panel");
	end,
	function(context)
		cm:callback(function()
			local savedCqi = cm:get_saved_value("aucm_last_selected_char_cqi")
			if not savedCqi then
				return
			end
			local lastSelectedCharacter = cm:get_character_by_cqi(cm:get_saved_value("aucm_last_selected_char_cqi"));
			if not(lastSelectedCharacter and lastSelectedCharacter ~= "") then
				return
			end
			if lastSelectedCharacter:is_wounded() then
				return
			end
			if not cm:char_is_mobile_general_with_army(lastSelectedCharacter) then
				return
			end
			aucm:setArmyCostToolTip(lastSelectedCharacter);
		end, 0.3)
	end,
	true
);

-- Shows the army cost in the army name tooltip
function aucm:setArmyCostToolTip(character)
  local zoom_component = find_uicomponent(core:get_ui_root(), "main_units_panel", "button_focus");
	if not zoom_component then
		return;
	end

	local tt_text = ""
	if character:has_military_force() then
		local armyCost = aucm:getArmyCost(character);
		local armyLimit = aucm:getArmyLimit(character);
		local armyQueueCost = aucm:getArmyQueuedUnitsCost();
		tt_text = "Current Cost: " .. armyCost .. "/" .. armyLimit
		tt_text = tt_text .. "\n"
		if armyQueueCost > 0 then
			tt_text = tt_text .. "Expected Cost: " .. (armyCost + armyQueueCost) .. "/" .. armyLimit
		end
	end
	zoom_component:SetTooltipText(tt_text, true);
end


--[[
    --when a unit is added to the recruitment queue, add its costs.
    core:add_listener(
      "TTCMainListeners",
      "RecruitmentItemIssuedByPlayer",
      function(context)
          return context:faction():name() == cm:get_local_faction_name(true)
      end,
      function(context)
        local character_record = mod.get_selected_character_record()
        if not character_record then
          out("The player recruited a unit but has no character selected?")
          out("This is an error")
          ttc_error()
          return
        end
        local unit_record = mod.get_unit(context:main_unit_record(), character_record)
        out("Player started recruitment of "..unit_record.key)
        character_record:apply_cost_of_unit(unit_record)
        mod.refresh_icons_on_army_units_panel()
        core:trigger_event("ModScriptEventRefreshUnitCards")
        cm:callback(function()
          mod.refresh_icons_on_army_units_panel()
        end, 0.1)
      end,
      true)

     
    --when a unit is removed from the recruitment queue, refund the costs associated with it.
    core:add_listener(
      "TTCMainListeners",
      "RecruitmentItemCancelledByPlayer",
      function(context)
          return context:faction():name() == cm:get_local_faction_name(true)
      end,
      function(context)
        local character_record = mod.get_selected_character_record()
        if not character_record then
          out("The player cancelled a unit but has no character selected?")
          out("This is an error")
          ttc_error()
          return
        end
        local unit_record = mod.get_unit(context:main_unit_record(), character_record)
        out("Player cancelled recruitment of "..unit_record.key)
        character_record:refund_cost_of_unit(unit_record)
        if mod.is_recruit_panel_open() or mod.is_merc_panel_open() then
          mod.refresh_icons_on_army_units_panel()
          core:trigger_event("ModScriptEventRefreshUnitCards")
          cm:callback(function()
            mod.refresh_icons_on_army_units_panel()
          end, 0.1)
        end
      end,
      true)
    --Adjust costs and trigger a refresh after a unit is disbanded
    core:add_listener(
      "TTCMainListeners",
      "UnitDisbanded",
      function(context)
        return context:unit():faction():name() == cm:get_local_faction_name(true)
      end,
      function(context)
        local character_record = mod.get_selected_character_record()
        if not character_record then
          out("The player disbanded a unit but has no character selected?")
          out("This is an error")
          ttc_error()
          return
        end
        local unit_record = mod.get_unit(context:unit():unit_key(), character_record)
        out("Player disbanded "..unit_record.key)
        character_record:refund_cost_of_unit(unit_record)
        if not mod.is_recruit_panel_open() and not mod.is_merc_panel_open() then
          cm:callback(function() 
            core:trigger_event("ModScriptEventRefreshUnitCards")
          end, 0.1)
        end
      end,
      true)
    --Adjust costs and trigger a refresh after unit merged
    core:add_listener(
      "TTCMainListeners",
      "UnitMergedAndDestroyed",
      function(context)
        return context:new_unit():faction():name() == cm:get_local_faction_name(true)
      end,
      function(context)
        local character_record = mod.get_selected_character_record()
        if not character_record then
          out("The player merged a unit but has no character selected?")
          out("This is an error")
          ttc_error()
          return
        end
        local unit_record = mod.get_unit(context:new_unit():unit_key(), character_record)
        out("Player merged and destroyed "..unit_record.key)
        character_record:refund_cost_of_unit(unit_record)
        if not mod.is_recruit_panel_open() and not mod.is_merc_panel_open() then
          cm:callback(function() 
            core:trigger_event("ModScriptEventRefreshUnitCards")
          end, 0.1)
        end
      end,
      true)
--]]