PlaytimeDB = PlaytimeDB or {}

local function unregisterTimePlayedEvents()
	local saved = {}
	for i = 1, NUM_CHAT_WINDOWS do
		local cf = _G["ChatFrame"..i]
		if cf:IsEventRegistered("TIME_PLAYED_MSG") then
			saved[i] = true
			cf:UnregisterEvent("TIME_PLAYED_MSG")
		end
	end
	return saved
end

local function restoreTimePlayedEvents(saved)
	for i = 1, NUM_CHAT_WINDOWS do
		if saved[i] then
			_G["ChatFrame"..i]:RegisterEvent("TIME_PLAYED_MSG")
		end
	end
end

local function secondsToDays(seconds)
	local days = math.floor(seconds / 86400)
	local hours = math.floor((seconds % 86400) / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	local secs = seconds % 60

	return string.format("%d days, %d hours, %d minutes, %d seconds", days, hours, minutes, secs)
end

local function savePlaytime()
	-- prevent default TimePlayed message from being printed to chat
	local savedEvents = unregisterTimePlayedEvents()
	RequestTimePlayed()
	-- restore events after a short delay to ensure we get the TIME_PLAYED_MSG event
	C_Timer.After(0.2, function() restoreTimePlayedEvents(savedEvents) end)
end

local function showPlaytime()
	savePlaytime()

	local totaltime = 0
	for player, time in pairs(PlaytimeDB) do
		print(string.format("|cffaaaaaa%s|r: %s", player, secondsToDays(time)))
		totaltime = totaltime + time
	end

	print(string.format("Total Playtime: %s", secondsToDays(totaltime)))
end

local Playtime = CreateFrame("Frame")
Playtime:RegisterEvent("PLAYER_LOGIN")
Playtime:RegisterEvent("PLAYER_LOGOUT")
Playtime:RegisterEvent("TIME_PLAYED_MSG")

Playtime:SetScript("OnEvent", function(self, event, ...)
	return self[event] and self[event](self, ...)
end)

function Playtime:PLAYER_LOGIN()
	savePlaytime()
end

function Playtime:PLAYER_LOGOUT()
	savePlaytime()
end

function Playtime:TIME_PLAYED_MSG(total, currentLevel)
	local playerName = UnitName("player")
	local realmName = GetRealmName()
	local key = string.format("%s (%s)", playerName, realmName)
	PlaytimeDB[key] = total
end

SLASH_PLAYTIME1 = '/playtime';

local function handler(msg, editbox)
	if msg and (msg == 'clear') then
		PlaytimeDB = {}
		savePlaytime()
	else
		showPlaytime()
	end
end

SlashCmdList["PLAYTIME"] = handler
