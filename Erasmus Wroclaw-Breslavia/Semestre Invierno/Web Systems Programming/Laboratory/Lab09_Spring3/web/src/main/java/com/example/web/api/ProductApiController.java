package com.example.web.api;

import com.example.web.entity.Product;
import com.example.web.service.ProductService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/product")
public class ProductApiController {

    private final ProductService productService;

    public ProductApiController(ProductService productService) {
        this.productService = productService;
    }

    // READ ALL
    @GetMapping
    public List<Product> getAll() {
        return productService.findAllWithCategory();
    }

    // READ ONE
    @GetMapping("/{id}")
    public ResponseEntity<Product> getById(@PathVariable Long id) {
        Product product = productService.findByIdWithCategory(id);
        if (product == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(product);
    }

    // CREATE
    @PostMapping
    public ResponseEntity<Void> create(@Valid @RequestBody Product product) {
        productService.add(product); // void
        return ResponseEntity.status(HttpStatus.CREATED).build();
    }

    // UPDATE
    @PutMapping("/{id}")
    public ResponseEntity<Void> update(@PathVariable Long id,
                                       @Valid @RequestBody Product product) {
        Product existing = productService.findByIdWithCategory(id);
        if (existing == null) {
            return ResponseEntity.notFound().build();
        }
        product.setId(id);
        productService.update(product); // void
        return ResponseEntity.ok().build();
    }

    // DELETE
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        Product existing = productService.findByIdWithCategory(id);
        if (existing == null) {
            return ResponseEntity.notFound().build();
        }
        productService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
