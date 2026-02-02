package com.example.web.controller;

import com.example.web.entity.Category;
import com.example.web.service.CategoryService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.*;
import org.springframework.web.bind.annotation.*;
import jakarta.validation.Valid;

@Controller
@RequestMapping("/category") // class-level mapping to avoid lots of /product
public class CategoryController {
    private final CategoryService cService;

    public CategoryController(CategoryService categoryService) { // @Qualifier("productService") ProductService productService if multiple service classes
        this.cService = categoryService;
    }

    @GetMapping("/add")
    public String addForm(Model model) {
        model.addAttribute("category", new Category());
        return "category/add";
    }

    @PostMapping("/add")
    public String add(@Valid @ModelAttribute Category category, BindingResult result) {
        if (result.hasErrors()) {
            return "category/add";
        }
        cService.add(category);
        return "redirect:/";
    }

    @GetMapping("/edit/{id}")
    public String editForm(@PathVariable Integer id, Model model) {
        model.addAttribute("category", cService.findById(id));
        return "category/edit";
    }

    @PostMapping("/edit/{id}")
    public String edit(@PathVariable Long id, @Valid @ModelAttribute  Category category, BindingResult result) {
        if (result.hasErrors()) {
            category.setId(id);
            return "category/edit";
        }
        category.setId(id);
        cService.update(category);
        return "redirect:/";
    }

    @GetMapping("/delete/{id}")
    public String delete(@PathVariable Integer id) {
        cService.delete(id);
        return "redirect:/";
    }
}
