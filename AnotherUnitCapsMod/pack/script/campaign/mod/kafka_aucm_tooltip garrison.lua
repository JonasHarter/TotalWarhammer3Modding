local aucm = core:get_static_object("aucm")

-- Set garrison cost tooltip
-- RegionSelected?
core:add_listener(
	"kafka_aucm_setGarrisonCostTooltip",
	"SettlementSelected",
	true,
	function(context)
		aucm:setGarrisonCostTooltip(context:garrison_residence():region())
	end,
	true)

function aucm:setGarrisonCostTooltip(region)
	if region:is_abandoned() then
		return
	end
	local garrison_commander = cm:get_garrison_commander_of_region(region)
	if not garrison_commander then
		return
	end
	local armyCqi = garrison_commander:military_force():command_queue_index()
	cm:callback(function()
		aucm:setGarrisonCostTooltipInternal(armyCqi)
	end, 0.1)
end

function aucm:setGarrisonCostTooltipInternal(cqi)
	if cqi == -1 then
		return
	end
	local settlementInfoButton = find_uicomponent(core:get_ui_root(), "settlement_panel", "button_info")
	if not settlementInfoButton then
		return
	end
	local armyCost = aucm:getGarrisonCost(cqi)
	local tt_text = "Garrison: " .. armyCost
	settlementInfoButton:SetTooltipText(tt_text, true)
end



