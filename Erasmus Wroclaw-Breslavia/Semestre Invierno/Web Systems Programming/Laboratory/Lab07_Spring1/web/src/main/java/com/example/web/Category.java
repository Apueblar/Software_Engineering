package com.example.web;

public enum Category {
    FISH("Fish"), PASTA("Pasta");

    private Category(final String name) {
        this.name = name;
    }

    private final String name;

    public String getName() {
        return this.name;
    }

}
