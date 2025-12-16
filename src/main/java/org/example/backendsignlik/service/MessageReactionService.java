package org.example.backendsignlik.service;

import org.example.backendsignlik.entity.MessageEntity;
import org.example.backendsignlik.entity.MessageReactionEntity;
import org.example.backendsignlik.entity.UserEntity;
import org.example.backendsignlik.repository.MessageReactionRepository;
import org.example.backendsignlik.repository.MessageRepository;
import org.example.backendsignlik.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.Optional;

@Service
public class MessageReactionService {

    @Autowired
    private MessageReactionRepository reactionRepository;
    
    @Autowired
    private MessageRepository messageRepository;
    
    @Autowired
    private UserRepository userRepository;

    @Transactional
    public MessageReactionEntity addReaction(Long messageId, String userEmail, String reaction) {
        Optional<MessageEntity> messageOpt = messageRepository.findById(messageId);
        Optional<UserEntity> userOpt = userRepository.findByEmail(userEmail);
        
        if(messageOpt.isEmpty() || userOpt.isEmpty()) {
            throw new IllegalArgumentException("Message or user not found");
        }
        
        // Check if user already reacted
        Optional<MessageReactionEntity> existing = reactionRepository.findByMessageAndUser(messageOpt.get(), userOpt.get());
        if(existing.isPresent()) {
            // Update existing reaction
            MessageReactionEntity existingReaction = existing.get();
            existingReaction.setReaction(reaction);
            return reactionRepository.save(existingReaction);
        }
        
        // Create new reaction
        MessageReactionEntity reactionEntity = new MessageReactionEntity();
        reactionEntity.setMessage(messageOpt.get());
        reactionEntity.setUser(userOpt.get());
        reactionEntity.setReaction(reaction);
        
        return reactionRepository.save(reactionEntity);
    }

    @Transactional
    public void removeReaction(Long messageId, String userEmail) {
        Optional<MessageEntity> messageOpt = messageRepository.findById(messageId);
        Optional<UserEntity> userOpt = userRepository.findByEmail(userEmail);
        
        if(messageOpt.isPresent() && userOpt.isPresent()) {
            reactionRepository.deleteByMessageAndUser(messageOpt.get(), userOpt.get());
        }
    }

    public List<MessageReactionEntity> getMessageReactions(Long messageId) {
        Optional<MessageEntity> messageOpt = messageRepository.findById(messageId);
        if(messageOpt.isEmpty()) {
            return List.of();
        }
        return reactionRepository.findByMessage(messageOpt.get());
    }
}

