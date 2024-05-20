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
		cm:callback(function()
			aucm:setArmyCostToolTip(character);
		end, 0.1)
	end,
	true);

-- Clear army cost tooltip before set
core:add_listener(
	"kafka_aucm_cleanArmyCostTooltip",
	"CharacterSelected", 
	function(context)
		return not context:character():has_military_force();
	end, 
	function()
		cm:set_saved_value("aucm_last_selected_char_cqi", "");
	end,
	true);

-- Shows the army cost in the army name tooltip
function aucm:setArmyCostToolTip(character)
	local zoom_component = find_uicomponent(core:get_ui_root(), "main_units_panel", "button_focus");
	if not zoom_component then
		return;
	end

	local armyCost = aucm:getArmyCost(character);
	local armyLimit = aucm:getArmyLimit(character);
	local tt_text = armyCost .. "/" .. armyLimit

	-- TODO check if army should be affected

	zoom_component:SetTooltipText(tt_text, true);
end
