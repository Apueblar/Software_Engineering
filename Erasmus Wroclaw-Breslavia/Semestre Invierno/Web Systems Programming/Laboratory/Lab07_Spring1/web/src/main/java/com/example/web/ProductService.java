package com.example.web;

import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class ProductService {
    private final Map<Long, Product> products = new HashMap<Long, Product>();
    private long nextId = 0;

    public ProductService() {}

    public List<Product> findAll() {
        return new ArrayList<Product>(products.values());
    }

    public Product findById(Long id) {
        return products.get(id); // Given the key, selects the product
    }

    public void add(Product p) {
        p.setId(nextId++);
        products.put(p.getId(), p);
    }

    public void update(Long id, Product updated) {
        updated.setId(id);
        products.put(id, updated);
    }

    public void delete(Long id) {
        products.remove(id);
    }
}
