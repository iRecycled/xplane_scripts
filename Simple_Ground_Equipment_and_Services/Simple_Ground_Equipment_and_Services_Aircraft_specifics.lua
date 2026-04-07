-- /////////////////////////////////////////// --
-- This script contains aircraft specific stuff.
-- This stuff is only triggered when a specific
-- aircraft type or X-Plane model is detected.
-- /////////////////////////////////////////// --


-- /////////////////////////////////////////// --
-- Define some functions for the Zibo B738 or LevelUp 737NG Series
if string.match(PLANE_ICAO,"B73") and string.find(PLANE_AUTHOR,"Unruh")  then

	function ZIBOToggleGPU()
			command_once("laminar/B738/tab/home")
			command_once("laminar/B738/tab/menu6") -- ground services
			command_once("laminar/B738/tab/menu1") -- GPU icon
	end
	show_Zibo_Chocks = false
	function ZIBOToggleChocks()
			command_once("laminar/B738/tab/home")
			command_once("laminar/B738/tab/menu6") -- ground services
			command_once("laminar/B738/tab/menu2") -- Chocks icon
	end
	function ZIBOToggleASU()
			command_once("laminar/B738/tab/home")
			command_once("laminar/B738/tab/menu6") -- ground services
			command_once("laminar/B738/tab/menu4") -- ASU icon
	end
	function ZIBOToggleStairs()
			command_once("laminar/B738/tab/home")
			command_once("laminar/B738/tab/menu6") -- ground services
			command_once("laminar/B738/tab/menu6") -- Stairs icon
	end
	function ZIBOToggleStairsOption()
			command_once("laminar/B738/tab/home")
			command_once("laminar/B738/tab/right") -- right
			command_once("laminar/B738/tab/menu1") -- Configure
			command_once("laminar/B738/tab/menu1") -- Configure
			command_once("laminar/B738/tab/menu1") -- Configure
			command_once("laminar/B738/tab/menu1") -- Configure
			command_once("laminar/B738/tab/line2") -- Airstairs
	end
	function ZIBOToggleServicesOption()
			command_once("laminar/B738/tab/home")
			command_once("laminar/B738/tab/right") -- ground services
			command_once("laminar/B738/tab/menu1") -- Configure
			command_once("laminar/B738/tab/menu5") -- General config
			command_once("laminar/B738/tab/right") -- Right
			command_once("laminar/B738/tab/line5") -- Built-in GND SERV  ZIBO V4.03.08 Dec 2024
	end
	if XPLMFindDataRef("laminar/B738/fwd_stairs_hide") ~= nil and  XPLMFindDataRef("laminar/B738/aft_stairs_hide") ~= nil and XPLMFindDataRef("737u/doors/L1") ~= nil and XPLMFindDataRef("737u/doors/L2") ~= nil then

		sges_zibodoorhandling1 		= dataref_table("laminar/B738/fwd_stairs_hide")
		sges_zibodoorhandling2 		= dataref_table("laminar/B738/aft_stairs_hide")
		sges_zibodoorhandling3 		= dataref_table("737u/doors/L1")
		sges_zibodoorhandling4 		= dataref_table("737u/doors/L2")


		function sges_zibodoorhandling()
			-- if FWD door open and fwd_stairs_hide == 0 then print an alert ro remove the SGES stairs
			if sges_zibodoorhandling3[1] > 0 and sges_zibodoorhandling1[1] == 0 then
				show_StairsXPJ = false
				StairsXPJ_chg = true
			end

			-- if AFT door open and aft_stairs_hide == 0 then print an alert ro remove the SGES stairs
			if sges_zibodoorhandling4[1] > 0 and sges_zibodoorhandling2[1] == 0 then
				show_StairsXPJ2 = false
				StairsXPJ2_chg = true
			end

			if show_Bus and (sges_zibodoorhandling1[1] == 0 or sges_zibodoorhandling2[1] == 0) then
				show_Bus = false
				Bus_chg = true
			end
		end
		do_sometimes("sges_zibodoorhandling()")

	end
end
-- /////////////////////////////////////////// --



-- /////////////////////////////////////////// --
-- X-Trident AW 109 : remove the engine and pitot covers
if IsXPlane12 and SGES_IsHelicopter == 1 and AIRCRAFT_FILENAME == "AW109SP.acf" then
	-- avoid setting engine on fire by inadvertance
	set("aw109/anim/rbf/engine1_cover",0)
	set("aw109/anim/rbf/engine1_plug",0)
	set("aw109/anim/rbf/engine2_cover",0)
	set("aw109/anim/rbf/engine2_plug",0)
	-- I dont remove all remove before flight flags, just the ones relative to the engines.
end
-- I don't like the cones for the X-Trident May 2024 A109.
if AIRCRAFT_FILENAME == "AW109SP.acf" and PLANE_AUTHOR == "X-Trident" then
	show_Cones = false Cones_chg = true
	show_Chocks = true Chocks_chg = true
	print("[Ground Equipment " .. version_text_SGES .. "] Applying " .. PLANE_AUTHOR .. " " .. AIRCRAFT_FILENAME .. " startup (no cones, chocks set).")
end
-- /////////////////////////////////////////// --


-- /////////////////////////////////////////// --
-- Q4XP FlyJSim DH8D
if IsXPlane12 and AIRCRAFT_FILENAME == "Q4XP.acf" then
	print("[Ground Equipment " .. version_text_SGES .. "] Applying " .. PLANE_AUTHOR .. " " .. AIRCRAFT_FILENAME .. " startup specifics.")
	set_array("FJS/Q4XP/Manips/CockpitDoor_Anim",0,0)
	--~ set_array("FJS/Q4XP/Manips/JumpSeat_Anim",0,0)
end
-- /////////////////////////////////////////// --

-- /////////////////////////////////////////// --
-- Personnal variant of the PC-12
--~ if string.match(PLANE_ICAO,"PC12") and string.match(AIRCRAFT_FILENAME,"Thranda_PC12") and  XPLMFindDataRef("thranda/cockpit/animations/windowmanip") ~= nil then
	--~ set_array("thranda/cockpit/animations/windowmanip",23,1)
	--~ set_array("thranda/cockpit/animations/windowmanip",24,1)
	--~ set_array("thranda/cockpit/animations/windowmanip",25,1)
	--~ set_array("thranda/cockpit/animations/windowmanip",26,1)
	--~ set_array("thranda/cockpit/animations/windowmanip",27,1)
	--~ set_array("thranda/cockpit/animations/windowmanip",28,1)
	--~ set_array("thranda/cockpit/animations/windowmanip",29,1)
	--~ set_array("thranda/cockpit/animations/windowmanip",30,1)
	--~ print("[Ground Equipment " .. version_text_SGES .. "] Applying " .. PLANE_AUTHOR .. " " .. AIRCRAFT_FILENAME .. " startup (closing shades).")
--~ end
-- /////////////////////////////////////////// --

-- /////////////////////////////////////////// --
-- # Mirror fuel, and passenger car/bus position around the aircraft longitudinal axis.
-- Usually this should and shall be done in the aircraft configuraiton file or the user profile.
-- Demonstrator for the Diamond DA20
--~ if PLANE_ICAO == "DV20" then
	--~ SGES_mirror = 1
--~ end
-- /////////////////////////////////////////// --



-- /////////////////////////////////////////// --
-- Aircraft with a cargo hold on the left hand side
-- For instance, the Dash-8, the CRJ, the ERJ-140.
-- Do not touch if not necessary, many regional airliners
-- are already taken care of (outside of the code below).

if PLANE_ICAO == "E45X" -- EMBRAER	ERJ-145XR
or PLANE_ICAO == "E45Y" -- Replace E45Y by your new favourite aircraft code with the cargo hold on the port side -- See https://www.icao.int/publications/DOC8643/Pages/Search.aspx
then
	plane_has_cargo_hold_on_the_left_hand_side = true
	print("[Ground Equipment " .. version_text_SGES .. "] " .. PLANE_AUTHOR .. " " .. AIRCRAFT_FILENAME .. " : plane_has_cargo_hold_on_the_left_hand_side = true.")
end
-- /////////////////////////////////////////// --
