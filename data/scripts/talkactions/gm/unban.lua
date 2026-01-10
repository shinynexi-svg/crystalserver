local unban = TalkAction("/unban")

function unban.onSay(player, words, param)
	-- create log
	logCommand(player, words, param)

	if param == "" then
		player:sendCancelMessage("Command param required.")
		return true
	end

	local resultId = db.storeQuery("SELECT `id`, `account_id`, `lastip` FROM `players` WHERE `name` = " .. db.escapeString(param))
	if resultId == false then
		return true
	end

	db.asyncQuery("DELETE FROM `account_bans` WHERE `account_id` = " .. Result.getNumber(resultId, "account_id"))
	db.asyncQuery("DELETE FROM `ip_bans` WHERE `ip` = " .. Result.getNumber(resultId, "lastip"))
	db.asyncQuery("DELETE FROM `player_bans` WHERE `player_id` = " .. Result.getNumber(resultId, "id"))
	Result.free(resultId)
	local text = param .. " has been unbanned."
	player:sendTextMessage(MESSAGE_ADMINISTRATOR, text)
	Webhook.sendMessage("Player Unbanned", text .. " (by: " .. player:getName() .. ")", WEBHOOK_COLOR_YELLOW, announcementChannels["serverAnnouncements"])
	return true
end

unban:separator(" ")
unban:groupType("gamemaster")
unban:register()
