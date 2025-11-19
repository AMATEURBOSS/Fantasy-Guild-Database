/*
Student Name: Carlos Ariel Mata Franco & Zainab Amir
Professor: Dr. Kia Teymourian
Course Number: COSC-3337-02 (Fall 2025)
Assignment: Term Project: Fantasy Guild Database
*/
-- =========================================================

DROP DATABASE IF EXISTS fantasy_guild;
CREATE DATABASE fantasy_guild;
USE fantasy_guild;

-- =========================================================
-- TABLE: Rank 
-- =========================================================
CREATE TABLE `GuildRank` (
    `rank_id` INT PRIMARY KEY AUTO_INCREMENT,
    `rank_name` VARCHAR(40) NOT NULL,
    `max_active_loans` INT NOT NULL CHECK (`max_active_loans` >= 0),
    `max_artifact_rarity` INT NOT NULL CHECK (`max_artifact_rarity` BETWEEN 1 AND 5)
);

-- =========================================================
-- TABLE: GuildMember
-- =========================================================
CREATE TABLE `GuildMember` (
    `member_id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(80) NOT NULL,
    `race` VARCHAR(40),
    `contact_rune` VARCHAR(80),
    `join_date` DATE NOT NULL,
    `rank_id` INT NOT NULL,
    `mentor_id` INT NULL,
    FOREIGN KEY (`rank_id`) REFERENCES `GuildRank`(`rank_id`),
    FOREIGN KEY (`mentor_id`) REFERENCES `GuildMember`(`member_id`)
);

CREATE INDEX `idx_gm_rank` ON `GuildMember` (`rank_id`);

-- =========================================================
-- TABLE: Ability
-- =========================================================
CREATE TABLE `Ability` (
    `ability_id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(80) NOT NULL,
    `category` VARCHAR(50),
    `description` VARCHAR(255)
);

-- =========================================================
-- TABLE: MemberAbility 
-- =========================================================
CREATE TABLE `MemberAbility` (
    `member_id` INT,
    `ability_id` INT,
    `proficiency_level` INT CHECK (`proficiency_level` BETWEEN 1 AND 5),
    `notes` VARCHAR(255),
    PRIMARY KEY (`member_id`, `ability_id`),
    FOREIGN KEY (`member_id`) REFERENCES `GuildMember`(`member_id`),
    FOREIGN KEY (`ability_id`) REFERENCES `Ability`(`ability_id`)
);

-- =========================================================
-- TABLE: Artifact
-- =========================================================
CREATE TABLE `Artifact` (
    `artifact_id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(80) NOT NULL,
    `category` VARCHAR(50),
    `rarity` INT NOT NULL CHECK (`rarity` BETWEEN 1 AND 5),
    `condition` ENUM('NEW','GOOD','FAIR','BROKEN') DEFAULT 'GOOD',
    `status` ENUM('AVAILABLE','ON_LOAN','DAMAGED') DEFAULT 'AVAILABLE',
    `location_note` VARCHAR(120)
);

-- =========================================================
-- TABLE: ArtifactRequest
-- =========================================================
CREATE TABLE `ArtifactRequest` (
    `request_id` INT PRIMARY KEY AUTO_INCREMENT,
    `member_id` INT NOT NULL,
    `artifact_id` INT NOT NULL,
    `request_date` DATE NOT NULL,
    `desired_start` DATE,
    `desired_end` DATE,
    `status` ENUM('PENDING','APPROVED','REJECTED','CANCELLED') DEFAULT 'PENDING',
    FOREIGN KEY (`member_id`) REFERENCES `GuildMember`(`member_id`),
    FOREIGN KEY (`artifact_id`) REFERENCES `Artifact`(`artifact_id`)
);

-- =========================================================
-- TABLE: ArtifactLoan
-- =========================================================
CREATE TABLE `ArtifactLoan` (
    `loan_id` INT PRIMARY KEY AUTO_INCREMENT,
    `member_id` INT NOT NULL,
    `artifact_id` INT NOT NULL,
    `request_id` INT NULL,
    `loan_date` DATE NOT NULL,
    `due_date` DATE NOT NULL,
    `return_date` DATE NULL,
    `condition_at_loan` ENUM('NEW','GOOD','FAIR','BROKEN') DEFAULT 'GOOD',
    `condition_at_return` ENUM('NEW','GOOD','FAIR','BROKEN') NULL,
    `status` ENUM('OPEN','CLOSED','LATE') DEFAULT 'OPEN',
    FOREIGN KEY (`member_id`) REFERENCES `GuildMember`(`member_id`),
    FOREIGN KEY (`artifact_id`) REFERENCES `Artifact`(`artifact_id`),
    FOREIGN KEY (`request_id`) REFERENCES `ArtifactRequest`(`request_id`),
    CHECK (`due_date` >= `loan_date`)
);

CREATE INDEX `idx_artifactloan_member` ON `ArtifactLoan`(`member_id`);

-- =========================================================
-- TABLE: Quest
-- =========================================================
CREATE TABLE `Quest` (
    `quest_id` INT PRIMARY KEY AUTO_INCREMENT,
    `title` VARCHAR(100) NOT NULL,
    `description` VARCHAR(255),
    `difficulty` INT CHECK (`difficulty` BETWEEN 1 AND 10),
    `required_rank_id` INT,
    `scheduled_date` DATE,
    `reward_xp` INT CHECK (`reward_xp` >= 0),
    FOREIGN KEY (`required_rank_id`) REFERENCES `GuildRank`(`rank_id`)
);

-- =========================================================
-- TABLE: QuestParticipation (Bridge)
-- =========================================================
CREATE TABLE `QuestParticipation` (
    `quest_id` INT,
    `member_id` INT,
    `role` VARCHAR(40),
    `completed` BOOLEAN DEFAULT FALSE,
    `xp_earned` INT CHECK (`xp_earned` >= 0),
    PRIMARY KEY (`quest_id`, `member_id`),
    FOREIGN KEY (`quest_id`) REFERENCES `Quest`(`quest_id`),
    FOREIGN KEY (`member_id`) REFERENCES `GuildMember`(`member_id`)
);

-- =========================================================
-- TABLE: Payment
-- =========================================================
CREATE TABLE `Payment` (
    `payment_id` INT PRIMARY KEY AUTO_INCREMENT,
    `member_id` INT NOT NULL,
    `loan_id` INT NULL,
    `amount` DECIMAL(10,2) NOT NULL CHECK (`amount` >= 0),
    `type` ENUM('DEPOSIT','PENALTY','REPAIR_FEE','SERVICE_FEE','OTHER'),
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `status` ENUM('PENDING','PAID','REFUNDED') DEFAULT 'PENDING',
    FOREIGN KEY (`member_id`) REFERENCES `GuildMember`(`member_id`),
    FOREIGN KEY (`loan_id`) REFERENCES `ArtifactLoan`(`loan_id`)
);

-- =========================================================
-- TRIGGER: Auto-add penalty for late returns
-- =========================================================
DELIMITER $$
CREATE TRIGGER `tr_add_penalty_after_return`
AFTER UPDATE ON `ArtifactLoan`
FOR EACH ROW
BEGIN
    IF NEW.return_date IS NOT NULL AND NEW.return_date > NEW.due_date THEN
        INSERT INTO `Payment`(`member_id`, `loan_id`, `amount`, `type`, `status`)
        VALUES (NEW.member_id, NEW.loan_id, 25.00, 'PENALTY', 'PENDING');
    END IF;
END $$
DELIMITER ;

-- =========================================================
-- SAMPLE INSERT DATA
-- =========================================================
INSERT INTO `GuildRank` (`rank_name`, `max_active_loans`, `max_artifact_rarity`)
VALUES ('Novice', 1, 2), ('Adept', 3, 4), ('Master', 5, 5);

INSERT INTO `GuildMember` (`name`, `race`, `contact_rune`, `join_date`, `rank_id`)
VALUES ('Arion the Swift', 'Elf', 'Rune-123', '2024-01-10', 1),
       ('Borg the Mighty', 'Orc', 'Rune-999', '2024-02-15', 2),
       ('Celina the Wise', 'Human', 'Rune-777', '2024-03-20', 3);

INSERT INTO `Ability` (`name`, `category`, `description`)
VALUES ('Healing Light', 'Healing', 'Restores health'),
       ('Fireball', 'Offense', 'Launch a flaming orb'),
       ('Lockpick', 'Utility', 'Open simple locks');

INSERT INTO `MemberAbility` (`member_id`, `ability_id`, `proficiency_level`)
VALUES (1, 1, 3), (3, 2, 5), (2, 3, 2);

INSERT INTO `Artifact` (`name`, `category`, `rarity`, `condition`, `status`)
VALUES ('Sword of Dawn', 'Weapon', 3, 'GOOD', 'AVAILABLE'),
       ('Shadow Cloak', 'Armor', 2, 'GOOD', 'AVAILABLE');

INSERT INTO `ArtifactRequest` (`member_id`, `artifact_id`, `request_date`, `desired_start`, `desired_end`)
VALUES (1, 1, '2025-01-10', '2025-01-11', '2025-01-15');

INSERT INTO `ArtifactLoan` (`member_id`, `artifact_id`, `request_id`, `loan_date`, `due_date`)
VALUES (1, 1, 1, '2025-01-11', '2025-01-15');

INSERT INTO `Quest` (`title`, `description`, `difficulty`, `required_rank_id`, `scheduled_date`, `reward_xp`)
VALUES ('Cave of Echoes', 'A dungeon filled with spirits', 5, 2, '2025-02-01', 200);

INSERT INTO `QuestParticipation` (`quest_id`, `member_id`, `role`, `completed`, `xp_earned`)
VALUES (1, 1, 'Healer', TRUE, 200);

