# NetBanking

A simple net-banking web application built with plain Java Servlets + JSP on Tomcat 9, backed by PostgreSQL. No frameworks — the goal is to show the classic layered MVC structure (Controller → Service → DAO → DB) end to end.

---

## Tech stack

| Layer      | Choice                                            |
|------------|---------------------------------------------------|
| Runtime    | Java 17, Apache Tomcat 9.0.x (Servlet 4 / JSP 2.3) |
| Database   | PostgreSQL (`NetBanking` db, `netbanking_app` user) |
| Libraries  | `postgresql-42.7.4.jar` (JDBC), `jbcrypt-0.4.jar` (password hashing) |
| Frontend   | JSP + JSTL-free scriptlets, single `static/css/style.css` |
| Build/run  | `start.bat` (compiles `src/` into `WEB-INF/classes`, starts Tomcat, opens browser) |

## Project layout

```
netbanking/
├── src/com/netbanking/
│   ├── controller/   Servlets (one per URL)
│   ├── filter/       LoginFilter, AdminAuthFilter (session guards)
│   ├── service/      Business rules + transactions (AuthService, TransferService, Admin*Service)
│   ├── dao/          JDBC access (UserDAO, AccountDAO, TransactionDAO, AdminDAO)
│   ├── model/        POJOs (User, Account, Transaction, Admin)
│   └── util/         DBConnection (reads db.properties), PasswordUtil (BCrypt)
├── WebContent/
│   ├── views/        JSPs (login, register, dashboard, transfer, history, fragments/sidebar-*)
│   ├── static/css/   style.css
│   └── WEB-INF/
│       ├── classes/  compiled output + db.properties
│       └── lib/      postgresql + jbcrypt jars
└── start.bat
```

## Running locally

1. Create the database and app user in PostgreSQL (see **Database schema** below).
2. Put the connection details in `WebContent/WEB-INF/classes/db.properties`:
   ```properties
   db.url=jdbc:postgresql://localhost:5432/NetBanking
   db.username=netbanking_app
   db.password=...
   ```
3. Edit the `JAVA_HOME` / `CATALINA_HOME` paths at the top of `start.bat` if they differ on your machine.
4. Run `start.bat`. It compiles everything, starts Tomcat and opens `http://localhost:8080/netbanking/login`.

## Database schema

There is no `schema.sql` in the repo yet (see *Next up*). The tables the code expects are:

```sql
CREATE TABLE users (
    user_id       SERIAL PRIMARY KEY,
    full_name     VARCHAR(100) NOT NULL,
    email         VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(100) NOT NULL,
    created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE accounts (
    account_id     SERIAL PRIMARY KEY,
    user_id        INT NOT NULL REFERENCES users(user_id),
    account_number VARCHAR(20) NOT NULL UNIQUE,      -- "NB" + 10-digit user id
    balance        NUMERIC(15,2) NOT NULL DEFAULT 0,
    status         VARCHAR(10) NOT NULL DEFAULT 'ACTIVE',  -- ACTIVE | FROZEN | CLOSED
    created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE transactions (
    transaction_id   SERIAL PRIMARY KEY,
    from_account_id  INT REFERENCES accounts(account_id),  -- NULL for admin credits
    to_account_id    INT REFERENCES accounts(account_id),  -- NULL for admin debits
    amount           NUMERIC(15,2) NOT NULL,
    kind             VARCHAR(20) NOT NULL DEFAULT 'TRANSFER', -- TRANSFER | ADMIN_CREDIT | ADMIN_DEBIT
    remark           VARCHAR(255),
    status           VARCHAR(10) NOT NULL,                  -- SUCCESS
    transaction_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE admins (
    admin_id      SERIAL PRIMARY KEY,
    full_name     VARCHAR(100) NOT NULL,
    email         VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(100) NOT NULL
);
```

> **Pending migration:** the `transactions.kind` column was added to the Java code but not yet to the live database.
> Run this once as the table owner (e.g. `postgres` in pgAdmin) or every dashboard/history/transfer page will 500 with
> `column "kind" does not exist`:
> ```sql
> ALTER TABLE transactions ADD COLUMN IF NOT EXISTS kind VARCHAR(20) NOT NULL DEFAULT 'TRANSFER';
> ```

---

## What is implemented so far

### Customer side — complete (backend + JSP views)

| URL          | Servlet             | What it does |
|--------------|---------------------|--------------|
| `/register`  | `RegisterServlet`   | Creates a user (BCrypt-hashed password) and an account with a ₹10,000 signup bonus; account number is `NB` + zero-padded user id. Rejects duplicate emails. |
| `/login`     | `LoginServlet`      | Email + password login; refuses FROZEN / CLOSED accounts with a clear message. Puts the user in the session. |
| `/logout`    | `LogoutServlet`     | Invalidates the session. |
| `/dashboard` | `DashboardServlet`  | Shows balance, account number/status, lifetime total sent / received, and the 5 most recent transactions. |
| `/transfer`  | `TransferServlet`   | Fund transfer by recipient account number with optional remark. |
| `/history`   | `HistoryServlet`    | Full transaction history for the logged-in account. |

Rules enforced in `TransferService`:
- amount must be positive, recipient must exist, cannot transfer to self
- both accounts must be `ACTIVE`, sender must have sufficient balance
- both balance updates + the transaction log row are written in **one DB transaction** with `SELECT … FOR UPDATE` row locks, so concurrent transfers can't overdraw an account
- DEBIT / CREDIT is not stored — it is derived per viewer in `TransactionDAO.mapRow` depending on which side of the row the account is on

`LoginFilter` guards `/dashboard`, `/transfer`, `/history` and redirects to `/login` when there is no session.

### Admin side — backend complete, views not yet written

| URL                     | Servlet                     | What it does |
|-------------------------|-----------------------------|--------------|
| `/admin/login`          | `AdminLoginServlet`         | Separate admin login against the `admins` table; stores the admin in the session. |
| `/admin/logout`         | `AdminLogoutServlet`        | Invalidates the admin session. |
| `/admin/dashboard`      | `AdminDashboardServlet`     | System stats in one query: total users / accounts / balance, active / frozen / closed counts, total transactions. |
| `/admin/users`          | `AdminUsersServlet`         | Lists every account with holder name + email; POST actions `freeze`, `unfreeze`, `close`, `reactivate` with state-transition validation and flash messages. |
| `/admin/add-user`       | `AdminAddUserServlet`       | Admin creates a customer through the same path as self-registration. |
| `/admin/adjust-balance` | `AdminAdjustBalanceServlet` | Credit or debit any account by account number with a mandatory reason; logged as `ADMIN_CREDIT` / `ADMIN_DEBIT`, atomic with the balance change, cannot go below zero or touch a closed account. |
| `/admin/transactions`   | `AdminTransactionsServlet`  | Global transaction log with both account numbers joined in. |

`AdminAuthFilter` guards all admin pages except `/admin/login`.

**Missing:** the JSPs these servlets forward to do not exist yet —
`views/admin/admin-login.jsp`, `admin-dashboard.jsp`, `admin-users.jsp`, `admin-add-user.jsp`, `admin-adjust-balance.jsp`, `admin-transactions.jsp`.
Hitting any admin URL currently returns a 404 from the dispatcher. There is also no way to create the first admin row other than inserting it by hand with a BCrypt hash.

---

## What to implement next

Roughly in priority order:

1. **Apply the `kind` migration** to the database (see the note above) — everything on the customer side is broken until this is done.
2. **Commit a `schema.sql`** (tables above + a seed admin row) so the DB can be recreated from the repo, and grant/own the tables to `netbanking_app` so future migrations don't need superuser.
3. **Admin JSP views** — the six pages under `WebContent/views/admin/`, plus an admin sidebar fragment mirroring `fragments/sidebar-start.jsp` / `sidebar-end.jsp`. Wire the freeze/unfreeze/close/reactivate buttons as small POST forms with the `action` + `accountId` parameters `AdminUsersServlet` expects.
4. **Seed / bootstrap admin** — a tiny one-off `CreateAdmin` main class (or SQL with a pre-computed BCrypt hash) so an admin account can be created without editing the DB manually.
5. **Customer profile page** — view name/email/account number, change password.
6. **Input validation & UX polish** — server-side email/password strength checks on register, amount formatting on transfer, empty-state messages on history, pagination for history and the admin transaction log.
7. **Search / filter** on `/admin/users` (by name, email, account number, status) and `/admin/transactions` (by account, date range, kind).
8. **Transaction detail / receipt** page per transaction id (owned-by check for customers).
9. **Security hardening** — CSRF token on all POST forms, session timeout, `HttpOnly`/`SameSite` cookie flags in `web.xml`, rate-limit login attempts, generic error page instead of Tomcat's stack trace.
10. **Nice-to-haves** — beneficiary list / saved payees, scheduled transfers, email notifications, downloadable statement (CSV/PDF), unit tests for the service layer.
