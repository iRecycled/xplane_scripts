-- CL650 AP Engage/Disconnect Toggle
-- Simulates a held button press for ap_eng, and a double press for ap_disc.
-- Bind a button to FWL/cl650_ap_eng_hold in MobiFlight or X-Plane settings.

if PLANE_ICAO ~= "CL60" then return end

dataref("ap_eng_lamp", "CL650/lamps/glareshield/FCP/ap_eng_1")

HOLD_FRAMES = 3
ap_frames = -1
ap_phase = 0
ap_mode = ""

create_command("FWL/cl650_ap_eng_hold", "CL650 AP ENG or DISC toggle",
    "if ap_eng_lamp > 0.5 then ap_mode = \"disc\" else ap_mode = \"eng\" end " ..
    "command_begin(\"CL650/FCP/ap_\" .. ap_mode) ap_frames = 0 ap_phase = 0",
    "", ""
)

function cl650_ap_tick()
    if ap_frames < 0 then return end
    ap_frames = ap_frames + 1
    if ap_frames <= HOLD_FRAMES then return end

    command_end("CL650/FCP/ap_" .. ap_mode)

    -- ap_eng only needs one press; ap_disc needs two (pull down, then release back up)
    if ap_mode == "eng" or ap_phase == 1 then
        ap_frames = -1
        ap_phase = 0
    else
        ap_phase = 1
        ap_frames = -HOLD_FRAMES  -- brief gap before second press
        command_begin("CL650/FCP/ap_disc")
    end
end

do_every_frame("cl650_ap_tick()")
