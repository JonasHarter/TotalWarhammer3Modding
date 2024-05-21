local aucm = core:get_static_object("aucm");

-- Set army cost tooltip
core:add_listener(
	"kafka_aucm_setArmyCostTooltip",
	"CharacterSelected", 
	true,
	function(context)
		local character = context:character();
		cm:callback(function()
			aucm:setArmyCostToolTip(character);
		end, 0.1)
	end,
	true);

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
		tt_text = "Army: " .. armyCost .. "/" .. armyLimit
	end
	-- TODO check if army should be affected
	zoom_component:SetTooltipText(tt_text, true);
end
