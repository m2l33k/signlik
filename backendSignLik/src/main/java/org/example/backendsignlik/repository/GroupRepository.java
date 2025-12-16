package org.example.backendsignlik.repository;

import org.example.backendsignlik.entity.GroupEntity;
import org.example.backendsignlik.entity.UserEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface GroupRepository extends JpaRepository<GroupEntity, Long> {
    List<GroupEntity> findByCreator(UserEntity creator);
    List<GroupEntity> findByIsActiveTrue();
}

