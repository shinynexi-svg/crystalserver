local playerBan = TalkAction("/playerban")

function playerBan.onSay(player, words, param)
	-- create log
	logCommand(player, words, param)

	local params = param:split(",")
	if #params < 3 then
		player:sendCancelMessage("Command requires 3 parameters: /playerban <player name>, <duration in days>, <reason>")
		return true
	end

	local playerName = params[1]:trim()
	local banDuration = tonumber(params[2]:trim())
	local banReason = params[3]:trim()

	if not banDuration or banDuration <= 0 then
		player:sendCancelMessage("Ban duration must be a positive number.")
		return true
	end

	local resultId = db.storeQuery("SELECT `id` FROM `players` WHERE `name` = " .. db.escapeString(playerName))
	if resultId == false then
		player:sendCancelMessage("Player not found.")
		return true
	end

	local targetGuid = Result.getNumber(resultId, "id")
	Result.free(resultId)

	resultId = db.storeQuery("SELECT 1 FROM `player_bans` WHERE `player_id` = " .. targetGuid)
	if resultId ~= false then
		player:sendTextMessage(MESSAGE_ADMINISTRATOR, playerName .. " is already banned.")
		Result.free(resultId)
		return true
	end

	local currentTime = os.time()
	local expirationTime = currentTime + (banDuration * 24 * 60 * 60)
	db.query(string.format("INSERT INTO `player_bans` (`player_id`, `reason`, `banned_at`, `expires_at`, `banned_by`) VALUES (%d, %s, %d, %d, %d)", targetGuid, db.escapeString(banReason), currentTime, expirationTime, player:getGuid()))

	local target = Player(playerName)
	if target then
		player:sendTextMessage(MESSAGE_ADMINISTRATOR, string.format("Character %s has been banned for %d days.", target:getName(), banDuration))
		target:remove()
		Webhook.sendMessage("Player Banned", string.format("Character %s has been banned for %d days. Reason: %s (by: %s)", target:getName(), banDuration, banReason, player:getName()), WEBHOOK_COLOR_YELLOW, announcementChannels["serverAnnouncements"])
	else
		player:sendTextMessage(MESSAGE_ADMINISTRATOR, string.format("Character %s has been banned for %d days.", playerName, banDuration))
	end
	return true
end

playerBan:separator(" ")
playerBan:groupType("gamemaster")
playerBan:register()
