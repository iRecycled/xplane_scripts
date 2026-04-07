function toggle_view()
    local view_type = get("sim/graphics/view/view_type")
    local aircraft_icao = get("sim/aircraft/view/acf_ICAO")
   
    if view_type == 1026 then
        logMsg("Switching to chase view from cockpit")
        command_once("sim/view/chase")
    else
        logMsg("Switching to cockpit view from chase or other view")
        command_once("sim/view/default_view")
        command_once('sim/view/quick_look_0')
    end
end

create_command("FlyWithLua/toggle_custom_view", "Toggle custom view", "toggle_view()", "", "")