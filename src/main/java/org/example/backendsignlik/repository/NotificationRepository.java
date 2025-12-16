package org.example.backendsignlik.repository;

import org.example.backendsignlik.entity.NotificationEntity;
import org.example.backendsignlik.entity.UserEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface NotificationRepository extends JpaRepository<NotificationEntity, Long> {
    List<NotificationEntity> findByUserOrderByTimestampDesc(UserEntity user);
    List<NotificationEntity> findByUserAndIsReadFalse(UserEntity user);
    Long countByUserAndIsReadFalse(UserEntity user);
    void deleteByUser(UserEntity user);
}

