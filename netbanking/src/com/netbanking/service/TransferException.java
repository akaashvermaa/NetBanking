package com.netbanking.service;

/**
 * Signals an expected transfer failure (insufficient balance, frozen account,
 * unknown recipient, self-transfer) as opposed to an unexpected SQLException -
 * lets the servlet show the message directly instead of a generic error page.
 */
public class TransferException extends Exception {

    public TransferException(String message) {
        super(message);
    }
}
