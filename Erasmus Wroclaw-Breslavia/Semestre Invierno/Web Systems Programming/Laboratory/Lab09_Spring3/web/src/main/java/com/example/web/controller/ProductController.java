package com.example.web.controller;

import com.example.web.entity.Product;
import com.example.web.service.CartService;
import com.example.web.service.CategoryService;
import com.example.web.service.ProductService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import jakarta.validation.Valid;

import java.util.Collection;

@Controller
@RequestMapping("/product") // class-level mapping to avoid lots of /product
public class ProductController {

    private final ProductService pService;
    private final CategoryService cService;
    private final CartService cartService;

    public ProductController(ProductService productService,
                             CategoryService categoryService,
                             CartService cartService) {
        this.pService = productService;
        this.cService = categoryService;
        this.cartService = cartService;
    }

    // Anyone can view product details
    @GetMapping("/{id}")
    public String details(@PathVariable Long id, Authentication authentication,
                          HttpServletRequest request, Model model) {
        model.addAttribute("product", pService.findByIdWithCategory(id));

        // expose cart info (so template can show current quantity and Remove button)
        model.addAttribute("cart", cartService.readCart(request));
        model.addAttribute("cartCount", cartService.readCart(request).values().stream().mapToInt(Integer::intValue).sum());

        return "product/details";
    }


    // Admin only: form
    @GetMapping("/add")
    public String addForm(Authentication authentication, Model model) {
        if (!isAdmin(authentication)) {
            return "error/403";
        }
        model.addAttribute("product", new Product());
        model.addAttribute("categories", cService.findAll());
        return "product/add";
    }

    // Admin only: submit
    @PostMapping("/add")
    public String add(@Valid @ModelAttribute Product product, BindingResult result,
                      Authentication authentication, Model model) {
        if (!isAdmin(authentication)) {
            return "error/403";
        }
        if (result.hasErrors()) {
            model.addAttribute("categories", cService.findAll());
            return "product/add";
        }
        pService.add(product);
        return "redirect:/";
    }


    // Admin only: edit form
    @GetMapping("/edit/{id}")
    public String editForm(@PathVariable Long id, Authentication authentication, Model model) {
        if (!isAdmin(authentication)) {
            return "error/403";
        }
        model.addAttribute("product", pService.findByIdWithCategory(id));
        model.addAttribute("categories", cService.findAll());
        return "product/edit";
    }

    // Admin only: submit edit
    @PostMapping("/edit/{id}")
    public String edit(@PathVariable Long id, @Valid @ModelAttribute Product product,
                       BindingResult result, Authentication authentication, Model model) {
        if (!isAdmin(authentication)) {
            return "error/403";
        }
        if (result.hasErrors()) {
            model.addAttribute("categories", cService.findAll());
            product.setId(id);
            return "product/edit";
        }
        product.setId(id);
        pService.update(product);
        return "redirect:/";
    }


    // Admin only: delete
    @GetMapping("/delete/{id}")
    public String delete(@PathVariable Long id, Authentication authentication) {
        if (!isAdmin(authentication)) {
            return "error/403";
        }
        pService.delete(id);
        return "redirect:/";
    }

    private boolean isAdmin(Authentication auth) {
        if (auth == null || !auth.isAuthenticated()) { return false; }
        Collection<? extends GrantedAuthority> authorities = auth.getAuthorities();
        return authorities.stream().anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"));
    }
}