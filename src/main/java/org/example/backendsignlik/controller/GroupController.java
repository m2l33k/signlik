package org.example.backendsignlik.controller;

import org.example.backendsignlik.entity.GroupEntity;
import org.example.backendsignlik.entity.UserEntity;
import org.example.backendsignlik.mapper.UserMapper;
import org.example.backendsignlik.model.User;
import org.example.backendsignlik.service.GroupService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/groups")
public class GroupController {

    @Autowired
    private GroupService groupService;
    
    @Autowired
    private UserMapper userMapper;

    @PostMapping("/create")
    public ResponseEntity<?> createGroup(
            @RequestParam String name,
            @RequestParam(required = false) String description,
            Authentication authentication) {
        try {
            String creatorEmail = authentication.getName();
            GroupEntity group = groupService.createGroup(name, description, creatorEmail);
            return ResponseEntity.ok(group);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(400).body(e.getMessage());
        }
    }

    @PostMapping("/{groupId}/members")
    public ResponseEntity<?> addMember(
            @PathVariable Long groupId,
            @RequestParam String userEmail,
            @RequestParam(required = false, defaultValue = "MEMBER") String role,
            Authentication authentication) {
        try {
            groupService.addMemberToGroup(groupId, userEmail, role);
            return ResponseEntity.ok("Member added to group");
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(400).body(e.getMessage());
        }
    }

    @DeleteMapping("/{groupId}/members")
    public ResponseEntity<?> removeMember(
            @PathVariable Long groupId,
            @RequestParam String userEmail,
            Authentication authentication) {
        groupService.removeMemberFromGroup(groupId, userEmail);
        return ResponseEntity.ok("Member removed from group");
    }

    @GetMapping("/my-groups")
    public ResponseEntity<List<GroupEntity>> getMyGroups(Authentication authentication) {
        String userEmail = authentication.getName();
        return ResponseEntity.ok(groupService.getUserGroups(userEmail));
    }

    @GetMapping("/{groupId}/members")
    public ResponseEntity<List<User>> getGroupMembers(@PathVariable Long groupId) {
        List<UserEntity> members = groupService.getGroupMembers(groupId);
        List<User> userList = members.stream()
                .map(userMapper::toModel)
                .collect(Collectors.toList());
        return ResponseEntity.ok(userList);
    }
}

