local move_button_left = 294
local move_button_right = 290
local move_button_forward = 288
local move_button_back = 292
local modifier_button = 160

dataref("head_x", "sim/graphics/view/pilots_head_x", "writable")
dataref("head_y", "sim/graphics/view/pilots_head_y", "writable")
dataref("head_z", "sim/graphics/view/pilots_head_z", "writable")
dataref("head_psi", "sim/graphics/view/pilots_head_psi")

local base_move_speed = 0.01
local max_move_speed = 0.05  -- Maximum speed (4x base speed)
local current_move_speed = base_move_speed
local movement_start_time = 0
local is_moving = false
local speed_ramp_duration = 1.5  -- Time in seconds to reach max speed

function move_camera_if_pressed()
    local any_button_pressed = false

    -- Check if any movement button is pressed
    if button(move_button_forward) or button(move_button_back) or
       (button(modifier_button) and (button(move_button_left) or button(move_button_right))) then
        any_button_pressed = true
    end

    -- Handle speed ramping
    if any_button_pressed then
        if not is_moving then
            -- Just started moving
            is_moving = true
            movement_start_time = os.clock()
            current_move_speed = base_move_speed
        else
            -- Calculate speed based on how long we've been moving
            local time_moving = os.clock() - movement_start_time
            local speed_factor = math.min(time_moving / speed_ramp_duration, 1.0)
            current_move_speed = base_move_speed + (max_move_speed - base_move_speed) * speed_factor
        end
    else
        -- Reset when no buttons are pressed
        is_moving = false
        current_move_speed = base_move_speed
    end

    -- Apply movement with current speed
    if not button(modifier_button) then
        if button(move_button_forward) then
            head_y = head_y + current_move_speed  -- Move up
        end

        if button(move_button_back) then
            head_y = head_y - current_move_speed  -- Move down
        end
    end

    if button(modifier_button) then
        -- Convert heading from degrees to radians
        local heading_rad = math.rad(head_psi)

        -- Calculate forward/back movement relative to view direction
        if button(move_button_forward) then
            head_x = head_x + math.sin(heading_rad) * current_move_speed
            head_z = head_z - math.cos(heading_rad) * current_move_speed
        end

        if button(move_button_back) then
            head_x = head_x - math.sin(heading_rad) * current_move_speed
            head_z = head_z + math.cos(heading_rad) * current_move_speed
        end

        -- Calculate left/right strafe movement (perpendicular to view direction)
        if button(move_button_left) then
            head_x = head_x - math.cos(heading_rad) * current_move_speed
            head_z = head_z - math.sin(heading_rad) * current_move_speed
        end

        if button(move_button_right) then
            head_x = head_x + math.cos(heading_rad) * current_move_speed
            head_z = head_z + math.sin(heading_rad) * current_move_speed
        end
    end
end

do_every_frame("move_camera_if_pressed()")
