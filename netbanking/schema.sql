




















CREATE TABLE users (
    user_id       SERIAL PRIMARY KEY,
    full_name     VARCHAR(100) NOT NULL,
    email         VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    profile_photo VARCHAR(255)
);

CREATE TABLE accounts (
    account_id     SERIAL PRIMARY KEY,
    user_id        INT NOT NULL REFERENCES users(user_id),
    account_number VARCHAR(20) NOT NULL UNIQUE,
    balance        NUMERIC(15,2) NOT NULL DEFAULT 0.00,
    status         VARCHAR(10) NOT NULL DEFAULT 'ACTIVE'
                       CHECK (status IN ('ACTIVE', 'FROZEN', 'CLOSED')),
    account_type   VARCHAR(10) NOT NULL DEFAULT 'SAVINGS'
                       CHECK (account_type IN ('SAVINGS', 'CURRENT')),
    created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_accounts_user_id ON accounts(user_id);

CREATE TABLE transactions (
    transaction_id   SERIAL PRIMARY KEY,
    from_account_id  INT REFERENCES accounts(account_id),
    to_account_id    INT REFERENCES accounts(account_id),
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











