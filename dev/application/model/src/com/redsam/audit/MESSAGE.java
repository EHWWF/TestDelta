package com.redsam.audit;

/**
 * Red Samurai Audit. Version 4.0
 */
public enum MESSAGE {
    SLOW_QUERY("Slow query"),
    SLOW_COUNT_QUERY("Slow query count"),
    LARGE_FETCH("Large fetch"),
    SLOW_ACTIVATION("Slow activation"),
    FULL_SCAN("Full scan"),
    SLOW_PLSQL("Slow pl/sql");

    private String displayName;

    MESSAGE(String displayName) {
        this.displayName = displayName;
    }

    public String toString() {
        return displayName;
    }
}
