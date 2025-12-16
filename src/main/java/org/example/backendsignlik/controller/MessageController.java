package org.example.backendsignlik.controller;

import org.example.backendsignlik.entity.MessageEntity;
import org.example.backendsignlik.mapper.MessageMapper;
import org.example.backendsignlik.model.Message;
import org.example.backendsignlik.service.MessageService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

import java.util.Optional;

@RestController
@RequestMapping("/api/messages")
public class MessageController {

    @Autowired
    private MessageService messageService;

    @Autowired
    private MessageMapper messageMapper;

    @PostMapping("/send")
    public ResponseEntity<?> sendMessage(
            @RequestParam String toEmail,
            @RequestParam String content,
            @RequestParam(required = false, defaultValue = "TEXT") String type,
            Authentication authentication) {
        try {
            String fromEmail = authentication.getName();
            MessageEntity message = messageService.sendMessage(fromEmail, toEmail, content, type);
            return ResponseEntity.ok(messageMapper.toModel(message));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(400).body(e.getMessage());
        }
    }

    @GetMapping("/conversation")
    public ResponseEntity<?> getConversation(
            @RequestParam String withEmail,
            Authentication authentication) {
        try {
            String userEmail = authentication.getName();
            List<MessageEntity> conversation = messageService.getConversation(userEmail, withEmail);
            List<Message> messages = conversation.stream()
                    .map(messageMapper::toModel)
                    .collect(Collectors.toList());
            return ResponseEntity.ok(messages);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(400).body(e.getMessage());
        }
    }

    @PutMapping("/read")
    public ResponseEntity<?> markAsRead(
            @RequestParam String withEmail,
            Authentication authentication) {
        String userEmail = authentication.getName();
        messageService.markMessagesAsRead(userEmail, withEmail);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getMessageById(
            @PathVariable Long id,
            Authentication authentication) {
        Optional<MessageEntity> msg = messageService.getMessageById(id);
        if (msg.isPresent()) {
             return ResponseEntity.ok(messageMapper.toModel(msg.get()));
        }
        return ResponseEntity.notFound().build();
    }

    @GetMapping("/unread-count")
    public ResponseEntity<Long> getUnreadCount(Authentication authentication) {
        String userEmail = authentication.getName();
        return ResponseEntity.ok(messageService.getUnreadCount(userEmail));
    }
}
