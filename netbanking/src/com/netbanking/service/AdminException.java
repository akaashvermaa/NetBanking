package com.netbanking.service;

/**
 * Signals an expected admin-action failure (invalid status transition, unknown
 * account, bad adjustment) so the servlet can show the message directly.
 */
public class AdminException extends Exception {

    public AdminException(String message) {
        super(message);
    }
}
