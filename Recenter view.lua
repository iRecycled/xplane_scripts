local reset_pending = false
local reset_timer_frames = 0

-- Cockpit view restore variables
local cockpit_restore_pending = false
local cockpit_restore_timer = 0

-- Popup message variables
local popup_message = ""
local popup_show_until = 0

-- Camera position datarefs
dataref("head_x", "sim/graphics/view/pilots_head_x", "writable")
dataref("head_y", "sim/graphics/view/pilots_head_y", "writable")
dataref("head_z", "sim/graphics/view/pilots_head_z", "writable")
dataref("head_pitch", "sim/graphics/view/pilots_head_the")
dataref("head_heading", "sim/graphics/view/pilots_head_psi")

-- Store home position
local home_x = 0
local home_y = 0
local home_z = 0
local home_pitch = 0
local home_heading = 0

function save_current_position()
    -- Set quick_look_0 to save current FOV
    command_once("sim/view/quick_look_0_mem")

    -- Save position and angles
    home_x = head_x
    home_y = head_y
    home_z = head_z
    home_pitch = head_pitch
    home_heading = head_heading

    logMsg("Recenter View: Set quick_look_0 and saved position - x=" .. tostring(home_x) ..
           ", y=" .. tostring(home_y) .. ", z=" .. tostring(home_z) ..
           ", pitch=" .. tostring(home_pitch) .. ", heading=" .. tostring(home_heading))
    -- Show popup message
    popup_message = "Home position saved"
    popup_show_until = os.clock() + 3
end

function reset_cockpit_view()
    local view_type = get("sim/graphics/view/view_type")
    local aircraft_icao = get("sim/aircraft/view/acf_ICAO")
    local aircraft_filename = get("sim/aircraft/view/acf_descrip")
    
    logMsg("DEBUG: Current view_type is: " .. tostring(view_type))
    logMsg("DEBUG: Aircraft ICAO: " .. tostring(aircraft_icao))
    logMsg("DEBUG: Aircraft filename: " .. tostring(aircraft_filename))
    
    -- Add debug info about view range checks
    logMsg("DEBUG: Checking conditions...")
    logMsg("DEBUG: view_type == 1026? " .. tostring(view_type == 1026))
    logMsg("DEBUG: view_type == 1017 or 1015? " .. tostring(view_type == 1017 or view_type == 1015))
    logMsg("DEBUG: view_type >= 1000 and <= 1016? " .. tostring(view_type >= 1000 and view_type <= 1016))
    
    if view_type == 1026 then
        logMsg("Inside cockpit view reset to center")
        -- First, trigger quick_look_0 to reset FOV and view angles
        command_once("sim/view/quick_look_0")
        -- Then schedule position restore after a few frames
        cockpit_restore_pending = true
        cockpit_restore_timer = 5  -- Wait 5 frames for quick_look to take effect
        logMsg("Triggered quick_look_0, will restore position in 5 frames")
        -- Show popup message
        popup_message = "View restored to home"
        popup_show_until = os.clock() + 3
    elseif view_type == 1017 or view_type == 1015 then
        logMsg("EXECUTING: In runway/circle view — prepping to reset chase view")
        reset_pending = true
        reset_timer_frames = 3  -- Wait ~3 frames (~0.05 sec)
        command_once("sim/view/default_view")
        command_once("sim/view/quick_look_0")
        -- command_once("sim/view/forward_with_panel")
    else
        logMsg("NO ACTION: Not in recognized view (type: " .. tostring(view_type) .. ") — no reset done")
        logMsg("DEBUG: This view_type is outside all our conditions")
    end
    
    logMsg("DEBUG: Function reset_cockpit_view() completed")
end

function reset_chase_logic()
    if reset_pending then
        reset_timer_frames = reset_timer_frames - 1
        if reset_timer_frames <= 0 then
            logMsg("Switching back to chase view now")
            command_once("sim/view/chase")
            reset_pending = false
        end
    end

    -- Handle delayed cockpit position restore
    if cockpit_restore_pending then
        cockpit_restore_timer = cockpit_restore_timer - 1
        if cockpit_restore_timer <= 0 then
            logMsg("Restoring saved position now")
            -- Restore only position (X, Y, Z) - quick_look already handled FOV and angles
            head_x = home_x
            head_y = home_y
            head_z = home_z
            cockpit_restore_pending = false
            logMsg("Position restored to x=" .. tostring(home_x) .. ", y=" .. tostring(home_y) .. ", z=" .. tostring(home_z))
        end
    end
end

do_every_frame("reset_chase_logic()")

-- Draw popup message
function draw_popup()
    if os.clock() < popup_show_until and popup_message ~= "" then
        local FONTSIZE = 18
        local boxWidth = FONTSIZE * 15
        local boxHeight = FONTSIZE * 2
        local xpos = SCREEN_WIDTH - boxWidth - 50
        local ypos = SCREEN_HEIGHT - boxHeight - 100

        -- Draw background box
        graphics.set_color(0, 0, 0, 0.7)
        graphics.draw_rectangle(xpos, ypos, xpos + boxWidth, ypos + boxHeight)

        -- Draw text
        graphics.set_color(1.0, 1.0, 1.0, 1.0)
        local xoffset = (boxWidth - measure_string(popup_message, "Helvetica_" .. FONTSIZE)) * 0.5
        draw_string(xpos + xoffset, ypos + FONTSIZE * 0.5, popup_message, "Helvetica_" .. FONTSIZE)
    end
end

do_every_draw("draw_popup()")

create_command(
    "FlyWithLua/reset_cockpit_view",
    "Reset view based on current camera mode",
    "reset_cockpit_view()",
    "",
    ""
)

create_command(
    "FlyWithLua/save_home_position",
    "Save current position as home and set quick look 0",
    "save_current_position()",
    "",
    ""
)

-- Save initial position when script loads
save_current_position()