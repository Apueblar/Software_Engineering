package com.example.web.controller;

import com.example.web.entity.Category;
import com.example.web.exception.CategoryInUseException;
import com.example.web.service.CategoryService;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.*;
import org.springframework.web.bind.annotation.*;
import jakarta.validation.Valid;

import java.util.Collection;

@Controller
@RequestMapping("/category") // class-level mapping to avoid lots of /product
public class CategoryController {
    private final CategoryService cService;

    public CategoryController(CategoryService categoryService) { // @Qualifier("productService") ProductService productService if multiple service classes
        this.cService = categoryService;
    }

    @GetMapping("/add")
    public String addForm(Authentication authentication, org.springframework.ui.Model model) {
        if (!isAdmin(authentication)) {
            return "error/403";
        }
        model.addAttribute("category", new Category());
        return "category/add";
    }

    @PostMapping("/add")
    public String add(@Valid @ModelAttribute Category category, BindingResult result, Authentication authentication) {
        if (!isAdmin(authentication)) {
            return "error/403";
        }
        if (result.hasErrors()) {
            return "category/add";
        }
        cService.add(category);
        return "redirect:/";
    }

    @GetMapping("/edit/{id}")
    public String editForm(@PathVariable Long id, Model model, Authentication authentication) {
        if (!isAdmin(authentication)) {
            return "error/403";
        }
        model.addAttribute("category", cService.findById(id));
        return "category/edit";
    }

    @PostMapping("/edit/{id}")
    public String edit(@PathVariable Long id, @Valid @ModelAttribute  Category category, BindingResult result, Authentication authentication) {
        if (!isAdmin(authentication)) {
            return "error/403";
        }
        if (result.hasErrors()) {
            return "category/edit";
        }
        cService.update(id, category.getName(), category.getCode());
        return "redirect:/";
    }

    @GetMapping("/delete/{id}")
    public String delete(@PathVariable Long id, Authentication authentication) {
        if (!isAdmin(authentication)) {
            return "error/403";
        }
        try {
            cService.deleteCategory(id);
            return "redirect:/";
        } catch (CategoryInUseException e) {
            return "redirect:/?error=category-in-use";
        } catch (EntityNotFoundException e) {
            return "redirect:/?error=category-not-found";
        }
    }

    private boolean isAdmin(Authentication auth) {
        if (auth == null || !auth.isAuthenticated()) return false;
        Collection<? extends GrantedAuthority> authorities = auth.getAuthorities();
        return authorities.stream().anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"));
    }
}
