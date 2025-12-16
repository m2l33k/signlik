package org.example.backendsignlik.repository;

import org.example.backendsignlik.entity.MessageEntity;
import org.example.backendsignlik.entity.MessageReactionEntity;
import org.example.backendsignlik.entity.UserEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface MessageReactionRepository extends JpaRepository<MessageReactionEntity, Long> {
    List<MessageReactionEntity> findByMessage(MessageEntity message);
    Optional<MessageReactionEntity> findByMessageAndUser(MessageEntity message, UserEntity user);
    void deleteByMessageAndUser(MessageEntity message, UserEntity user);
}

