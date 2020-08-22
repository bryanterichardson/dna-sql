-- DROP DATABASE IF EXISTS dna_production;
-- CREATE DATABASE dna_production;

-- CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
-- CREATE EXTENSION IF NOT EXISTS "plv8";


DROP TABLE IF EXISTS roles CASCADE;
CREATE TABLE IF NOT EXISTS roles (
    id SERIAL PRIMARY KEY NOT NULL,
    role_name VARCHAR(20) UNIQUE NOT NULL
);

INSERT INTO roles VALUES
    (0, 'anonymous'),
    (1, 'client'),
    (2, 'partner'),
    (3, 'admin');


DROP TABLE IF EXISTS users CASCADE;
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    encrypted_password VARCHAR(255) NOT NULL,
    role_id INT NOT NULL DEFAULT 0,
    can_post BOOLEAN NOT NULL DEFAULT FALSE,
    email_verified BOOLEAN NOT NULL DEFAULT FALSE,
    settings JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT users_role_id_fk FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE RESTRICT
);
CREATE INDEX users_email_idx ON users(email);
CREATE INDEX users_role_id_idx ON users(role_id);
CREATE INDEX users_can_post_idx ON users(can_post);
CREATE INDEX users_email_verified_idx ON users(email_verified);
CREATE INDEX users_created_at_idx ON users(created_at);


DROP TABLE IF EXISTS posts CASCADE;
CREATE TABLE IF NOT EXISTS posts (
    id SERIAL PRIMARY KEY NOT NULL,
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    is_visible BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT posts_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
CREATE INDEX posts_user_id_idx ON posts(user_id);
CREATE INDEX posts_is_visible_idx ON posts(is_visible);
CREATE INDEX posts_created_at_idx ON posts(created_at);


DROP TABLE IF EXISTS posts_threads CASCADE;
CREATE TABLE IF NOT EXISTS posts_threads (
    id SERIAL PRIMARY KEY NOT NULL,
    user_id INT NOT NULL,
    post_id INT NOT NULL,
    content TEXT NOT NULL,
    is_visible BOOLEAN NOT NULL DEFAULT FALSE,
    is_visible_to_author BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT posts_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT posts_post_id_fk FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
);
CREATE INDEX posts_threads_user_id_idx ON posts_threads(user_id);
CREATE INDEX posts_threads_post_id_idx ON posts_threads(post_id);
CREATE INDEX posts_threads_is_visible_idx ON posts_threads(is_visible);
CREATE INDEX posts_threads_is_visible_to_author_idx ON posts_threads(is_visible_to_author);
CREATE INDEX posts_threads_created_at_idx ON posts_threads(created_at);


DROP TABLE IF EXISTS thread_replies CASCADE;
CREATE TABLE IF NOT EXISTS thread_replies (
    id SERIAL PRIMARY KEY NOT NULL,
    user_id INT NOT NULL,
    post_thread_id INT NOT NULL,
    content TEXT NOT NULL,
    is_visible BOOLEAN NOT NULL DEFAULT FALSE,
    is_visible_to_author BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT thread_replies_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT thread_replies_post_thread_id_fk FOREIGN KEY (post_thread_id) REFERENCES posts_threads(id) ON DELETE CASCADE
);
CREATE INDEX thread_replies_user_id_idx ON thread_replies(user_id);
CREATE INDEX thread_replies_post_thread_id_idx ON thread_replies(post_thread_id);
CREATE INDEX thread_replies_user_id_post_thread_id_idx ON thread_replies(user_id, post_thread_id);
CREATE INDEX thread_replies_is_visible_idx ON thread_replies(is_visible);
CREATE INDEX thread_replies_is_visible_to_author_idx ON thread_replies(is_visible_to_author);
CREATE INDEX thread_replies_created_at_idx ON thread_replies(created_at);


DROP TABLE IF EXISTS likes CASCADE;
CREATE TABLE IF NOT EXISTS likes (
    user_id INT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT likes_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
CREATE INDEX likes_user_id_idx ON likes(user_id);
CREATE INDEX likes_created_at_idx ON likes(created_at);


DROP TABLE IF EXISTS posts_threads_likes CASCADE;
CREATE TABLE IF NOT EXISTS posts_threads_likes (
    post_thread_id INT NOT NULL,
    CONSTRAINT posts_threads_likes_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT posts_threads_likes_post_thread_id_fk FOREIGN KEY (post_thread_id) REFERENCES posts_threads(id) ON DELETE CASCADE
) INHERITS (likes);
CREATE UNIQUE INDEX posts_threads_likes_user_id_thread_id_udx ON posts_threads_likes(user_id, post_thread_id);
CREATE INDEX posts_threads_likes_user_id_idx ON posts_threads_likes(user_id);
CREATE INDEX posts_threads_likes_post_thread_id_idx ON posts_threads_likes(post_thread_id);
CREATE INDEX posts_threads_likes_created_at_idx ON posts_threads_likes(created_at);


DROP TABLE IF EXISTS thread_replies_likes CASCADE;
CREATE TABLE IF NOT EXISTS thread_replies_likes (
    thread_reply_id INT NOT NULL,
    CONSTRAINT thread_replies_likes_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT thread_replies_likes_thread_reply_id_fk FOREIGN KEY (thread_reply_id) REFERENCES thread_replies(id) ON DELETE CASCADE
) INHERITS (likes);
CREATE UNIQUE INDEX thread_replies_likes_user_id_thread_reply_id_udx ON thread_replies_likes(user_id, thread_reply_id);
CREATE INDEX thread_replies_likes_user_id_idx ON thread_replies_likes(user_id);
CREATE INDEX thread_replies_likes_thread_reply_id_idx ON thread_replies_likes(thread_reply_id);
CREATE INDEX thread_replies_likes_created_at_idx ON thread_replies_likes(created_at);


DROP TABLE IF EXISTS users_hidden_posts CASCADE;
CREATE TABLE IF NOT EXISTS users_hidden_posts (
    user_id INT NOT NULL,
    post_id INT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT users_hidden_posts_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT users_hidden_posts_post_id_fk FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
);
CREATE UNIQUE INDEX users_hidden_posts_user_id_post_id_udx ON users_hidden_posts(user_id, post_id);
CREATE INDEX users_hidden_posts_user_id_idx ON users_hidden_posts(user_id);
CREATE INDEX users_hidden_posts_post_id_idx ON users_hidden_posts(post_id);
CREATE INDEX users_hidden_posts_created_at_idx ON users_hidden_posts(created_at);
