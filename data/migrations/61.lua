function onUpdateDatabase()
	logger.info("Updating database to version 61 (add player_bans and player_ban_history)")

	db.query([[CREATE TABLE IF NOT EXISTS `player_bans` (
		`player_id` int(11) NOT NULL,
		`reason` varchar(255) NOT NULL,
		`banned_at` bigint(20) NOT NULL,
		`expires_at` bigint(20) NOT NULL,
		`banned_by` int(11) NOT NULL,
		INDEX `banned_by` (`banned_by`),
		CONSTRAINT `player_bans_pk` PRIMARY KEY (`player_id`),
		CONSTRAINT `player_bans_players_fk`
			FOREIGN KEY (`player_id`) REFERENCES `players` (`id`)
			ON DELETE CASCADE
			ON UPDATE CASCADE,
		CONSTRAINT `player_bans_players2_fk`
			FOREIGN KEY (`banned_by`) REFERENCES `players` (`id`)
			ON DELETE CASCADE
			ON UPDATE CASCADE
	) ENGINE=InnoDB DEFAULT CHARSET=utf8;]])

	db.query([[CREATE TABLE IF NOT EXISTS `player_ban_history` (
		`id` int(11) NOT NULL AUTO_INCREMENT,
		`player_id` int(11) NOT NULL,
		`reason` varchar(255) NOT NULL,
		`banned_at` bigint(20) NOT NULL,
		`expired_at` bigint(20) NOT NULL,
		`banned_by` int(11) NOT NULL,
		INDEX `player_id` (`player_id`),
		INDEX `banned_by` (`banned_by`),
		CONSTRAINT `player_ban_history_pk` PRIMARY KEY (`id`),
		CONSTRAINT `player_ban_history_players_fk`
			FOREIGN KEY (`player_id`) REFERENCES `players` (`id`)
			ON DELETE CASCADE
			ON UPDATE CASCADE,
		CONSTRAINT `player_ban_history_players2_fk`
			FOREIGN KEY (`banned_by`) REFERENCES `players` (`id`)
			ON DELETE CASCADE
			ON UPDATE CASCADE
	) ENGINE=InnoDB DEFAULT CHARSET=utf8;]])
end
