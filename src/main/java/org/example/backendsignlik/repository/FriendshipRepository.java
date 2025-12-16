package org.example.backendsignlik.repository;

import org.example.backendsignlik.entity.FriendshipEntity;
import org.example.backendsignlik.entity.UserEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface FriendshipRepository extends JpaRepository<FriendshipEntity, Long> {
    @Query("SELECT f FROM FriendshipEntity f WHERE (f.user1 = :user1 AND f.user2 = :user2) OR (f.user1 = :user2 AND f.user2 = :user1)")
    Optional<FriendshipEntity> findFriendship(@Param("user1") UserEntity user1, @Param("user2") UserEntity user2);
    
    @Query("SELECT f FROM FriendshipEntity f WHERE (f.user1 = :user OR f.user2 = :user) AND f.status = 'ACCEPTED'")
    List<FriendshipEntity> findAcceptedFriendships(@Param("user") UserEntity user);
    
    @Query("SELECT f FROM FriendshipEntity f WHERE f.user2 = :user AND f.status = 'PENDING'")
    List<FriendshipEntity> findPendingFriendRequests(@Param("user") UserEntity user);

    @Query("SELECT f FROM FriendshipEntity f WHERE f.user1 = :user AND f.status = 'PENDING'")
    List<FriendshipEntity> findSentFriendRequests(@Param("user") UserEntity user);
}

