package org.example.backendsignlik.controller;

import org.example.backendsignlik.entity.FriendshipEntity;
import org.example.backendsignlik.entity.UserEntity;
import org.example.backendsignlik.mapper.UserMapper;
import org.example.backendsignlik.model.User;
import org.example.backendsignlik.service.FriendshipService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/friends")
public class FriendshipController {

    @Autowired
    private FriendshipService friendshipService;
    
    @Autowired
    private UserMapper userMapper;

    @PostMapping("/request")
    public ResponseEntity<?> sendFriendRequest(
            @RequestParam String toEmail,
            Authentication authentication) {
        try {
            String fromEmail = authentication.getName();
            FriendshipEntity friendship = friendshipService.sendFriendRequest(fromEmail, toEmail);
            return ResponseEntity.ok("Friend request sent successfully");
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(400).body(e.getMessage());
        }
    }

    @PutMapping("/accept/{friendshipId}")
    public ResponseEntity<?> acceptFriendRequest(
            @PathVariable Long friendshipId,
            Authentication authentication) {
        try {
            String userEmail = authentication.getName();
            friendshipService.acceptFriendRequest(friendshipId, userEmail);
            return ResponseEntity.ok("Friend request accepted");
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(400).body(e.getMessage());
        }
    }

    @DeleteMapping("/reject/{friendshipId}")
    public ResponseEntity<?> rejectFriendRequest(
            @PathVariable Long friendshipId,
            Authentication authentication) {
        String userEmail = authentication.getName();
        friendshipService.rejectFriendRequest(friendshipId, userEmail);
        return ResponseEntity.ok("Friend request rejected");
    }

    @DeleteMapping("/remove")
    public ResponseEntity<?> removeFriend(
            @RequestParam String friendEmail,
            Authentication authentication) {
        String userEmail = authentication.getName();
        friendshipService.removeFriend(userEmail, friendEmail);
        return ResponseEntity.ok("Friend removed");
    }

    @GetMapping
    public ResponseEntity<List<User>> getFriends(Authentication authentication) {
        String userEmail = authentication.getName();
        List<UserEntity> friends = friendshipService.getFriends(userEmail);
        List<User> userList = friends.stream()
                .map(userMapper::toModel)
                .collect(Collectors.toList());
        return ResponseEntity.ok(userList);
    }

    @GetMapping("/pending")
    public ResponseEntity<List<FriendshipEntity>> getPendingRequests(Authentication authentication) {
        String userEmail = authentication.getName();
        return ResponseEntity.ok(friendshipService.getPendingFriendRequests(userEmail));
    }
}

