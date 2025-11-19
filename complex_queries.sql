-- =========================================================
-- Fantasy Guild Database - Complex Queries
-- COSC 3337 - Term Project
-- Professor: Dr. Kia Teymourian
-- Student Name: Carlos Ariel Mata Franco & Zainab Amir
-- =========================================================

USE fantasy_guild;

-- =========================================================
-- Q1: JOIN
-- Purpose: List members, the artifacts they borrowed, and the rarity.
--          (JOIN GuildMember → ArtifactLoan → Artifact)
-- =========================================================
SELECT 
    gm.name AS member_name,
    a.name AS artifact_name,
    a.rarity,
    al.loan_date,
    al.due_date
FROM GuildMember gm
JOIN ArtifactLoan al ON gm.member_id = al.member_id
JOIN Artifact a ON a.artifact_id = al.artifact_id
ORDER BY gm.name;


-- =========================================================
-- Q2: SUBQUERY
-- Purpose: Find members whose total payments are above 
--          the average payment amount across all members.
-- =========================================================
SELECT 
    gm.name,
    SUM(p.amount) AS total_paid
FROM GuildMember gm
JOIN Payment p ON p.member_id = gm.member_id
GROUP BY gm.member_id
HAVING SUM(p.amount) > (
    SELECT AVG(total_payments)
    FROM (
        SELECT SUM(amount) AS total_payments
        FROM Payment
        GROUP BY member_id
    ) AS temp
);


-- =========================================================
-- Q3: WINDOW FUNCTION
-- Purpose: Rank artifacts within each rarity group based on how many times
--          they were loaned.
-- =========================================================
SELECT 
    a.artifact_id,
    a.name AS artifact_name,
    a.rarity,
    COUNT(al.loan_id) AS loan_count,
    RANK() OVER (
        PARTITION BY a.rarity
        ORDER BY COUNT(al.loan_id) DESC
    ) AS popularity_rank
FROM Artifact a
LEFT JOIN ArtifactLoan al ON al.artifact_id = a.artifact_id
GROUP BY a.artifact_id, a.name, a.rarity
ORDER BY a.rarity, popularity_rank;


-- =========================================================
-- Q4: TRANSACTION 
-- Purpose: Check out an artifact:
--   1) Mark artifact as ON_LOAN
--   2) Insert loan record
--   3) COMMIT if all succeeds, otherwise ROLLBACK
-- =========================================================

START TRANSACTION;

-- (1) Update artifact status
UPDATE Artifact
SET status = 'ON_LOAN'
WHERE artifact_id = 1;

-- (2) Insert loan record
INSERT INTO ArtifactLoan (member_id, artifact_id, loan_date, due_date)
VALUES (1, 1, CURRENT_DATE(), DATE_ADD(CURRENT_DATE(), INTERVAL 3 DAY));

COMMIT;


-- =========================================================
-- Q5: AGGREGATION + HAVING
-- Purpose: List quests that have more than 1 participant.
-- =========================================================
SELECT 
    q.title,
    COUNT(qp.member_id) AS participant_count
FROM Quest q
JOIN QuestParticipation qp ON qp.quest_id = q.quest_id
GROUP BY q.quest_id, q.title
HAVING COUNT(qp.member_id) > 1;


-- =========================================================
-- Q6: UPDATE OPERATION
-- Purpose: Increase the XP earned by all members who completed a quest.
-- =========================================================
UPDATE QuestParticipation
SET xp_earned = xp_earned + 50
WHERE completed = TRUE;

-- We can use this to test : SELECT * FROM QuestParticipation;
