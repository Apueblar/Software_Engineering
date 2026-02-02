package com.example.web.service;

import com.example.web.entity.Product;
import com.example.web.repository.ProductRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ProductService {
    final ProductRepository productRepository;

    public ProductService(ProductRepository productRepository) {
        this.productRepository = productRepository;
    }

    public List<Product> findAll() {
        return productRepository.findAll();
    }

    public Product findById(Integer id) {
        var value = productRepository.findById(id);
        return value.orElse(null);
    }

    public void add(Product p) {
        productRepository.save(p);
    }

    public void update(Product p) {
        productRepository.save(p);
    }

    public void delete(Integer id) {
        productRepository.deleteById(id);
    }
}
