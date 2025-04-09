package com.example.trivytestapp.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.example.trivytestapp.model.Todo;

public interface TodoRepository extends JpaRepository<Todo, Long> {
} 