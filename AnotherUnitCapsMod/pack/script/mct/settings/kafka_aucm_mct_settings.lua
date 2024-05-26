if not get_mct then return end
local mct = get_mct();

if not mct then return end
local mct_mod = mct:register_mod("kafka_another_unit_caps_mod");

mct_mod:set_title("Cost-based Army Caps", false);
mct_mod:set_author("Kafka, Wolfy & Jadawin");
mct_mod:set_description("Cost limit for all armies", false);

mct_mod:add_new_section("aucm_base", "Base Options", false);

local option_cbac_army_limit_player = mct_mod:add_new_option("army_limit_point_divider", "slider");
option_cbac_army_limit_player:set_text("Army limit");
option_cbac_army_limit_player:set_tooltip_text(
    "The amount the mp-cost of the units get divided by to reach the actual point value (rounded down).\n" ..
    "[[col:yellow]]" .. 
    "All other options have to be adjusted manually with this value in mind.\n" .. 
    "An army limit of 50 with a divider of 200 equals a limit of 10000 with a divider of 1." ..
    "[[/col]]"
);
option_cbac_army_limit_player:slider_set_min_max(1, 1000);
option_cbac_army_limit_player:slider_set_step_size(50);
option_cbac_army_limit_player:set_default_value(200);

local option_cbac_army_limit_player = mct_mod:add_new_option("army_limit_base", "slider");
option_cbac_army_limit_player:set_text("Army limit");
option_cbac_army_limit_player:set_tooltip_text("The amount of points allowed per army.");
option_cbac_army_limit_player:slider_set_min_max(1, 40000);
option_cbac_army_limit_player:slider_set_step_size(1);
option_cbac_army_limit_player:set_default_value(50);

local option_cbac_army_limit_ai = mct_mod:add_new_option("army_limit_ai_adjust", "slider");
option_cbac_army_limit_ai:set_text("AI army limit bonus");
option_cbac_army_limit_ai:set_tooltip_text(
    "The amount of points, that gets applied to the army limit for ai armies.\n" .. 
    "[[col:yellow]]A smaller value will cause AI turns to take longer.[[/col]]"
);
option_cbac_army_limit_ai:slider_set_min_max(-40000, 40000);
option_cbac_army_limit_ai:slider_set_step_size(1);
option_cbac_army_limit_ai:set_default_value(10);

local option_cbac_hero_cap = mct_mod:add_new_option("army_limit_hero_cap", "slider");
option_cbac_hero_cap:set_text("Army hero count");
option_cbac_hero_cap:set_tooltip_text(
    "The amount heroes allowed per army." ..
    "[[col:yellow]]Applies to the player only.[[/col]]"
);
option_cbac_hero_cap:slider_set_min_max(0, 19);
option_cbac_hero_cap:slider_set_step_size(1);
option_cbac_hero_cap:set_default_value(2);

mct_mod:add_new_section("aucm_advanced", "Advanced Options", false);

local option_cbac_logging_enabled = mct_mod:add_new_option("logging_enabled", "checkbox");
option_cbac_logging_enabled:set_text("Enable logging");
option_cbac_logging_enabled:set_default_value(false);
