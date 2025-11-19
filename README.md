Fantasy Guild Artifact & Ability Management System

This project models the data management needs of a fantasy adventurers’ guild. The guild serves
as a central organization where members of various ranks borrow magical artifacts, develop
specialized abilities, and participate in quests. Because the guild operates as a structured
organization with rules, privileges, and roles, it requires a robust database to maintain accurate
records, enforce constraints, and support complex interactions between members and guild
assets.

Each GuildMember belongs to a specific GuildRank (such as Novice, Adept, or Master),
which determines the maximum number of active artifact loans they are allowed and the highest
rarity of artifact they may borrow. Members may also be mentored by senior members, creating a
hierarchical mentorship structure inside the guild.
The guild owns various Artifacts: weapons, armor pieces, relics, and magical items, that
members can request and borrow. These artifact interactions are managed through
ArtifactRequest and ArtifactLoan tables, which track who requested the item, when it was
loaned out, its due date, and its condition both at loan and at return. A trigger automatically
generates penalty payments if an artifact is returned late, enforcing guild rules.
Members train in different magical or utility Abilities, creating a many-to-many relationship
modeled through the MemberAbility bridge table. This allows the guild to store each member’s
proficiency level in the abilities they have learned.

The guild also organizes Quests, which members can participate in through the
QuestParticipation table. These quests award experience points and have difficulty levels and
rank requirements, making them ideal for advanced SQL queries and constraints.
Finally, the guild manages financial transactions through the Payment table, which records
deposits, penalties, repair fees, and other charges associated with artifact use or guild activities.
Together, these components form a rich environment for applying normalization, relationships,
constraints, triggers, transactions, window functions, and advanced SQL.
This database design provides a cohesive fantasy-themed system that is both engaging and
structurally robust, showcasing real-world database principles within an imaginative setting.
