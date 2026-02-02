package com.example.web.repository;

import com.example.web.entity.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ProductRepository extends JpaRepository<Product,Long> {

    boolean existsByCategoryId(Long categoryId);

    @Query("select p from Product p join fetch p.category")
    List<Product> findAllWithCategory();

    @Query("select p from Product p join fetch p.category where p.id = :id")
    Optional<Product> findByIdWithCategory(@Param("id") Long id);
}

