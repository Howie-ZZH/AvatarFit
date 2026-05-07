package com.fitgame.backend.workout;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ExerciseRepository extends JpaRepository<Exercise, String> {
    List<Exercise> findAllByStatusOrderBySortOrderAsc(String status);
}
