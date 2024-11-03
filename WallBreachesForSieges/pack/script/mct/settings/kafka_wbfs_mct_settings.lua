if not get_mct then
    return
end
local mct = get_mct();
if not mct then
    return
end

local mct_mod = mct:register_mod("kafka_wbfs")

mct_mod:set_title("Wall Breaches for Sieges ", false);
mct_mod:set_author("Kafka");
mct_mod:set_description("Creates wall breaches during a siege", false);

local option_apply_to_player = mct_mod:add_new_option("apply_to_player", "checkbox");
option_apply_to_player:set_text("Applies to human players");
option_apply_to_player:set_tooltip_text("Create breaches for attacking human players.");
option_apply_to_player:set_default_value(true);

local option_apply_to_ai = mct_mod:add_new_option("apply_to_ai", "checkbox");
option_apply_to_ai:set_text("Applies to ai");
option_apply_to_ai:set_tooltip_text("Create breaches for attacking ai players.");
option_apply_to_ai:set_default_value(false);

local option_breaches_count = mct_mod:add_new_option("breaches_count", "slider");
option_breaches_count:set_text("Breaches");
option_breaches_count:set_tooltip_text("Total amount of wall segments, that will be destroyed.");
option_breaches_count:slider_set_min_max(0, 99);
option_breaches_count:slider_set_step_size(1);
option_breaches_count:set_default_value(6);