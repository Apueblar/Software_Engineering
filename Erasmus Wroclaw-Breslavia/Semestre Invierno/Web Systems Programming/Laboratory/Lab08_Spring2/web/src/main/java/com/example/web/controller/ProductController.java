package com.example.web.controller;

import com.example.web.entity.Product;
import com.example.web.service.CategoryService;
import com.example.web.service.ProductService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import jakarta.validation.Valid;

@Controller
@RequestMapping("/product") // class-level mapping to avoid lots of /product
public class ProductController {
    private final ProductService pService;
    private final CategoryService cService;

    public ProductController(ProductService productService, CategoryService categoryService) { // @Qualifier("productService") ProductService productService if multiple service classes
        this.pService = productService;
        this.cService = categoryService;
    }

    // Model is the way a controller sends data to a Thymeleaf view

    @GetMapping("/add")
    public String addForm(Model model) {
        model.addAttribute("product", new Product());
        model.addAttribute("categories", cService.findAll());
        return "product/add";
    }

    @PostMapping("/add")
    public String add(@Valid @ModelAttribute Product product, BindingResult result, Model model) {
        if (result.hasErrors()) {
            model.addAttribute("categories", cService.findAll());
            return "product/add";
        }
        pService.add(product);
        return "redirect:/";
    }

    @GetMapping("/{id}")
    public String details(@PathVariable Integer id, Model model) {
        // @PathVariable — gets data from the URL path
        // @ModelAttribute — binds form data to an object
        model.addAttribute("product", pService.findById(id));
        return "product/details";
    }

    @GetMapping("/edit/{id}")
    public String editForm(@PathVariable Integer id, Model model) {
        model.addAttribute("product", pService.findById(id));
        model.addAttribute("categories", cService.findAll());
        return "product/edit";
    }

    @PostMapping("/edit/{id}")
    public String edit(@PathVariable Long id, @Valid @ModelAttribute Product product, BindingResult result, Model model) {
        if (result.hasErrors()) {
            model.addAttribute("categories", cService.findAll());
            product.setId(id); // keep id in form
            return "product/edit";
        }
        product.setId(id);
        pService.update(product);
        return "redirect:/";
    }

    @GetMapping("/delete/{id}")
    public String delete(@PathVariable Integer id) {
        pService.delete(id);
        return "redirect:/";
    }
}