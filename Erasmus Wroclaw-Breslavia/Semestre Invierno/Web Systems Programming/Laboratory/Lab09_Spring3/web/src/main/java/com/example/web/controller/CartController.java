package com.example.web.controller;

import com.example.web.entity.Product;
import com.example.web.service.CartService;
import com.example.web.service.ProductService;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.*;

@Controller
@RequestMapping("/cart")
public class CartController {

    private final CartService cartService;
    private final ProductService productService;

    public CartController(CartService cartService, ProductService productService) {
        this.cartService = cartService;
        this.productService = productService;
    }

    /**
     * Cart view page
     */
    @GetMapping
    public String viewCart(Authentication authentication,
                           HttpServletRequest request,
                           Model model) {

        Map<Long, Integer> cart = cartService.readCart(request);

        List<Map<String, Object>> items = new ArrayList<>();
        double total = 0.0;

        for (Map.Entry<Long, Integer> entry : cart.entrySet()) {
            Product product = productService.findByIdWithCategory(entry.getKey());
            if (product == null) continue;

            int qty = entry.getValue();
            double lineTotal = qty * product.getPrice();
            total += lineTotal;

            Map<String, Object> item = new HashMap<>();
            item.put("product", product);
            item.put("quantity", qty);
            item.put("lineTotal", lineTotal);

            items.add(item);
        }

        int cartCount = cart.values().stream().mapToInt(Integer::intValue).sum();

        model.addAttribute("items", items);
        model.addAttribute("orderTotal", total);
        model.addAttribute("cartCount", cartCount);

        return "cart/view";
    }

    @PostMapping("/add/{productId}")
    public String addToCart(@PathVariable Long productId,
                            @RequestParam(defaultValue = "1") int qty,
                            HttpServletRequest request,
                            HttpServletResponse response) {
        if (qty > 0) { cartService.addItem(request, response, productId, qty);}
        return "redirect:/cart";
    }

    @PostMapping("/update/{productId}")
    public String update(@PathVariable Long productId,
                         @RequestParam int quantity,
                         HttpServletRequest request,
                         HttpServletResponse response) {
        cartService.updateItem(request, response, productId, quantity);
        return "redirect:/cart";
    }

    @PostMapping("/remove/{productId}")
    public String remove(@PathVariable Long productId,
                         HttpServletRequest request,
                         HttpServletResponse response) {
        cartService.removeItem(request, response, productId);
        return "redirect:/cart";
    }

    /**
     * Buy / checkout
     */
    @PostMapping("/buy")
    public String buy(Authentication authentication,
                      HttpServletResponse response,
                      HttpServletRequest request,
                      RedirectAttributes redirectAttributes) {
        if (!isClient(authentication)) {
            return "error/403";
        }

        // In a real app: create Order, persist, reduce stock, etc.
        cartService.clearCart(request, response);

        redirectAttributes.addFlashAttribute(
                "success",
                "✅ Purchase completed successfully!"
        );

        return "redirect:/cart";
    }

    private boolean isClient(Authentication auth) {
        if (auth == null || !auth.isAuthenticated()) return false;
        Collection<? extends GrantedAuthority> authorities = auth.getAuthorities();
        return authorities.stream().anyMatch(a -> a.getAuthority().equals("ROLE_CLIENT") || a.getAuthority().equals("ROLE_USER"));
    }
}
