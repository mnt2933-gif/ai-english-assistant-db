-- 1. Add a new user to the platform
INSERT INTO "users" ("first_name", "last_name", "username", "proficiency_level")
VALUES ('Menna', 'Tallah', 'menna_cs', 'B2');

-- 2. Add a new conversation topic
INSERT INTO "topics" ("title", "category", "difficulty")
VALUES ('Job Interview Practice', 'Career', 'Intermediate');

-- 3. Start a new conversation session for a user on a specific topic
INSERT INTO "conversations" ("user_id", "topic_id", "duration_minutes")
VALUES (1, 1, 15);

-- 4. Record messages exchanged in a conversation
INSERT INTO "messages" ("conversation_id", "sender", "transcript")
VALUES
(1, 'ai', 'Hello! Welcome to your interview practice. Can you tell me about yourself?'),
(1, 'user', 'Hi, I am a computer science student and I loves coding.');

-- 5. Insert AI correction and feedback for a grammar error in a message
INSERT INTO "feedback" ("message_id", "original_text", "corrected_text", "error_type", "explanation")
VALUES
(2, 'I loves coding', 'I love coding', 'Grammar', 'Subject-verb agreement: Use "love" with the first-person singular pronoun "I".');

-- 6. Retrieve all conversation history and messages for a specific user
SELECT "c"."id" AS "conversation_id", "t"."title" AS "topic", "m"."sender", "m"."transcript", "m"."sent_at"
FROM "conversations" "c"
JOIN "topics" "t" ON "c"."topic_id" = "t"."id"
JOIN "messages" "m" ON "c"."id" = "m"."conversation_id"
WHERE "c"."user_id" = 1
ORDER BY "m"."sent_at" ASC;

-- 7. Get user performance summary using the view
SELECT * FROM "user_performance_summary"
WHERE "username" = 'menna_cs';

-- 8. Find the most common error types for a specific user to focus on weaknesses
SELECT "f"."error_type", COUNT("f"."id") AS "error_count"
FROM "feedback" "f"
JOIN "messages" "m" ON "f"."message_id" = "m"."id"
JOIN "conversations" "c" ON "m"."conversation_id" = "c"."id"
WHERE "c"."user_id" = 1
GROUP BY "f"."error_type"
ORDER BY "error_count" DESC;
