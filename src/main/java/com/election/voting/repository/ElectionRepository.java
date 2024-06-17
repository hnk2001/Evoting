package com.election.voting.repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.election.voting.model.Election;

public interface ElectionRepository extends JpaRepository<Election, Long> {
    @Query("SELECT e FROM Election e WHERE e.id = ?1")
    Optional<Election> findById(Long id);

    @Query("SELECT e FROM Election e WHERE LOWER(e.name) = LOWER(?1)")
    Optional<Election> findByName(String name);

    @Query("SELECT e.id FROM Election e WHERE e.name = :name")
    Long findIdByName(String name);

    @Query("SELECT e FROM Election e WHERE LOWER(e.name) = LOWER(:name)")
    Optional<Election> findByNameIgnoreCase(@Param("name") String name);

    @Query("SELECT e FROM Election e WHERE e.admin.id = ?1")
    List<Election> findByAdminId(Long adminId);
}