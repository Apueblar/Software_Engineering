package com.example.web.util;

import jakarta.servlet.http.*;
import org.springframework.http.ResponseCookie;

public final class CookieUtils {

    private CookieUtils() {}

    public static void addCookie(HttpServletResponse response, String name, String value, int maxAgeSeconds) {
        ResponseCookie cookie = ResponseCookie.from(name, value)
                .httpOnly(true) // accessible from JS if you want to allow client-side updates
                .path("/")
                .maxAge(maxAgeSeconds)
                .sameSite("Lax")
                .build();
        response.addHeader("Set-Cookie", cookie.toString());
    }

    public static Cookie getCookie(HttpServletRequest request, String name) {
        if (request.getCookies() == null) return null;
        for (Cookie c : request.getCookies()) {
            if (c.getName().equals(name)) return c;
        }
        return null;
    }
}
