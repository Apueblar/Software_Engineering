package com.example.web.api;

import com.example.web.entity.Category;
import com.example.web.service.CategoryService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/category")
public class CategoryApiController {

    private final CategoryService categoryService;

    public CategoryApiController(CategoryService categoryService) {
        this.categoryService = categoryService;
    }

    // READ ALL
    @GetMapping
    public List<Category> getAll() {
        return categoryService.findAll();
    }

    // READ ONE
    @GetMapping("/{id}")
    public ResponseEntity<Category> getById(@PathVariable Long id) {
        Category category = categoryService.findById(id);
        if (category == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(category);
    }

    // CREATE -> service returns void, so respond 201 with no body
    @PostMapping("/add")
    public ResponseEntity<Void> create(@Valid @RequestBody Category category) {
        categoryService.add(category); // void
        return ResponseEntity.status(HttpStatus.CREATED).build();
    }

    // UPDATE -> service returns void
    @PutMapping("/delete/{id}")
    public ResponseEntity<Void> update(@PathVariable Long id, @Valid @RequestBody Category category) {
        Category existing = categoryService.findById(id);
        if (existing == null) {
            return ResponseEntity.notFound().build();
        }
        categoryService.update(id, category.getName(), category.getCode());
        return ResponseEntity.ok().build();
    }

    // DELETE
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        categoryService.deleteCategory(id);
        return ResponseEntity.noContent().build();
    }
}
