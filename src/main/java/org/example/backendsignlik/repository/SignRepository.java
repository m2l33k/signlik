package org.example.backendsignlik.repository;

import org.example.backendsignlik.entity.SignEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface SignRepository extends JpaRepository<SignEntity, Long> {
    
    Optional<SignEntity> findByName(String name);
    
    List<SignEntity> findByCreatedBy(String createdBy);
    
    List<SignEntity> findByCategory(String category);
    
    List<SignEntity> findByIsApproved(Boolean isApproved);
    
    List<SignEntity> findByDifficultyLevel(String difficultyLevel);
    
    @Query("SELECT s FROM SignEntity s WHERE s.name LIKE %:query% OR s.description LIKE %:query%")
    List<SignEntity> searchSigns(@Param("query") String query);
    
    @Query("SELECT s FROM SignEntity s WHERE s.isApproved = true ORDER BY s.viewCount DESC")
    List<SignEntity> findPopularSigns();
    
    @Query("SELECT s FROM SignEntity s WHERE s.isApproved = true ORDER BY s.createdAt DESC")
    List<SignEntity> findRecentSigns();
}

