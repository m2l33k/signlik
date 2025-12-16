package org.example.backendsignlik.repository;

import org.example.backendsignlik.entity.MessageEntity;
import org.example.backendsignlik.entity.UserEntity;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface MessageRepository extends JpaRepository<MessageEntity, Long> {
    List<MessageEntity> findBySenderOrReceiver(UserEntity sender, UserEntity receiver);
    
    @Query("SELECT m FROM MessageEntity m WHERE (m.sender = :user1 AND m.receiver = :user2) OR (m.sender = :user2 AND m.receiver = :user1) ORDER BY m.timestamp ASC")
    List<MessageEntity> findConversation(@Param("user1") UserEntity user1, @Param("user2") UserEntity user2);
    
    List<MessageEntity> findByTypeIgnoreCase(String type);
    
    List<MessageEntity> findByReceiverAndIsReadFalse(UserEntity receiver);
    
    Page<MessageEntity> findAll(Pageable pageable);
    
    @Query("SELECT COUNT(m) FROM MessageEntity m WHERE m.receiver = :receiver AND m.isRead = false")
    Long countUnreadMessages(@Param("receiver") UserEntity receiver);
}

