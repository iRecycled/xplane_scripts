--------------------------------------------------------------------------------
-- Downed aircraft : prevent respawn :

print("[Ground Equipment " .. version_text_SGES .. "] Loading respawn prevention module from Simple Ground Equipment and Services")

-----------------------------------------------------------------------
--~ I have a problem in X-Plane 12. When AI got shot down by missile, they often go into a crazy whirling when they meet the ground. At this moment, X-Plane crashes.to the desktop, and outputs in the Log a fatal flight model error associated with the throttle management. In 12.07. So the combat actually is dangerous because at any moment a CTD can happen. I didn't have that before. I tested with the default F4 Phantom selected as AI aircraft after having got the problem with many AI models and still the same prob.
--~ I am coding an anti respawn function which captures the aircraft so hopefully I can catch any aircraft approaching the ground vicinity and disable it before the infamous whirling occurs. In order to be effective, I will need to capture the aircraft high enough above the ground though.
--~ https://forums.x-plane.org/index.php?/forums/topic/298110-fatal-flight-model-error-when-downed-ai-aircraft-reach-the-ground-and-depart-from-stable-flying/#comment-2643326
-----------------------------------------------------------------------

-- load the XPLM library
local ffi = require("ffi")

-- find the right lib to load
local XPLMlib = ""
if SYSTEM == "IBM" then
	-- Windows OS (no path and file extension needed)
	if SYSTEM_ARCHITECTURE == 64 then
			XPLMlib = "XPLM_64"  -- 64bit
	else
			XPLMlib = "XPLM"     -- 32bit
	end
elseif SYSTEM == "LIN" then
	-- Linux OS (we need the path "Resources/plugins/" here for some reason)
	if SYSTEM_ARCHITECTURE == 64 then
			XPLMlib = "Resources/plugins/XPLM_64.so"  -- 64bit
	else
			XPLMlib = "Resources/plugins/XPLM.so"     -- 32bit
	end
elseif SYSTEM == "APL" then
	-- Mac OS (we need the path "Resources/plugins/" here for some reason)
	XPLMlib = "Resources/plugins/XPLM.framework/XPLM" -- 64bit and 32 bit
else
	return -- this should not happen
end

-- load the lib and store in local variable
local XPLM = ffi.load(XPLMlib)
local w1 = ffi.new("int[1]")
local w2 = ffi.new("int[1]")
local w3 = ffi.new("int[1]")
local AIRCRAFT_FILENAME = ffi.new("char[1024]")
local AIRCRAFT_PATH = ffi.new("char[1024]")
local PLANE_COUNT
local PLANE_TOTAL
local PLANE_PLUGIN
ffi.cdef("typedef int XPLMPluginID")
ffi.cdef("void XPLMCountAircraft (int * outPLANE_COUNT, int * outPLANE_TOTAL, XPLMPluginID * outController)")
ffi.cdef("typedef void (* XPLMPlanesAvailable_f)(void * inRefcon)")
ffi.cdef("int XPLMAcquirePlanes ( char ** inAIRCRAFT_PATH, XPLMPlanesAvailable_f inCallback, void * inRefcon)")
ffi.cdef("void XPLMDisableAIForPlane (int inAI)")
ffi.cdef("void XPLMReleasePlanes(void)")
ffi.cdef("void XPLMSetActiveAircraftCount(int  inAct)")
ffi.cdef("void XPLMGetNthAircraftModel(int  inIndex,  char * outFileName, char * outPath)")
XPLM.XPLMCountAircraft (w1 , w2 , w3)
PLANE_COUNT, PLANE_TOTAL, PLANE_PLUGIN = w1[0], w2[0], w3[0]
local ground_intersection

function AcquireAircraft_sges()
	XPLM.XPLMCountAircraft (w1 , w2 , w3)
	PLANE_COUNT, PLANE_TOTAL, PLANE_PLUGIN = w1[0], w2[0], w3[0]
	local ai_plane_array = ffi.new("char *[7]")
	for i = 1, PLANE_COUNT-1 do  --  Grab the AI Plane details
		--~ print("[Ground Equipment " .. version_text_SGES .. "] Acquire i " .. i )
		if disabled_planes["plane" .. i] == 2  then
			-- elevate all aircraft to avoid the infamous XP12 CTD near the grounnd with airplanes whirling
			set("sim/multiplayer/position/plane" .. i .. "_y", ground_intersection + 6 * sges_capture_elevation_threshold)
			set("sim/multiplayer/position/plane" .. i .. "_the",0)
			set("sim/multiplayer/position/plane" .. i .. "_phi",0)
			set("sim/multiplayer/position/plane" .. i .. "_psi",0)
			set("sim/multiplayer/position/plane" .. i .. "_throttle",0,0.5)
		end
		XPLM.XPLMGetNthAircraftModel(i, AIRCRAFT_FILENAME, AIRCRAFT_PATH)
		ai_plane_array[i] = AIRCRAFT_PATH
	end
	XPLM.XPLMAcquirePlanes(ai_plane_array, acquire_planes_callback, nil)
	XPLM.XPLMSetActiveAircraftCount(1)
end
function ReleaseAircraft_sges()
	print("[Ground Equipment " .. version_text_SGES .. "] SGES Release AI aircraft. Total PLANE_COUNT " .. PLANE_COUNT)
	XPLM.XPLMReleasePlanes()
	XPLM.XPLMCountAircraft (w1 , w2 , w3)
	PLANE_COUNT, PLANE_TOTAL, PLANE_PLUGIN = w1[0], w2[0], w3[0]
	XPLM.XPLMSetActiveAircraftCount(PLANE_COUNT)
	disabled_planes = {plane1=-1,plane2=-1,plane3=-1,plane4=-1,plane5=-1,plane6=-1,plane7=-1,plane8=-1,plane9=-1,plane10=-1,plane11=-1,plane12=-1,plane13=-1,plane14=-1,plane15=-1,plane16=-1,plane17=-1,plane18=-1,plane19=-1}
end
--~ Note There is no enableAIForPlane() function: you cannot simple re-enable AI.
--~ However, if you acquire all planes, set the active count to 1 (User aircraft only) and
--~ then reset the count to something larger than 1, all of the added aircraft will have their AI re-enabled once you call xp.releasePlanes()


-- we have the airplane multiplayer sim/multiplayer/position/plane1_el
	--~ sim/multiplayer/position/plane1_el	double	n	meters
	-- for active plane this value is above zero, otherwise is negative

-- we can sense the ground elevation below the active plane regularly
-- I'm doing a simlification : sense the ground elvel at user aircraft, to sense if we are in the Himalaya, or over the sea, that should be sufficient to trigger the down status

-- if the elevation and ground are the same, remove the aircraft from the game

-- declare the datarefs in a table we will watch
 plane_y = {plane1=-1,Plane2=-1,plane3=-1,plane4=-1,plane5=-1,plane6=-1,plane7=-1,plane8=-1,plane9=-1,plane10=-1,plane11=-1,plane12=-1,plane13=-1,plane14=-1,plane15=-1,plane16=-1,plane17=-1,plane18=-1,plane19=-1}
ground_intersectionation_meters = {plane1=-1,Plane2=-1,plane3=-1,plane4=-1,plane5=-1,plane6=-1,plane7=-1,plane8=-1,plane9=-1,plane10=-1,plane11=-1,plane12=-1,plane13=-1,plane14=-1,plane15=-1,plane16=-1,plane17=-1,plane18=-1,plane19=-1}
disabled_planes = {plane1=-1,plane2=-1,plane3=-1,plane4=-1,plane5=-1,plane6=-1,plane7=-1,plane8=-1,plane9=-1,plane10=-1,plane11=-1,plane12=-1,plane13=-1,plane14=-1,plane15=-1,plane16=-1,plane17=-1,plane18=-1,plane19=-1}
local j=1
for j=1,19 do
	plane_y["plane" .. j] = dataref_table("sim/multiplayer/position/plane" .. j .. "_y")
end

-- watch the AI elevations
function watch_AI_altitudes()
	if PLANE_COUNT > 1 then
		local i=1
		for i=1,PLANE_COUNT-0 do
			if disabled_planes["plane" .. i] == -1  then
				ground_intersection,_ = probe_y (get("sim/multiplayer/position/plane" .. i .. "_x"), get("sim/multiplayer/position/plane" .. i .. "_y"), get("sim/multiplayer/position/plane" .. i .. "_z"))
				--~ print("Aircraft " .. i+1 .. " ground_intersection is " .. math.floor(ground_intersection) .. "ua and aircraft y is " .. math.floor(plane_y["plane" .. i][0]) .. "ua." .. disabled_planes["plane" .. i] )
				if plane_y["plane" .. i][0] < ground_intersection + sges_capture_elevation_threshold then -- THE ACFT IS DOWN
					-- disabled it from the sim
					disabled_planes["plane" .. i] = 2
					print("[Ground Equipment " .. version_text_SGES .. "] Going to disable AIRCRAFT " .. i+1 .. "...")
					XPLM.XPLMDisableAIForPlane(i)
					-- put that in a smi-buried attitude :
					set("sim/multiplayer/position/plane" .. i .. "_y",ground_intersection-2)
					set("sim/multiplayer/position/plane" .. i .. "_the",-45)
					set("sim/multiplayer/position/plane" .. i .. "_phi",90)
					set("sim/multiplayer/position/plane" .. i .. "_psi",0)
					set("sim/multiplayer/position/plane" .. i .. "_throttle",0,0)
					print("[Ground Equipment " .. version_text_SGES .. "] Disabled AIRCRAFT " .. i+1 .. " (KIA).")
				end
			end
		end
	end
end

function watch_AI_count()
	if PLANE_COUNT <= 2 then
		XPLM.XPLMCountAircraft (w1 , w2 , w3)
		PLANE_COUNT, PLANE_TOTAL, PLANE_PLUGIN = w1[0], w2[0], w3[0]
	end
end

do_sometimes("if prevent_respawn and SGES_XPlaneIsPaused == 0  then watch_AI_count() end")
do_often("if prevent_respawn and SGES_XPlaneIsPaused == 0  then watch_AI_altitudes() end")
sges_respawn_loaded = true


