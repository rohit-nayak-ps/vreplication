CREATE TABLE `bar_entry` (
    `id` bigint unsigned NOT NULL AUTO_INCREMENT,
    `a` enum('fooEntry') NOT NULL DEFAULT 'fooEntry',
    `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `b` bigint NOT NULL,
    `c` bigint unsigned NOT NULL,
    `d` bigint NOT NULL,
    `e` varchar(255) NOT NULL,
    `f` decimal(14, 4) NOT NULL,
    `g` char(3) NOT NULL,
    `h` decimal(14, 4) NOT NULL DEFAULT '1.0000',
    `i` tinyint DEFAULT '1',
    `j` smallint NOT NULL DEFAULT '0',
    `k` decimal(14, 4) DEFAULT NULL,
    `l` int unsigned DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `idx_foo_unique` (
        `b`,
        `d`,
        `e`,
        `j`,
        `i`
    ),
    KEY `idx_foo` (`d`, `e`, `l`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8;
