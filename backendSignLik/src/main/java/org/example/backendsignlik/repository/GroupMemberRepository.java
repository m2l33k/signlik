package org.example.backendsignlik.repository;

import org.example.backendsignlik.entity.GroupEntity;
import org.example.backendsignlik.entity.GroupMemberEntity;
import org.example.backendsignlik.entity.UserEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface GroupMemberRepository extends JpaRepository<GroupMemberEntity, Long> {
    List<GroupMemberEntity> findByGroup(GroupEntity group);
    List<GroupMemberEntity> findByUser(UserEntity user);
    Optional<GroupMemberEntity> findByGroupAndUser(GroupEntity group, UserEntity user);
    boolean existsByGroupAndUser(GroupEntity group, UserEntity user);
    void deleteByGroupAndUser(GroupEntity group, UserEntity user);
}

