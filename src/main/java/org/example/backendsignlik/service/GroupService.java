package org.example.backendsignlik.service;

import org.example.backendsignlik.entity.GroupEntity;
import org.example.backendsignlik.entity.GroupMemberEntity;
import org.example.backendsignlik.entity.MessageEntity;
import org.example.backendsignlik.entity.UserEntity;
import org.example.backendsignlik.repository.GroupMemberRepository;
import org.example.backendsignlik.repository.GroupRepository;
import org.example.backendsignlik.repository.MessageRepository;
import org.example.backendsignlik.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class GroupService {

    @Autowired
    private GroupRepository groupRepository;
    
    @Autowired
    private GroupMemberRepository groupMemberRepository;
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private MessageRepository messageRepository;

    @Transactional
    public GroupEntity createGroup(String name, String description, String creatorEmail) {
        Optional<UserEntity> creatorOpt = userRepository.findByEmail(creatorEmail);
        if(creatorOpt.isEmpty()) {
            throw new IllegalArgumentException("Creator not found");
        }
        
        GroupEntity group = new GroupEntity();
        group.setName(name);
        group.setDescription(description);
        group.setCreator(creatorOpt.get());
        
        GroupEntity saved = groupRepository.save(group);
        
        // Add creator as admin
        GroupMemberEntity member = new GroupMemberEntity();
        member.setGroup(saved);
        member.setUser(creatorOpt.get());
        member.setRole("ADMIN");
        groupMemberRepository.save(member);
        
        return saved;
    }

    @Transactional
    public GroupMemberEntity addMemberToGroup(Long groupId, String userEmail, String role) {
        Optional<GroupEntity> groupOpt = groupRepository.findById(groupId);
        Optional<UserEntity> userOpt = userRepository.findByEmail(userEmail);
        
        if(groupOpt.isEmpty() || userOpt.isEmpty()) {
            throw new IllegalArgumentException("Group or user not found");
        }
        
        // Check if already a member
        if(groupMemberRepository.existsByGroupAndUser(groupOpt.get(), userOpt.get())) {
            throw new IllegalArgumentException("User is already a member of this group");
        }
        
        GroupMemberEntity member = new GroupMemberEntity();
        member.setGroup(groupOpt.get());
        member.setUser(userOpt.get());
        member.setRole(role != null ? role : "MEMBER");
        
        return groupMemberRepository.save(member);
    }

    @Transactional
    public void removeMemberFromGroup(Long groupId, String userEmail) {
        Optional<GroupEntity> groupOpt = groupRepository.findById(groupId);
        Optional<UserEntity> userOpt = userRepository.findByEmail(userEmail);
        
        if(groupOpt.isPresent() && userOpt.isPresent()) {
            groupMemberRepository.deleteByGroupAndUser(groupOpt.get(), userOpt.get());
        }
    }

    public List<GroupEntity> getUserGroups(String userEmail) {
        Optional<UserEntity> userOpt = userRepository.findByEmail(userEmail);
        if(userOpt.isEmpty()) {
            return List.of();
        }
        
        List<GroupMemberEntity> memberships = groupMemberRepository.findByUser(userOpt.get());
        return memberships.stream()
                .map(GroupMemberEntity::getGroup)
                .filter(g -> g.getIsActive())
                .collect(Collectors.toList());
    }

    public List<UserEntity> getGroupMembers(Long groupId) {
        Optional<GroupEntity> groupOpt = groupRepository.findById(groupId);
        if(groupOpt.isEmpty()) {
            return List.of();
        }
        
        List<GroupMemberEntity> members = groupMemberRepository.findByGroup(groupOpt.get());
        return members.stream()
                .map(GroupMemberEntity::getUser)
                .collect(Collectors.toList());
    }

    public List<MessageEntity> getGroupMessages(Long groupId) {
        Optional<GroupEntity> groupOpt = groupRepository.findById(groupId);
        if(groupOpt.isEmpty()) {
            return List.of();
        }
        
        // For group messages, we'll need to add a group_id field to MessageEntity
        // For now, this is a placeholder
        return List.of();
    }
}

