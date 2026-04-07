-- CL650 ATS Throttle Disconnect
-- When ATS is disengaged via the glareshield button, automatically triggers
-- both throttle disconnect buttons (L+R) to fully disengage auto-throttle.
-- No custom command needed — just use CL650/glareshield/ATS as normal.

if PLANE_ICAO ~= "CL60" then return end

dataref("ats_lamp", "CL650/lamps/glareshield/ats_L")

ats_was_on = false
ats_disc_frames = -1

function cl650_ats_monitor()
    local ats_on = ats_lamp > 0.5

    -- ATS just turned off — trigger throttle disconnect
    if ats_was_on and not ats_on then
        command_begin("CL650/pedestal/throttle/at_disc_L")
        command_begin("CL650/pedestal/throttle/at_disc_R")
        ats_disc_frames = 0
    end

    -- Release disconnect buttons after a few frames
    if ats_disc_frames >= 0 then
        ats_disc_frames = ats_disc_frames + 1
        if ats_disc_frames > 3 then
            command_end("CL650/pedestal/throttle/at_disc_L")
            command_end("CL650/pedestal/throttle/at_disc_R")
            ats_disc_frames = -1
        end
    end

    ats_was_on = ats_on
end

do_every_frame("cl650_ats_monitor()")
