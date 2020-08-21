-- DROP DATABASE IF EXISTS dna_production;
-- CREATE DATABASE dna_production;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

DROP TABLE IF EXISTS users CASCADE;
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY NOT NULL DEFAULT uuid_generate_v4(),
    email VARCHAR(100) UNIQUE NOT NULL,
    encrypted_password VARCHAR(255) NOT NULL,  -- Uses Bcrypt
    role VARCHAR(100),
    can_post BOOLEAN NOT NULL DEFAULT FALSE,
    email_verified BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX users_created_at_idx ON users(created_at);
CREATE INDEX users_email_idx ON users(email);
CREATE INDEX users_role_idx ON users(role);
CREATE INDEX users_can_post_idx ON users(can_post);
CREATE INDEX users_email_verified_idx ON users(email_verified);


DROP TABLE IF EXISTS posts CASCADE;
CREATE TABLE IF NOT EXISTS posts (
    id UUID PRIMARY KEY NOT NULL DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    content TEXT NOT NULL,
    is_visible BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT posts_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
CREATE INDEX posts_user_id_idx ON posts(user_id);
CREATE INDEX posts_is_visible_idx ON posts(is_visible);
CREATE INDEX posts_created_at_idx ON posts(created_at);


DROP TABLE IF EXISTS post_threads CASCADE;
CREATE TABLE IF NOT EXISTS post_threads (
    id UUID PRIMARY KEY NOT NULL DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    post_id UUID NOT NULL,
    content TEXT NOT NULL,
    is_visible BOOLEAN NOT NULL DEFAULT FALSE,
    is_visible_to_author BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT posts_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT posts_post_id_fk FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
);
CREATE INDEX post_threads_user_id_idx ON post_threads(user_id);
CREATE INDEX post_threads_post_id_idx ON post_threads(post_id);
CREATE INDEX post_threads_is_visible_idx ON post_threads(is_visible);
CREATE INDEX post_threads_is_visible_to_author_idx ON post_threads(is_visible_to_author);
CREATE INDEX post_threads_created_at_idx ON post_threads(created_at);


DROP TABLE IF EXISTS post_thread_likes CASCADE;
CREATE TABLE IF NOT EXISTS post_thread_likes (
    user_id UUID NOT NULL,
    thread_id UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT post_thread_likes_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT post_thread_likes_thread_id_fk FOREIGN KEY (thread_id) REFERENCES post_threads(id) ON DELETE CASCADE
);
CREATE UNIQUE INDEX post_thread_likes_user_id_thread_id_udx ON post_thread_likes(user_id, thread_id);
CREATE INDEX post_thread_likes_user_id_idx ON post_thread_likes(user_id);
CREATE INDEX post_thread_likes_thread_id_idx ON post_thread_likes(thread_id);
CREATE INDEX post_thread_likes_created_at_idx ON post_thread_likes(created_at);


DROP TABLE IF EXISTS thread_replies CASCADE;
CREATE TABLE IF NOT EXISTS thread_replies (
    id UUID PRIMARY KEY NOT NULL DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    post_thread_id UUID NOT NULL,
    content TEXT NOT NULL,
    is_visible BOOLEAN NOT NULL DEFAULT FALSE,
    is_visible_to_author BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT thread_replies_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT thread_replies_post_thread_id_fk FOREIGN KEY (post_thread_id) REFERENCES post_threads(id) ON DELETE CASCADE
);
CREATE INDEX thread_replies_user_id_idx ON thread_replies(user_id);
CREATE INDEX thread_replies_post_thread_id_idx ON thread_replies(post_thread_id);
CREATE INDEX thread_replies_user_id_post_thread_id_idx ON thread_replies(user_id, post_thread_id);
CREATE INDEX thread_replies_is_visible_idx ON thread_replies(is_visible);
CREATE INDEX thread_replies_is_visible_to_author_idx ON thread_replies(is_visible_to_author);
CREATE INDEX thread_replies_created_at_idx ON thread_replies(created_at);


DROP TABLE IF EXISTS thread_reply_likes CASCADE;
CREATE TABLE IF NOT EXISTS thread_reply_likes (
    user_id UUID NOT NULL,
    reply_id UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT thread_reply_likes_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT thread_reply_likes_reply_id_fk FOREIGN KEY (reply_id) REFERENCES thread_replies(id) ON DELETE CASCADE
);
CREATE UNIQUE INDEX thread_reply_likes_user_id_reply_id_udx ON thread_reply_likes(user_id, reply_id);
CREATE INDEX thread_reply_likes_user_id_idx ON thread_reply_likes(user_id);
CREATE INDEX thread_reply_likes_reply_id_idx ON thread_reply_likes(reply_id);
CREATE INDEX thread_reply_likes_created_at_idx ON thread_reply_likes(created_at);


DROP TABLE IF EXISTS users_hidden_posts CASCADE;
CREATE TABLE IF NOT EXISTS users_hidden_posts (
    user_id UUID NOT NULL,
    post_id UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT users_hidden_posts_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT users_hidden_posts_post_id_fk FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
);
CREATE UNIQUE INDEX users_hidden_posts_user_id_post_id_udx ON users_hidden_posts(user_id, post_id);
CREATE INDEX users_hidden_posts_user_id_idx ON users_hidden_posts(user_id);
CREATE INDEX users_hidden_posts_post_id_idx ON users_hidden_posts(post_id);
CREATE INDEX users_hidden_posts_created_at_idx ON users_hidden_posts(created_at);


DROP TABLE IF EXISTS users_settings CASCADE;
CREATE TABLE IF NOT EXISTS users_settings (
    user_id UUID PRIMARY KEY NOT NULL,
    settings JSONB NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT users_settings_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
