package org.example.backendsignlik.service;

import org.example.backendsignlik.entity.MessageEntity;
import org.example.backendsignlik.entity.UserEntity;
import org.example.backendsignlik.repository.MessageRepository;
import org.example.backendsignlik.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class MessageService {

    @Autowired
    private MessageRepository messageRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private NotificationService notificationService;

    @Autowired
    private BlockedUserService blockedUserService;

    @Transactional
    public MessageEntity sendMessage(String fromEmail, String toEmail, String content, String type) {
        Optional<UserEntity> fromOpt = userRepository.findByEmail(fromEmail);
        Optional<UserEntity> toOpt = userRepository.findByEmail(toEmail);

        if (fromOpt.isEmpty() || toOpt.isEmpty()) {
            throw new IllegalArgumentException("User not found");
        }

        UserEntity from = fromOpt.get();
        UserEntity to = toOpt.get();

        // Check if users are blocked
        if (blockedUserService.isBlocked(fromEmail, toEmail)) {
            throw new IllegalArgumentException("Cannot send message: User is blocked");
        }

        MessageEntity message = new MessageEntity();
        message.setSender(from);
        message.setReceiver(to);
        message.setContent(content);
        message.setType(type != null ? type : "TEXT");
        message.setTimestamp(LocalDateTime.now());
        message.setIsRead(false);

        MessageEntity saved = messageRepository.save(message);

        // Notify receiver
        notificationService.createNotification(
            toEmail,
            "MESSAGE",
            "New message from " + from.getUsername(),
            saved.getId()
        );

        return saved;
    }

    public List<MessageEntity> getConversation(String userEmail1, String userEmail2) {
        Optional<UserEntity> user1Opt = userRepository.findByEmail(userEmail1);
        Optional<UserEntity> user2Opt = userRepository.findByEmail(userEmail2);

        if (user1Opt.isEmpty() || user2Opt.isEmpty()) {
            throw new IllegalArgumentException("User not found");
        }

        return messageRepository.findConversation(user1Opt.get(), user2Opt.get());
    }

    @Transactional
    public void markMessagesAsRead(String userEmail, String otherUserEmail) {
        Optional<UserEntity> userOpt = userRepository.findByEmail(userEmail);
        Optional<UserEntity> otherUserOpt = userRepository.findByEmail(otherUserEmail);

        if (userOpt.isEmpty() || otherUserOpt.isEmpty()) {
            return;
        }

        // Find unread messages from otherUser to user
        // Ideally we should have a repository method for this specific update, but we can iterate for now or add a custom query
        // For simplicity, let's just use the conversation and filter
        // Or better, let's add a method to repository later if needed.
        // But wait, findConversation gets all.
        // Let's use findConversation and filter in memory for now, or fetch by sender/receiver/unread
        
        List<MessageEntity> conversation = messageRepository.findConversation(userOpt.get(), otherUserOpt.get());
        for (MessageEntity msg : conversation) {
            if (msg.getReceiver().getEmail().equals(userEmail) && !msg.getIsRead()) {
                msg.setIsRead(true);
                messageRepository.save(msg);
            }
        }
    }

    public Long getUnreadCount(String userEmail) {
        Optional<UserEntity> userOpt = userRepository.findByEmail(userEmail);
        if (userOpt.isEmpty()) {
            return 0L;
        }
        return messageRepository.countUnreadMessages(userOpt.get());
    }

    public Optional<MessageEntity> getMessageById(Long id) {
        return messageRepository.findById(id);
    }
}
