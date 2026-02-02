package com.example.web.service;

import com.example.web.entity.Category;
import com.example.web.exception.CategoryInUseException;
import com.example.web.repository.CategoryRepository;
import com.example.web.repository.ProductRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
public class CategoryService {
    final CategoryRepository categoryRepository;
    final ProductRepository productRepository;

    public CategoryService(CategoryRepository categoryRepository, ProductRepository productRepository) {
        this.categoryRepository = categoryRepository;
        this.productRepository = productRepository;
    }

    public List<Category> findAll() {
        return categoryRepository.findAll();
    }

    public Category findById(Long id) {
        var value = categoryRepository.findById(id);
        return value.orElse(null);
    }

    public void add(Category c) {
        categoryRepository.save(c);
    }

    @Transactional
    public void update(Long id, String newName, String newCode) {
        Category managed = categoryRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Category not found: " + id));
        managed.setName(newName);
        managed.setCode(newCode);
    }
    @Transactional
    public void deleteCategory(Long categoryId) {

        if (productRepository.existsByCategoryId(categoryId)) {
            throw new CategoryInUseException(
                    "Cannot delete category: it has associated products"
            );
        }

        categoryRepository.deleteById(categoryId);
    }
}
