package com.example.web.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import jakarta.servlet.http.*;
import org.springframework.stereotype.Service;
import com.example.web.util.CookieUtils;

import java.util.HashMap;
import java.util.Map;

@Service
public class CartService {

    private static final String COOKIE_PREFIX = "prod";
    private static final int COOKIE_AGE = 60 * 60 * 24 * 30; // 30 days

    /**
     * Read cart by scanning all cookies named "prod{productId}".
     * Example cookie: prod123=2 (productId=123, qty=2)
     */
    public Map<Long, Integer> readCart(HttpServletRequest request) {
        Map<Long, Integer> cart = new HashMap<>();
        Cookie[] cookies = request.getCookies();

        if (cookies == null) return cart;

        for (Cookie cookie : cookies) {
            String name = cookie.getName();
            if (name != null && name.startsWith(COOKIE_PREFIX)) {
                String idStr = name.substring(COOKIE_PREFIX.length());
                try {
                    Long id = Long.valueOf(idStr);
                    String val = cookie.getValue();
                    if (val != null && !val.isBlank()) {
                        int quantity = Integer.parseInt(val);
                        if (quantity > 0) {cart.put(id, quantity);}
                    }
                } catch (NumberFormatException e) {
                    // ignore :)
                }
            }
        }
        return cart;
    }

    public void saveCart(HttpServletRequest request, HttpServletResponse response, Map<Long, Integer> cart) {
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                String name = cookie.getName();
                if (name != null && name.startsWith(COOKIE_PREFIX)) {
                    String idStr = name.substring(COOKIE_PREFIX.length());
                    try {
                        Long id = Long.valueOf(idStr);
                        if (!cart.containsKey(id)) { // Avoid replicated keys
                            CookieUtils.addCookie(response, name, "", 0);
                            ;
                        }
                    } catch (NumberFormatException e) {
                        // ignore :)
                    }
                }
            }
        }

        // add/update cookies for each cart entry
        for (Map.Entry<Long, Integer> e : cart.entrySet()) {
            Long id = e.getKey();
            Integer qty = e.getValue();
            if (qty == null || qty <= 0) { // Only positive quantity of products
                CookieUtils.addCookie(response, COOKIE_PREFIX + id, "", 0); // delete if zero/invalid
            } else {
                CookieUtils.addCookie(response, COOKIE_PREFIX + id, String.valueOf(qty), COOKIE_AGE);
            }
        }
    }

    public void addItem(HttpServletRequest request, HttpServletResponse response, Long productId, int qty) {
        Map<Long, Integer> cart = readCart(request);
        cart.put(productId, cart.getOrDefault(productId, 0) + qty);
        saveCart(request, response, cart);
    }

    public void updateItem(HttpServletRequest request, HttpServletResponse response, Long productId, int qty) {
        Map<Long, Integer> cart = readCart(request);
        if (qty <= 0) { cart.remove(productId); }
        else cart.put(productId, qty);
        saveCart(request, response, cart);
    }

    public void removeItem(HttpServletRequest request, HttpServletResponse response, Long productId) {
        Map<Long, Integer> cart = readCart(request);
        cart.remove(productId);
        saveCart(request, response, cart);
    }

    public void clearCart(HttpServletRequest request, HttpServletResponse response) {
        Cookie[] cookies = request.getCookies();
        if (cookies == null) { return; }
        for (Cookie c : cookies) {
            String name = c.getName();
            if (name != null && name.startsWith(COOKIE_PREFIX)) {
                CookieUtils.addCookie(response, name, "", 0);
            }
        }
    }
}
