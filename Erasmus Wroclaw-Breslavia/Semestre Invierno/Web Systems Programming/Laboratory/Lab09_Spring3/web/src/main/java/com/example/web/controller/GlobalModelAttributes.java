package com.example.web.controller;

import com.example.web.service.CartService;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

import jakarta.servlet.http.HttpServletRequest;
import java.util.Map;

@ControllerAdvice
public class GlobalModelAttributes {

    private final CartService cartService;

    public GlobalModelAttributes(CartService cartService) {
        this.cartService = cartService;
    }

    @ModelAttribute
    public void addGlobalAttributes(HttpServletRequest request,
                                    Authentication authentication,
                                    org.springframework.ui.Model model) {
        // read cart from cookies (CartService handles null cookies and malformed entries)
        Map<Long, Integer> cart = cartService.readCart(request);
        int cartCount = cart.values().stream().mapToInt(Integer::intValue).sum();

        model.addAttribute("cart", cart);
        model.addAttribute("cartCount", cartCount);
        model.addAttribute("auth", authentication);
    }
}
