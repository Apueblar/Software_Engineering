package com.example.web;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/product") // class-level mapping to avoid lots of /product
public class ProductController {
    private final ProductService pService;

    public ProductController(ProductService productService) { // @Qualifier("productService") ProductService productService if multiple service classes
        this.pService = productService;
    }

    // Model is the way a controller sends data to a Thymeleaf view

    @GetMapping // For get calls
    public String list(Model model) {
        model.addAttribute("products", pService.findAll());
        return "product/list";
    }

    @GetMapping("/add")
    public String addForm(Model model) {
        model.addAttribute("product", new Product());
        model.addAttribute("categories", Category.values());
        return "product/add";
    }

    @PostMapping("/add")
    public String add(@ModelAttribute Product product) {
        pService.add(product);
        return "redirect:/product";
    }

    @GetMapping("/{id}")
    public String details(@PathVariable Long id, Model model) {
        // @PathVariable — gets data from the URL path
        // @ModelAttribute — binds form data to an object
        model.addAttribute("product", pService.findById(id));
        return "product/details";
    }

    @GetMapping("/edit/{id}")
    public String editForm(@PathVariable Long id, Model model) {
        model.addAttribute("product", pService.findById(id));
        model.addAttribute("categories", Category.values());
        return "product/edit";
    }

    @PostMapping("/edit/{id}")
    public String edit(@PathVariable Long id, @ModelAttribute Product product) {
        pService.update(id, product);
        return "redirect:/product";
    }

    @GetMapping("/delete/{id}")
    public String delete(@PathVariable Long id) {
        pService.delete(id);
        return "redirect:/product";
    }
}
