package org.example.backendsignlik.controller;

import org.example.backendsignlik.entity.BlockedUserEntity;
import org.example.backendsignlik.entity.UserEntity;
import org.example.backendsignlik.mapper.UserMapper;
import org.example.backendsignlik.model.User;
import org.example.backendsignlik.service.BlockedUserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/blocked")
public class BlockedUserController {

    @Autowired
    private BlockedUserService blockedUserService;
    
    @Autowired
    private UserMapper userMapper;

    @PostMapping("/block")
    public ResponseEntity<?> blockUser(
            @RequestParam String blockedUserEmail,
            @RequestParam(required = false) String reason,
            Authentication authentication) {
        try {
            String userEmail = authentication.getName();
            BlockedUserEntity block = blockedUserService.blockUser(userEmail, blockedUserEmail, reason);
            return ResponseEntity.ok("User blocked successfully");
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(400).body(e.getMessage());
        }
    }

    @PostMapping("/unblock")
    public ResponseEntity<?> unblockUser(
            @RequestParam String blockedUserEmail,
            Authentication authentication) {
        String userEmail = authentication.getName();
        blockedUserService.unblockUser(userEmail, blockedUserEmail);
        return ResponseEntity.ok("User unblocked successfully");
    }

    @GetMapping
    public ResponseEntity<List<User>> getBlockedUsers(Authentication authentication) {
        String userEmail = authentication.getName();
        List<UserEntity> blockedUsers = blockedUserService.getBlockedUsers(userEmail);
        List<User> userList = blockedUsers.stream()
                .map(userMapper::toModel)
                .collect(Collectors.toList());
        return ResponseEntity.ok(userList);
    }

    @GetMapping("/check")
    public ResponseEntity<Map<String, Boolean>> checkBlocked(
            @RequestParam String otherUserEmail,
            Authentication authentication) {
        String userEmail = authentication.getName();
        boolean isBlocked = blockedUserService.isBlocked(userEmail, otherUserEmail);
        return ResponseEntity.ok(Map.of("isBlocked", isBlocked));
    }
}

