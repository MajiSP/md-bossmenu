
CREATE TABLE IF NOT EXISTS `mdbossmenu` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `job` text NOT NULL,
  `transactions` text DEFAULT NULL,
  `firings` text DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;


CREATE TABLE IF NOT EXISTS `mdbossmenu_billings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cid` text NOT NULL,
  `job` text NOT NULL,
  `amount` int(11) NOT NULL DEFAULT 0,
  `biller` text NOT NULL,
  `billed` text DEFAULT NULL,
  `reason` text NOT NULL,
  `time` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;


CREATE TABLE IF NOT EXISTS `mdbossmenu_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` text DEFAULT NULL,
  `job` text DEFAULT NULL,
  `sender` text DEFAULT NULL,
  `content` text DEFAULT NULL,
  `timestamp` text DEFAULT NULL,
  `userimage` text DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

ALTER TABLE `players`
ADD COLUMN `userimage` TEXT NULL DEFAULT NULL;

CREATE TABLE IF NOT EXISTS employee_of_the_month (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    image VARCHAR(255) NOT NULL,
    month DATE NOT NULL
);