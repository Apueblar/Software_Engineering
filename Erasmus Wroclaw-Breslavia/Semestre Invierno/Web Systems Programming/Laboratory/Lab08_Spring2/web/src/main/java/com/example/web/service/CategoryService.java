package com.example.web.service;

import com.example.web.entity.Category;
import com.example.web.repository.CategoryRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CategoryService {
    final CategoryRepository categoryRepository;

    public CategoryService(CategoryRepository categoryRepository) {
        this.categoryRepository = categoryRepository;
    }

    public List<Category> findAll() {
        return categoryRepository.findAll();
    }

    public Category findById(Integer id) {
        var value = categoryRepository.findById(id);
        return value.orElse(null);
    }

    public void add(Category c) {
        categoryRepository.save(c);
    }

    public void update(Category c) {
        categoryRepository.save(c);
    }

    public void delete(Integer id) {
        categoryRepository.deleteById(id);
    }
}
