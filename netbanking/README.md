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
├── schema.sql        Full DB schema — run once against a fresh database
├── src/com/netbanking/
│   ├── controller/   Servlets (one per URL)
│   ├── filter/       LoginFilter, AdminAuthFilter (session guards)
│   ├── service/      Business rules + transactions (AuthService, TransferService, Admin*Service)
│   ├── dao/          JDBC access (UserDAO, AccountDAO, TransactionDAO, AdminDAO)
│   ├── model/        POJOs (User, Account, Transaction, Admin)
│   ├── tool/         CreateAdmin — one-off CLI to bootstrap the first admin row
│   └── util/         DBConnection (reads db.properties), PasswordUtil (BCrypt)
├── WebContent/
│   ├── views/        JSPs (login, register, dashboard, transfer, history, fragments/sidebar-*)
│   │   └── admin/    Admin JSPs + fragments/admin-sidebar-*
│   ├── static/css/   style.css
│   └── WEB-INF/
│       ├── classes/  compiled output + db.properties (+ db.properties.example template)
│       └── lib/      postgresql + jbcrypt jars
└── start.bat
```

## Running locally

1. Create the role, database, and schema in PostgreSQL — see **Database schema** below, which walks through `schema.sql`.
2. Copy `WebContent/WEB-INF/classes/db.properties.example` to `db.properties` in the same folder and fill in your own credentials (this file is gitignored — never commit real credentials):
   ```properties
   db.url=jdbc:postgresql://localhost:5432/NetBanking
   db.username=netbanking_app
   db.password=...
   ```
3. Edit the `JAVA_HOME` / `CATALINA_HOME` paths at the top of `start.bat` if they differ on your machine.
4. Run `start.bat`. It compiles everything, starts Tomcat and opens `http://localhost:8080/netbanking/login`.
5. Create the first admin account (there is no self-service admin signup, by design):
   ```
   java -cp "WebContent\WEB-INF\classes;WebContent\WEB-INF\lib\postgresql-42.7.4.jar;WebContent\WEB-INF\lib\jbcrypt-0.4.jar" com.netbanking.tool.CreateAdmin "Admin Name" admin@example.com
   ```
   It prompts for a password (hidden in a real terminal; visible with a fallback prompt if run somewhere with no attached console, e.g. some IDE run configurations) and inserts the row using the same BCrypt hashing the app uses. Then log in at `/admin/login`.

## Database schema

`schema.sql` in the repo root creates all four tables (`users`, `accounts`, `transactions`, `admins`) with the indexes and check constraints the app relies on, owned by `netbanking_app` so it can run future migrations itself without needing superuser access. As a superuser (e.g. `postgres`):

```sql
CREATE ROLE netbanking_app WITH LOGIN PASSWORD 'choose-a-password';
CREATE DATABASE "NetBanking" OWNER netbanking_app;
\c NetBanking
\i schema.sql
```

Two things worth knowing if you're working against an older/hand-created copy of this database instead of a fresh `schema.sql` run:
- `transactions.kind` was added to the Java code after the table already existed in some environments. If you see `column "kind" does not exist`, run (as the table owner): `ALTER TABLE transactions ADD COLUMN IF NOT EXISTS kind VARCHAR(20) NOT NULL DEFAULT 'TRANSFER';`
- The original `accounts_status_check` constraint only allowed `ACTIVE`/`FROZEN` — `CLOSED` (used throughout the admin UI) would be rejected by the database. Fix with:
  ```sql
  ALTER TABLE accounts DROP CONSTRAINT accounts_status_check;
  ALTER TABLE accounts ADD CONSTRAINT accounts_status_check CHECK (status IN ('ACTIVE', 'FROZEN', 'CLOSED'));
  ```

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

### Admin side — complete (backend + JSP views)

| URL                     | Servlet                     | What it does |
|-------------------------|-----------------------------|--------------|
| `/admin/login`          | `AdminLoginServlet`         | Separate admin login against the `admins` table; stores the admin in the session. |
| `/admin/logout`         | `AdminLogoutServlet`        | Invalidates the admin session. |
| `/admin/dashboard`      | `AdminDashboardServlet`     | System stats in one query: total users / accounts / balance, active / frozen / closed counts, total transactions. |
| `/admin/users`          | `AdminUsersServlet`         | Lists every account with holder name + email; POST actions `freeze`, `unfreeze`, `close`, `reactivate` with state-transition validation and flash messages. |
| `/admin/add-user`       | `AdminAddUserServlet`       | Admin creates a customer through the same path as self-registration. |
| `/admin/adjust-balance` | `AdminAdjustBalanceServlet` | Credit or debit any account by account number with a mandatory reason; logged as `ADMIN_CREDIT` / `ADMIN_DEBIT`, atomic with the balance change, cannot go below zero or touch a closed account. |
| `/admin/transactions`   | `AdminTransactionsServlet`  | Global transaction log with both account numbers joined in. |

`AdminAuthFilter` guards all admin pages except `/admin/login`. The six views under `WebContent/views/admin/` (plus `fragments/admin-sidebar-*`) are written, wired to the exact `action`/`accountId` POST parameters each servlet expects, and share the customer-facing design system (tokens, `.card`/`.txn-table`/`.badge` components). There is no admin self-signup by design — use `com.netbanking.tool.CreateAdmin` (see **Running locally**) to create the first one.

---

## What to implement next

Roughly in priority order:

1. **Customer profile page** — view name/email/account number, change password.
2. **Input validation & UX polish** — server-side email/password strength checks on register, amount formatting on transfer, empty-state messages on history, pagination for history and the admin transaction log.
3. **Search / filter** on `/admin/users` (by name, email, account number, status) and `/admin/transactions` (by account, date range, kind).
4. **Transaction detail / receipt** page per transaction id (owned-by check for customers).
5. **Security hardening** — CSRF token on all POST forms, session timeout, `HttpOnly`/`SameSite` cookie flags in `web.xml`, rate-limit login attempts, generic error page instead of Tomcat's stack trace.
6. **Nice-to-haves** — beneficiary list / saved payees, scheduled transfers, email notifications, downloadable statement (CSV/PDF), unit tests for the service layer.
