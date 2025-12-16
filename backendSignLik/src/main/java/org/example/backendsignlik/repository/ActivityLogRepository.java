package org.example.backendsignlik.repository;

import org.example.backendsignlik.entity.ActivityLogEntity;
import org.example.backendsignlik.entity.UserEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface ActivityLogRepository extends JpaRepository<ActivityLogEntity, Long> {
    List<ActivityLogEntity> findByUserOrderByTimestampDesc(UserEntity user);
    
    @Query("SELECT a FROM ActivityLogEntity a WHERE a.user = :user AND a.timestamp >= :since ORDER BY a.timestamp DESC")
    List<ActivityLogEntity> findByUserSince(@Param("user") UserEntity user, @Param("since") LocalDateTime since);
    
    List<ActivityLogEntity> findByActionOrderByTimestampDesc(String action);
}

