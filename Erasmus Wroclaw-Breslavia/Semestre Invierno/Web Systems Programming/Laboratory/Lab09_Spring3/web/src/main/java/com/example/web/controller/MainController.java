package com.example.web.controller;

import com.example.web.entity.Product;
import com.example.web.service.CartService;
import com.example.web.service.CategoryService;
import com.example.web.service.ProductService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.util.Map;

@Controller
public class MainController {

    private final ProductService pService;
    private final CategoryService cService;
    private final CartService cartService;

    public MainController(ProductService productService,
                          CategoryService categoryService,
                          CartService cartService) {
        this.pService = productService;
        this.cService = categoryService;
        this.cartService = cartService;
    }

    @GetMapping
    public String list(Authentication authentication, HttpServletRequest request, Model model) {
        model.addAttribute("products", pService.findAllWithCategory());
        model.addAttribute("categories", cService.findAll());

        // Expose cart map and a simple cartCount (sum of quantities) so the template can show qty/remove
        Map<Long, Integer> cart = cartService.readCart(request);
        int cartCount = cart.values().stream().mapToInt(Integer::intValue).sum();
        model.addAttribute("cart", cart);
        model.addAttribute("cartCount", cartCount);

        return "list";
    }
}
