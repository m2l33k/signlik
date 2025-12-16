package org.example.backendsignlik.repository;

import org.example.backendsignlik.entity.UserEntity;
import org.example.backendsignlik.entity.UserPreferencesEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface UserPreferencesRepository extends JpaRepository<UserPreferencesEntity, Long> {
    Optional<UserPreferencesEntity> findByUser(UserEntity user);
    Optional<UserPreferencesEntity> findByUserEmail(String email);
}

