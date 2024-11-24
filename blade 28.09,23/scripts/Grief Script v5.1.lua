local Config = {}
Config.SubmenuStyle = false
Config.SlamType = 1
Config.SlamHeight = 1
Config.SlamTypes = {"Rhino", "Khanjali", "Halftrack"}
Config.VehicleSpawnGlobal = 2639783
Config.TrickOrTreatBase = 2764906
Config.TrickOrTreatType = Config.TrickOrTreatBase + 579
Config.TrickOrTreatTimer = Config.TrickOrTreatBase + 581
Config.TrickOrTreatTrigger = Config.TrickOrTreatBase + 581 + 1
Config.ExplodeTpBack = true
Config.VehicleTypes = {}
Config.VehicleTypes["Super"] = {"Krieger", "Prototipo", "T20"}
Config.VehicleTypes["Sports"] = {"Kuruma", "Kuruma2"}
Config.VehicleTypes["Sports Classic"] = {"Toreador", "Ardent"}
Config.VehicleTypes["Millitary"] = {"Rhino", "Khanjali", "Halftrack"}
Config.VehicleTypes["Bikes"] = {"Oppressor", "Oppressor2", "Akuma"}
Config.VehicleTypes["Planes"] = {"Hydra", "Lazer", "Titan", "Cargoplane"}
 
-- Function definitions
local function null() end
 
local function Text(submenu, text)
	if (submenu ~= nil) then
		submenu:add_action(text, null)
	else
		menu.add_action(text, null)
	end
end
 
local function sqrt(i)
	return math.sqrt(i)
end
 
local function DistanceToSqr(vec1, vec2)
	return ((vec2.x - vec1.x)^2) + ((vec2.y - vec1.y)^2) + ((vec2.z - vec1.z)^2)
end
 
local function Distance(vec1, vec2)
	return sqrt(DistanceToSqr(vec1, vec2))
end
 
local function floor(num)
	return math.floor(num)
end
 
local function clamp(num, min, max)
	if num > max then return max elseif num < min then return min else return num end
end
-- Player / Ped functions
 
local function IsPlayer(ped)
	if ped == nil or ped:get_pedtype() >= 4 then
		return false
	end
	return true
end
 
local function IsNPC(ped)
	if ped == nil or ped:get_pedtype() < 4 then
		return false
	end
	return true
end
 
local function IsModder(ply)
	if not IsPlayer(ply) then return false end
	
	if ply:get_max_health() < 100 then return true end
	if ply:is_in_vehicle() and ply:get_godmode() then return true end
	if ply:get_run_speed() > 1.0 or ply:get_swim_speed() > 1.0 then return true end
 
	return false
end
 
local function GetPlayerCount()
	return player.get_number_of_players()
end
 
local function createVehicle(modelhash, pos)
	globals.set_int(Config.VehicleSpawnGlobal + 46, modelhash)
	globals.set_float(Config.VehicleSpawnGlobal + 42, pos.x)
	globals.set_float(Config.VehicleSpawnGlobal + 43, pos.y)
	globals.set_float(Config.VehicleSpawnGlobal + 44, pos.z)
	globals.set_boolean(Config.VehicleSpawnGlobal + 41, true)
end
 
-- Action functions
 
local function GiveVehicle(ply, model)
	if not ply or ply == nil then return end 
	local pos = ply:get_position()
	local heading = ply:get_heading()
	createVehicle(joaat(model), pos + heading * 10)
end
 
local function TeleportToPlayer(ply, seconds)
	if not ply or ply == nil then return end 
	local pos = ply:get_position()
	if seconds then
		if localplayer:is_in_vehicle() then return end
 
		local oldpos = localplayer:get_position() 
		local oldgod = localplayer:get_godmode()
		local oldoffradar = menu.get_offradar()
		localplayer:set_godmode(true)
		menu.set_offradar(true)
		localplayer:set_freeze_momentum(true) 
		localplayer:set_config_flag(292,true)
		localplayer:set_position(pos)
	
		sleep(seconds)
	
		localplayer:set_position(oldpos)
		localplayer:set_freeze_momentum(false) 
		localplayer:set_config_flag(292,false)
		if not oldgod then localplayer:set_godmode(false) end
		if not oldoffradar then menu.set_offradar(false) end
		return
	end
 
	if not localplayer:is_in_vehicle() then
		localplayer:set_position(pos)
	else
		localplayer:get_current_vehicle():set_position(pos)
	end
end
 
local function TeleportVehiclesToPlayer(ply)
	if not ply or ply == nil then return end 
 
	local pos = ply:get_position()
	local currentvehicle = nil 
 
	if localplayer:is_in_vehicle() then
		currentvehicle = localplayer:get_current_vehicle()
	end
 
	for veh in replayinterface.get_vehicles() do
		if not currentvehicle or currentvehicle ~= veh then
			veh:set_position(pos)
		end
	end
end
 
local function TeleportClosestVehicleToPlayer(ply)
	if not ply or ply == nil then return end 
 
	local pos = ply:get_position()
	local veh = localplayer:get_nearest_vehicle()
	if not veh then return end
 
	veh:set_position(pos)
end
 
local function TeleportPedsToPlayer(ply, dead)
	if not ply or ply == nil then return end 
 
	local pos = ply:get_position()
	for ped in replayinterface.get_peds() do
		if IsNPC(ped) then
			if not ped:is_in_vehicle() then
				if dead then 
					ped:set_health(0)
				end
				ped:set_position(pos)
			end
		end
	end
end
 
local function ExplodePlayer(ply)
	if not ply or ply == nil then return end 
 
	local pos = ply:get_position()
	local currentvehicle = nil 
 
	if localplayer:is_in_vehicle() then
		currentvehicle = localplayer:get_current_vehicle()
	end
 
	for veh in replayinterface.get_vehicles() do
		if not currentvehicle or currentvehicle ~= veh then
			veh:set_rotation(vector3(0,0,180))
			veh:set_health(-1)
			veh:set_position(pos)
		end
	end
end
 
local function TeleportToAndExplode(ply, mode, bool)
	if not ply or ply == nil then return end 
 
	
	local currentvehicle = nil 
 
	local oldpos = localplayer:get_position() 
	local oldgod = localplayer:get_godmode()
	local oldoffradar = menu.get_offradar()
 
	localplayer:set_godmode(true)
	menu.set_offradar(true)
 
	if mode == 0 then
		localplayer:set_freeze_momentum(true) 
		localplayer:set_config_flag(292,true)
		local pos = ply:get_position()
		localplayer:set_position(pos)
		sleep(0.05)
		globals.set_int(Config.TrickOrTreatType, 0) 
    	globals.set_int(Config.TrickOrTreatTimer, 1000000)
    	globals.set_int(Config.TrickOrTreatTrigger, 1)
	else
		globals.set_int(Config.TrickOrTreatType, 1) 
    	globals.set_int(Config.TrickOrTreatTimer, 1000000)
    	globals.set_int(Config.TrickOrTreatTrigger, 1)
		localplayer:set_freeze_momentum(true) 
		localplayer:set_config_flag(292,true)
		sleep(2)
		local pos = ply:get_position()
		localplayer:set_position(pos)
	end
	sleep(1)
 
	if bool then 
		localplayer:set_position(oldpos)
	end
	localplayer:set_freeze_momentum(false) 
	localplayer:set_config_flag(292,false)
	if not oldgod then localplayer:set_godmode(false) end
	if not oldoffradar then menu.set_offradar(false) end
end
 
local function LaunchPlayer(ply)
	if not ply or ply == nil then return end 
 
	local currentvehicle = nil 
 
	if localplayer:is_in_vehicle() then
		currentvehicle = localplayer:get_current_vehicle()
	end
	local i = 0
	for veh in replayinterface.get_vehicles() do
		if not currentvehicle or currentvehicle ~= veh then
			local pos = ply:get_position()
			veh:set_rotation(vector3(0,0,0))
			veh:set_gravity(-100)
			veh:set_position(vector3(pos.x, pos.y, pos.z - 20))
		end
	end
	sleep(1)
	for veh in replayinterface.get_vehicles() do
		if not currentvehicle or currentvehicle ~= veh then
			local pos = ply:get_position()
			veh:set_gravity(9.8)
		end
	end
end
 
local function SlamPlayer(ply, model)
	if not ply or ply == nil then return end 
 
	if model then 
		createVehicle(joaat(model), ply:get_position() + vector3(0,0,10 * Config.SlamHeight))
		return
	end
 
	local currentvehicle = nil 
 
	if localplayer:is_in_vehicle() then
		currentvehicle = localplayer:get_current_vehicle()
	end
	local i = 0
	for veh in replayinterface.get_vehicles() do
		if not currentvehicle or currentvehicle ~= veh then
			local pos = ply:get_position()
			veh:set_rotation(vector3(0,0,0))
			veh:set_gravity(10000)
			veh:set_position(vector3(pos.x, pos.y, pos.z + 10 * Config.SlamHeight))
		end
	end
	sleep(1)
	for veh in replayinterface.get_vehicles() do
		if not currentvehicle or currentvehicle ~= veh then
			local pos = ply:get_position()
			veh:set_gravity(9.8)
		end
	end
end
 
-- Player option 
local selectedplayer = -1
 
local function f_p_o(ply_id, ply, ply_name) -- Format Player Option Text
	local text = ""
 
	if (player.get_player_ped(ply_id) == nil) then return "**Invalid**" end
 
	-- Player Name
	if ply == localplayer then
		text = text.."YOU"
	else
		text = text..ply_name
	end
 
	if IsModder(ply) then
		text = text.."*"
	end
 
	-- Is In GodMode, if not then Player Health
	if ply:get_godmode() then
		text = text.." | God"
	else
		local max_hp = ply:get_max_health()
		text = text.." | "..floor(clamp((ply:get_health() - 100), 0, max_hp)/(max_hp - 100)*100).."\u{2665}"
		local armour = ply:get_armour()
		if armour > 0 then
			text = text.." | "..floor(ply:get_armour()).."\u{1f455}"
		end
	end
 
	-- Is In Vehicle
	if ply:is_in_vehicle() then
		text = text.." | \u{1F697}"
	end
 
	-- Player Wanted Level
	local wanted = ply:get_wanted_level()
 
	if wanted > 0 then
		text = text.." | "..wanted.."\u{2730}"
	end
	-- Player's Distance From You
	text = text.." | "..floor(Distance(ply:get_position(), localplayer:get_position())).." m"
	
	return text
end
 
local function add_player_option(submenu, ply_id, ply, ply_name)
	
	local text = f_p_o(ply_id, ply, ply_name)
 
	local d = ply_id
 
	if (submenu ~= nil) then
		submenu:add_bare_item(text, function() return f_p_o(ply_id, ply, ply_name).."|"..(selectedplayer == ply_id and "\u{2713}" or "\u{25A1}")  end, function() selectedplayer = d end, null, null)
	else
		menu.add_bare_item(text, function() return f_p_o(ply_id, ply, ply_name).."|"..(selectedplayer == ply_id and "\u{2713}" or "\u{25A1}") end, function() selectedplayer = d end, null, null)
	end
end
 
local function add_info_option(submenu, text, funcget, forceplayer)
 
	local func = function() 
		local ply = player.get_player_ped(forceplayer and forceplayer or selectedplayer)
		if not ply then return text..": **Invalid**" end
 
		return text..": "..funcget(ply)
	end
 
	if (submenu ~= nil) then
		submenu:add_bare_item(text..": ", func, null, null, null)
	else
		menu.add_bare_item(text..": ", func, null, null, null)
	end
end
 
-- Building Player List
local playerlist = nil
local was_opened = true
 
local function BuildListSub() -- Deprecated for the moment
	playerlist:add_bare_item("---AppleVegas's Player List, "..GetPlayerCount().." Players---", function() was_opened = true return "---AppleVegas's Player List, "..GetPlayerCount().." Players---" end, null, null, null)
 
	local popt = {}
	for i = 0, 31 do
		local ply = player.get_player_ped(i)
		if ply then 
			popt[i] = playerlist:add_submenu(f_p_o(i, ply, player.get_player_name(i))) -- add_player_option(playerlist, i, ply, player.get_player_name(i))
			
			add_info_option(popt[i], "Player", function() selectedplayer = i return player.get_player_name(i) end, i)
			local subtp = popt[i]:add_submenu("Teleport Options")
			local subtroll = popt[i]:add_submenu("Trolling Options")
			local subgiveveh = popt[i]:add_submenu("Give Vehicle")
			local subinfo = popt[i]:add_submenu("Player Info")
		
			-- Teleport Options
			add_info_option(subtp, "Player", function() return player.get_player_name(selectedplayer) end)
			subtp:add_action("Teleport To Player", function() TeleportToPlayer(player.get_player_ped(selectedplayer)) end)
			subtp:add_int_range("Teleport To Player Then Back", 1, 1, 5, function() return 2 end, function(n) TeleportToPlayer(player.get_player_ped(selectedplayer), n) end)
			subtp:add_action("Teleport Closest Vehicle To Player", function() TeleportClosestVehicleToPlayer(player.get_player_ped(selectedplayer)) end)
			subtp:add_action("Teleport Vehicles To Player", function() TeleportVehiclesToPlayer(player.get_player_ped(selectedplayer)) end)
			subtp:add_action("Teleport Peds To Player", function() TeleportPedsToPlayer(player.get_player_ped(selectedplayer)) end)
			subtp:add_action("Teleport Dead Peds To Player", function() TeleportPedsToPlayer(player.get_player_ped(selectedplayer), true) end)
		
			--Trolling Options
			add_info_option(subtroll, "Player", function() return player.get_player_name(selectedplayer) end)
			subtroll:add_action("Launch Player", function() LaunchPlayer(player.get_player_ped(selectedplayer)) end)
			subtroll:add_action("Slam Player", function() SlamPlayer(player.get_player_ped(selectedplayer)) end)
			subtroll:add_toggle("Teleport Myself Back", function() return Config.ExplodeTpBack end, function(v) Config.ExplodeTpBack = v end)
			subtroll:add_action("Explode Player (Explosion)", function() TeleportToAndExplode(player.get_player_ped(selectedplayer), 1, Config.ExplodeTpBack) end)
			subtroll:add_action("Explode Player (Send Cars)", function() ExplodePlayer(player.get_player_ped(selectedplayer)) end)
			subtroll:add_action("Up-N-Atomize Player", function() TeleportToAndExplode(player.get_player_ped(selectedplayer), 0, Config.ExplodeTpBack) end)
			subtroll:add_array_item("Slam Player Using", Config.SlamTypes, function() return Config.SlamType end, function(value) Config.SlamType = value SlamPlayer(player.get_player_ped(selectedplayer), Config.SlamTypes[value]) end)
			subtroll:add_int_range("Slam Height", 1, 0, 10, function() return Config.SlamHeight end, function(v) Config.SlamHeight = v end)
 
			--Give Vehicle
			add_info_option(subgiveveh, "Player", function() return player.get_player_name(selectedplayer) end)
			for name,array in pairs(Config.VehicleTypes) do
				local sub = subgiveveh:add_submenu(name)
				for k,model in pairs(array) do
					sub:add_action(model, function() GiveVehicle(player.get_player_ped(selectedplayer), model) end)
				end
			end
			
			-- Info Panel
		
			add_info_option(subinfo, "Player", function() return player.get_player_name(selectedplayer) end)
			add_info_option(subinfo, "Distance from you", function(p) return floor(Distance(p:get_position(), localplayer:get_position())).." m" end)
			add_info_option(subinfo, "Health", function(p) return floor(clamp((p:get_health() - 100), 0, p:get_max_health())/(p:get_max_health() - 100)*100) end)
			add_info_option(subinfo, "Armour", function(p) return floor(p:get_armour()) end)
			add_info_option(subinfo, "Is In Vehicle", function(p) return (p:is_in_vehicle() and "Yes" or "No") end)
			add_info_option(subinfo, "Vehicle Health", function(p) return ((p:is_in_vehicle() and p:get_current_vehicle() ~= nil) and floor(p:get_current_vehicle():get_health()/(p:get_current_vehicle():get_max_health())*100) or 0) end)
			add_info_option(subinfo, "Is In GodMode", function(p) return (p:get_godmode() and "Yes" or "No") end)
			add_info_option(subinfo, "Is Modder", function(p) return (IsModder(p) and "Yes" or "No") end)
			add_info_option(subinfo, "X", function(p) return p:get_position().x end)
			add_info_option(subinfo, "Y", function(p) return p:get_position().y end)
			add_info_option(subinfo, "Z", function(p) return p:get_position().z end)
		end
	end
end
 
local function BuildList()
	playerlist:add_bare_item("---AppleVegas's Player List, "..GetPlayerCount().." Players---", function() was_opened = true return "---AppleVegas's Player List, "..GetPlayerCount().." Players---" end, null, null, null)
 
	for i = 0, 31 do
		local ply = player.get_player_ped(i)
		if ply then 
			add_player_option(playerlist, i, ply, player.get_player_name(i))
		end
	end
 
	Text(playerlist, "---End---")
 
	local subtp = playerlist:add_submenu("Teleport Options")
	local subtroll = playerlist:add_submenu("Trolling Options")
	local subgiveveh = playerlist:add_submenu("Give Vehicle")
	local subinfo = playerlist:add_submenu("Player Info")
 
	-- Teleport Options
	add_info_option(subtp, "Player", function() return player.get_player_name(selectedplayer) end)
	subtp:add_action("Teleport To Player", function() TeleportToPlayer(player.get_player_ped(selectedplayer)) end)
	subtp:add_int_range("Teleport To Player Then Back", 1, 1, 5, function() return 2 end, function(n) TeleportToPlayer(player.get_player_ped(selectedplayer), n) end)
	subtp:add_action("Teleport Closest Vehicle To Player", function() TeleportClosestVehicleToPlayer(player.get_player_ped(selectedplayer)) end)
	subtp:add_action("Teleport Vehicles To Player", function() TeleportVehiclesToPlayer(player.get_player_ped(selectedplayer)) end)
	subtp:add_action("Teleport Peds To Player", function() TeleportPedsToPlayer(player.get_player_ped(selectedplayer)) end)
	subtp:add_action("Teleport Dead Peds To Player", function() TeleportPedsToPlayer(player.get_player_ped(selectedplayer), true) end)
 
	--Trolling Options
	add_info_option(subtroll, "Player", function() return player.get_player_name(selectedplayer) end)
	subtroll:add_action("Launch Player", function() LaunchPlayer(player.get_player_ped(selectedplayer)) end)
	subtroll:add_action("Slam Player", function() SlamPlayer(player.get_player_ped(selectedplayer)) end)
	subtroll:add_toggle("Teleport Myself Back", function() return Config.ExplodeTpBack end, function(v) Config.ExplodeTpBack = v end)
	subtroll:add_action("Explode Player (Explosion)", function() TeleportToAndExplode(player.get_player_ped(selectedplayer), 1, Config.ExplodeTpBack) end)
	subtroll:add_action("Explode Player (Send Cars)", function() ExplodePlayer(player.get_player_ped(selectedplayer)) end)
	subtroll:add_action("Up-N-Atomize Player", function() TeleportToAndExplode(player.get_player_ped(selectedplayer), 0, Config.ExplodeTpBack) end)
	subtroll:add_array_item("Slam Player Using", Config.SlamTypes, function() return Config.SlamType end, function(value) Config.SlamType = value SlamPlayer(player.get_player_ped(selectedplayer), Config.SlamTypes[value]) end)
	subtroll:add_int_range("Slam Height", 1, 0, 10, function() return Config.SlamHeight end, function(v) Config.SlamHeight = v end)
	
	--Give Vehicle
	add_info_option(subgiveveh, "Player", function() return player.get_player_name(selectedplayer) end)
	for name,array in pairs(Config.VehicleTypes) do
		local sub = subgiveveh:add_submenu(name)
		for k,model in pairs(array) do
			sub:add_action(model, function() GiveVehicle(player.get_player_ped(selectedplayer), model) end)
		end
	end
	
	-- Info Panel
 
	add_info_option(subinfo, "Player", function() return player.get_player_name(selectedplayer) end)
	add_info_option(subinfo, "Distance from you", function(p) return floor(Distance(p:get_position(), localplayer:get_position())).." m" end)
	add_info_option(subinfo, "Health", function(p) return floor(clamp((p:get_health() - 100), 0, p:get_max_health())/(p:get_max_health() - 100)*100) end)
	add_info_option(subinfo, "Armour", function(p) return floor(p:get_armour()) end)
	add_info_option(subinfo, "Is In Vehicle", function(p) return (p:is_in_vehicle() and "Yes" or "No") end)
	add_info_option(subinfo, "Vehicle Health", function(p) return ((p:is_in_vehicle() and p:get_current_vehicle() ~= nil) and floor(p:get_current_vehicle():get_health()/(p:get_current_vehicle():get_max_health())*100) or 0) end)
	add_info_option(subinfo, "Is In GodMode", function(p) return (p:get_godmode() and "Yes" or "No") end)
	add_info_option(subinfo, "Is Modder", function(p) return (IsModder(p) and "Yes" or "No") end)
	add_info_option(subinfo, "X", function(p) return p:get_position().x end)
	add_info_option(subinfo, "Y", function(p) return p:get_position().y end)
	add_info_option(subinfo, "Z", function(p) return p:get_position().z end)
end
 
-- List Updater
 
local function Update()
	playerlist:clear() 
	if Config.SubmenuStyle then 
		BuildListSub() 
	else 
		BuildList() 
	end
end
 
playerlist = menu.add_submenu("GriefScript - v5.0", Update)