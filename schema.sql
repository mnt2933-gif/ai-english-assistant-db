-- Represent users practicing English speaking on the platform
CREATE TABLE "users" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    "username" TEXT NOT NULL UNIQUE,
    "proficiency_level" TEXT CHECK("proficiency_level" IN ('A1', 'A2', 'B1', 'B2', 'C1', 'C2')) DEFAULT 'B2',
    "joined_date" NUMERIC DEFAULT CURRENT_TIMESTAMP
);

-- Represent conversation topics available for users
CREATE TABLE "topics" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "title" TEXT NOT NULL,
    "category" TEXT NOT NULL,
    "difficulty" TEXT CHECK("difficulty" IN ('Beginner', 'Intermediate', 'Advanced')) NOT NULL
);

-- Represent individual practice sessions between a user and the AI
CREATE TABLE "conversations" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "user_id" INTEGER NOT NULL,
    "topic_id" INTEGER NOT NULL,
    "started_at" NUMERIC DEFAULT CURRENT_TIMESTAMP,
    "duration_minutes" INTEGER CHECK("duration_minutes" >= 0),
    FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE,
    FOREIGN KEY ("topic_id") REFERENCES "topics"("id") ON DELETE CASCADE
);

-- Represent messages exchanged during a conversation session
CREATE TABLE "messages" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "conversation_id" INTEGER NOT NULL,
    "sender" TEXT CHECK("sender" IN ('user', 'ai')) NOT NULL,
    "transcript" TEXT NOT NULL,
    "sent_at" NUMERIC DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("conversation_id") REFERENCES "conversations"("id") ON DELETE CASCADE
);

-- Represent grammatical and fluency feedback provided by the AI
CREATE TABLE "feedback" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "message_id" INTEGER NOT NULL,
    "original_text" TEXT NOT NULL,
    "corrected_text" TEXT NOT NULL,
    "error_type" TEXT CHECK("error_type" IN ('Grammar', 'Vocabulary', 'Pronunciation', 'Fluency')) NOT NULL,
    "explanation" TEXT,
    FOREIGN KEY ("message_id") REFERENCES "messages"("id") ON DELETE CASCADE
);

-- Indexes to speed up queries for conversations and messages
CREATE INDEX "idx_conversations_user" ON "conversations"("user_id");
CREATE INDEX "idx_messages_conversation" ON "messages"("conversation_id");
CREATE INDEX "idx_feedback_message" ON "feedback"("message_id");

-- View to summarize user practice history and error counts
CREATE VIEW "user_performance_summary" AS
SELECT
    "u"."id" AS "user_id",
    "u"."username",
    "u"."proficiency_level",
    COUNT(DISTINCT "c"."id") AS "total_conversations",
    COUNT("f"."id") AS "total_errors_corrected"
FROM "users" "u"
LEFT JOIN "conversations" "c" ON "u"."id" = "c"."user_id"
LEFT JOIN "messages" "m" ON "c"."id" = "m"."conversation_id"
LEFT JOIN "feedback" "f" ON "m"."id" = "f"."message_id"
GROUP BY "u"."id";
