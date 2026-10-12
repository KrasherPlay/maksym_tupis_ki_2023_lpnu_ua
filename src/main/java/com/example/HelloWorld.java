package com.example;

public final class HelloWorld {
    private HelloWorld() {
    }

    public static String message() {
        return "Hello, World!";
    }

    public static void main(String[] args) {
        System.out.println(message());
    }
}
