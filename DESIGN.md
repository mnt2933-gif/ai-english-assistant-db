# Design Document: AI English Speaking Assistant Database

By Menna Tallah

Video overview: <https://youtu.be/jp5Aj3WuZW0?si=GzkvgtKhU0zPC7Lg>

## Scope

* **What is the purpose of your database?**
  The purpose of the database is to power an AI-driven English speaking practice application. It manages user profiles, conversation topics, practice session records, full transcripts of spoken/written messages, and detailed linguistic feedback to help users track their progress and improve their language skills.

* **Which people, places, things, etc. are you including in the scope of your database?**
  * Users practicing English speaking.
  * Topics categorized by difficulty and category.
  * Conversation sessions held between users and the AI.
  * Transcripts of messages exchanged.
  * AI-generated corrections and feedback (Grammar, Vocabulary, Pronunciation, Fluency).

* **Which people, places, things, etc. are outside the scope of your database?**
  * Raw audio data files (only text transcripts are stored).
  * Payment processing, subscriptions, and financial transactions.
  * Detailed administrative staff credentials and OAuth authentication tokens.

## Functional Requirements

* **What should a user be able to do with your database?**
  * Create and maintain a user profile with a specific English proficiency level (A1–C2).
  * Select conversation topics based on category and difficulty.
  * Log new practice sessions and store full message transcripts.
  * Store and retrieve AI feedback on grammar, vocabulary, and fluency mistakes.
  * Query past performance, including total practice sessions and common error patterns.

* **What's beyond the scope of what a user should be able to do with your database?**
  * Live streaming or direct storage of high-resolution audio files.
  * Peer-to-peer messaging with other real human users (it is strictly user-to-AI interaction).
  * Direct modification or deletion of past feedback logs without appropriate administrative triggers.

## Representation

### Entities

* **`users`**
  * Attributes: `id` (INTEGER, PRIMARY KEY, AUTOINCREMENT), `first_name` (TEXT, NOT NULL), `last_name` (TEXT, NOT NULL), `username` (TEXT, NOT NULL, UNIQUE), `proficiency_level` (TEXT, CHECK), `joined_date` (NUMERIC, DEFAULT CURRENT_TIMESTAMP).
  * *Types & Constraints*: `id` is an auto-incrementing integer for unique identification. `username` is UNIQUE to prevent duplicate user accounts. `proficiency_level` uses a CHECK constraint restricting values to valid CEFR levels ('A1', 'A2', 'B1', 'B2', 'C1', 'C2').

* **`topics`**
  * Attributes: `id` (INTEGER, PRIMARY KEY, AUTOINCREMENT), `title` (TEXT, NOT NULL), `category` (TEXT, NOT NULL), `difficulty` (TEXT, CHECK).
  * *Types & Constraints*: `difficulty` is restricted via CHECK constraint to ('Beginner', 'Intermediate', 'Advanced') to ensure consistent categorization.

* **`conversations`**
  * Attributes: `id` (INTEGER, PRIMARY KEY, AUTOINCREMENT), `user_id` (INTEGER, FOREIGN KEY), `topic_id` (INTEGER, FOREIGN KEY), `started_at` (NUMERIC, DEFAULT CURRENT_TIMESTAMP), `duration_minutes` (INTEGER, CHECK).
  * *Types & Constraints*: Foreign keys establish relationships with `users` and `topics`. `duration_minutes` includes a CHECK constraint (`>= 0`) to prevent invalid negative times.

* **`messages`**
  * Attributes: `id` (INTEGER, PRIMARY KEY, AUTOINCREMENT), `conversation_id` (INTEGER, FOREIGN KEY), `sender` (TEXT, CHECK), `transcript` (TEXT, NOT NULL), `sent_at` (NUMERIC, DEFAULT CURRENT_TIMESTAMP).
  * *Types & Constraints*: `sender` uses a CHECK constraint ensuring values are strictly either 'user' or 'ai'. Foreign key ties each message to a specific conversation session.

* **`feedback`**
  * Attributes: `id` (INTEGER, PRIMARY KEY, AUTOINCREMENT), `message_id` (INTEGER, FOREIGN KEY), `original_text` (TEXT, NOT NULL), `corrected_text` (TEXT, NOT NULL), `error_type` (TEXT, CHECK), `explanation` (TEXT).
  * *Types & Constraints*: `error_type` is constrained via CHECK to ('Grammar', 'Vocabulary', 'Pronunciation', 'Fluency') for reliable analytical grouping.

### Relationships

The entity relationship structure is outlined as follows:

* **Users to Conversations**: One-to-Many ($1:N$). A single user can start and record multiple conversation sessions over time.
* **Topics to Conversations**: One-to-Many ($1:N$). A single topic can be selected for practice across many user conversations.
* **Conversations to Messages**: One-to-Many ($1:N$). Each conversation session contains multiple messages back and forth.
* **Messages to Feedback**: One-to-Many ($1:N$). A message sent by a user can receive one or more specific corrections/feedback items.
##OPtimizations

* **Indexes**:
  * `idx_conversations_user`: Created on `conversations(user_id)` to speed up queries retrieving practice history for a specific user.
  * `idx_messages_conversation`: Created on `messages(conversation_id)` to optimize fetching full chat logs for a specific conversation session.
  * `idx_feedback_message`: Created on `feedback(message_id)` to accelerate performance when displaying language corrections for specific messages.

* **Views**:
  * `user_performance_summary`: A view that aggregates user information, total completed conversations, and total language errors corrected. It speeds up generating user dashboard analytics without writing complex JOIN queries every time.

## Limitations

* **No Audio Storage**: The schema only stores textual transcriptions (`transcript`) instead of audio files to maintain minimal database size and complexity.
* **Static Proficiency Track**: Proficiency levels are stored as a single value on the user's entity. Tracking proficiency history/progress over multiple months would require an additional historical snapshot table.
