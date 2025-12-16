package org.example.backendsignlik.controller;

import org.example.backendsignlik.entity.MessageReactionEntity;
import org.example.backendsignlik.service.MessageReactionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/reactions")
public class ReactionController {

    @Autowired
    private MessageReactionService reactionService;

    @PostMapping("/message/{messageId}")
    public ResponseEntity<?> addReaction(
            @PathVariable Long messageId,
            @RequestParam String reaction,
            Authentication authentication) {
        try {
            String userEmail = authentication.getName();
            MessageReactionEntity reactionEntity = reactionService.addReaction(messageId, userEmail, reaction);
            return ResponseEntity.ok(reactionEntity);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(400).body(e.getMessage());
        }
    }

    @DeleteMapping("/message/{messageId}")
    public ResponseEntity<?> removeReaction(
            @PathVariable Long messageId,
            Authentication authentication) {
        String userEmail = authentication.getName();
        reactionService.removeReaction(messageId, userEmail);
        return ResponseEntity.ok("Reaction removed");
    }

    @GetMapping("/message/{messageId}")
    public ResponseEntity<List<MessageReactionEntity>> getMessageReactions(@PathVariable Long messageId) {
        return ResponseEntity.ok(reactionService.getMessageReactions(messageId));
    }
}

