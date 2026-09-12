package com.netbanking.tool;

import com.netbanking.dao.AdminDAO;
import com.netbanking.model.Admin;
import com.netbanking.util.PasswordUtil;

import java.io.BufferedReader;
import java.io.Console;
import java.io.IOException;
import java.io.InputStreamReader;
import java.sql.SQLException;
import java.util.Arrays;

/**
 * One-off command-line bootstrap for the very first admin account.
 *
 * There is no UI for creating admins (by design - admin accounts shouldn't
 * be self-service), so this is the only way to get one into the database
 * without hand-writing a BCrypt hash into a SQL INSERT.
 *
 * Usage (from netbanking/, after start.bat has compiled the classes at
 * least once so WebContent/WEB-INF/classes/db.properties is in place):
 *
 *   java -cp "WebContent\WEB-INF\classes;WebContent\WEB-INF\lib\postgresql-42.7.4.jar;WebContent\WEB-INF\lib\jbcrypt-0.4.jar" ^
 *        com.netbanking.tool.CreateAdmin "Admin Name" admin@example.com
 *
 * It then prompts for a password (hidden if run from a real terminal,
 * visible with a fallback prompt if run from an IDE console that has no
 * java.io.Console attached).
 */
public class CreateAdmin {

    // Shared across both readPassword() calls: a fresh BufferedReader wrapping
    // System.in on every call would each eagerly buffer-read whatever input is
    // already available (piped/redirected stdin in particular), so the first
    // reader can silently consume the line meant for the second one.
    private static final BufferedReader STDIN_FALLBACK = new BufferedReader(new InputStreamReader(System.in));

    public static void main(String[] args) {
        if (args.length != 2) {
            System.err.println("Usage: CreateAdmin <full name> <email>");
            System.exit(1);
        }

        String fullName = args[0];
        String email = args[1];

        AdminDAO adminDAO = new AdminDAO();

        try {
            if (adminDAO.findByEmail(email) != null) {
                System.err.println("An admin with email " + email + " already exists.");
                System.exit(1);
            }

            char[] password = readPassword("Password: ");
            char[] confirm = readPassword("Confirm password: ");

            if (!Arrays.equals(password, confirm)) {
                System.err.println("Passwords do not match.");
                System.exit(1);
            }
            if (password.length < 8) {
                System.err.println("Password must be at least 8 characters.");
                System.exit(1);
            }

            Admin admin = new Admin();
            admin.setFullName(fullName);
            admin.setEmail(email);
            admin.setPasswordHash(PasswordUtil.hash(new String(password)));

            Arrays.fill(password, '\0');
            Arrays.fill(confirm, '\0');

            adminDAO.create(admin);

            System.out.println("Admin created: id=" + admin.getAdminId() + ", email=" + admin.getEmail());
        } catch (SQLException e) {
            System.err.println("Database error: " + e.getMessage());
            System.exit(1);
        }
    }

    private static char[] readPassword(String prompt) {
        Console console = System.console();
        if (console != null) {
            return console.readPassword(prompt);
        }

        // No java.io.Console (common when run from an IDE) - fall back to a
        // plain, visible prompt read from stdin instead of failing outright.
        System.out.println(prompt + " (visible - no console attached)");
        try {
            String line = STDIN_FALLBACK.readLine();
            return line == null ? new char[0] : line.toCharArray();
        } catch (IOException e) {
            throw new RuntimeException("Failed to read password from stdin", e);
        }
    }
}
