-- NetBanking database schema
--
-- Recreates the schema exactly as it exists in the running dev database
-- (including the two fixes applied after the fact: transactions.kind, and
-- the accounts.status check constraint that originally omitted CLOSED).
--
-- Usage (as a superuser, e.g. `postgres`):
--
--   CREATE ROLE netbanking_app WITH LOGIN PASSWORD 'choose-a-password';
--   CREATE DATABASE "NetBanking" OWNER netbanking_app;
--   \c NetBanking
--   \i schema.sql
--
-- Put the matching connection details in
-- WebContent/WEB-INF/classes/db.properties (see db.properties.example).
--
-- Every table and sequence here is created by (and therefore owned by)
-- netbanking_app, so the app can run its own migrations later without
-- needing superuser access.

CREATE TABLE users (
    user_id       SERIAL PRIMARY KEY,
    full_name     VARCHAR(100) NOT NULL,
    email         VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE accounts (
    account_id     SERIAL PRIMARY KEY,
    user_id        INT NOT NULL REFERENCES users(user_id),
    account_number VARCHAR(20) NOT NULL UNIQUE,      -- "NB" + 10-digit zero-padded user id
    balance        NUMERIC(15,2) NOT NULL DEFAULT 0.00,
    status         VARCHAR(10) NOT NULL DEFAULT 'ACTIVE'
                       CHECK (status IN ('ACTIVE', 'FROZEN', 'CLOSED')),
    created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_accounts_user_id ON accounts(user_id);

CREATE TABLE transactions (
    transaction_id   SERIAL PRIMARY KEY,
    from_account_id  INT REFERENCES accounts(account_id),  -- NULL for admin credits
    to_account_id    INT REFERENCES accounts(account_id),  -- NULL for admin debits
    amount           NUMERIC(15,2) NOT NULL CHECK (amount > 0),
    kind             VARCHAR(20) NOT NULL DEFAULT 'TRANSFER'
                         CHECK (kind IN ('TRANSFER', 'ADMIN_CREDIT', 'ADMIN_DEBIT')),
    remark           VARCHAR(255),
    status           VARCHAR(10) NOT NULL
                         CHECK (status IN ('SUCCESS', 'FAILED')),
    transaction_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_transactions_from_account ON transactions(from_account_id);
CREATE INDEX idx_transactions_to_account ON transactions(to_account_id);

CREATE TABLE admins (
    admin_id      SERIAL PRIMARY KEY,
    full_name     VARCHAR(100) NOT NULL,
    email         VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL
);

-- No seed admin row here on purpose: a hand-written INSERT would need a
-- pre-computed BCrypt hash pasted into source control. Instead, after
-- running this schema, create the first admin with:
--
--   java -cp "WebContent\WEB-INF\classes;WebContent\WEB-INF\lib\postgresql-42.7.4.jar;WebContent\WEB-INF\lib\jbcrypt-0.4.jar" ^
--        com.netbanking.tool.CreateAdmin "Admin Name" admin@example.com
--
-- (see src/com/netbanking/tool/CreateAdmin.java). It prompts for a
-- password, hashes it with the same BCrypt routine the app uses, and
-- inserts the row directly.
