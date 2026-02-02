package com.example.web.controller;

import com.example.web.service.CategoryService;
import com.example.web.service.ProductService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class MainController {

    private final ProductService pService;
    private final CategoryService cService;

    public MainController(ProductService productService, CategoryService categoryService) { // @Qualifier("productService") ProductService productService if multiple service classes
        this.pService = productService;
        this.cService = categoryService;
    }

    @GetMapping
    public String list(Model model) {
        model.addAttribute("products", pService.findAll());
        model.addAttribute("categories", cService.findAll());
        return "list";
    }
}
