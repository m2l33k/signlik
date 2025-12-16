package org.example.backendsignlik.repository;

import org.example.backendsignlik.entity.BlockedUserEntity;
import org.example.backendsignlik.entity.UserEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface BlockedUserRepository extends JpaRepository<BlockedUserEntity, Long> {
    @Query("SELECT b FROM BlockedUserEntity b WHERE b.user = :user AND b.blockedUser = :blockedUser")
    Optional<BlockedUserEntity> findBlock(@Param("user") UserEntity user, @Param("blockedUser") UserEntity blockedUser);
    
    List<BlockedUserEntity> findByUser(UserEntity user);
    
    @Query("SELECT b FROM BlockedUserEntity b WHERE (b.user = :user1 AND b.blockedUser = :user2) OR (b.user = :user2 AND b.blockedUser = :user1)")
    List<BlockedUserEntity> findBlockBetweenUsers(@Param("user1") UserEntity user1, @Param("user2") UserEntity user2);
}

