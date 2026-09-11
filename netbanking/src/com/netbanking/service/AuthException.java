package com.netbanking.service;

/**
 * Signals an expected authentication/registration failure (bad credentials,
 * duplicate email, frozen account) as opposed to an unexpected SQLException -
 * lets the servlet show the message directly instead of a generic error page.
 */
public class AuthException extends Exception {

    public AuthException(String message) {
        super(message);
    }
}
