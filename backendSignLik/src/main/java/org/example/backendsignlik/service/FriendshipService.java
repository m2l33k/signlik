package org.example.backendsignlik.service;

import org.example.backendsignlik.entity.FriendshipEntity;
import org.example.backendsignlik.entity.UserEntity;
import org.example.backendsignlik.repository.FriendshipRepository;
import org.example.backendsignlik.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class FriendshipService {

    @Autowired
    private FriendshipRepository friendshipRepository;
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private NotificationService notificationService;

    @Transactional
    public FriendshipEntity sendFriendRequest(String fromEmail, String toEmail) {
        Optional<UserEntity> fromOpt = userRepository.findByEmail(fromEmail);
        Optional<UserEntity> toOpt = userRepository.findByEmail(toEmail);
        
        if(fromOpt.isEmpty() || toOpt.isEmpty()) {
            throw new IllegalArgumentException("User not found");
        }
        
        UserEntity from = fromOpt.get();
        UserEntity to = toOpt.get();
        
        // Check if friendship already exists
        Optional<FriendshipEntity> existing = friendshipRepository.findFriendship(from, to);
        if(existing.isPresent()) {
            throw new IllegalArgumentException("Friendship request already exists");
        }
        
        FriendshipEntity friendship = new FriendshipEntity();
        friendship.setUser1(from);
        friendship.setUser2(to);
        friendship.setStatus("PENDING");
        
        FriendshipEntity saved = friendshipRepository.save(friendship);
        
        // Create notification
        notificationService.createNotification(
            toEmail,
            "FRIEND_REQUEST",
            from.getUsername() + " sent you a friend request",
            saved.getId()
        );
        
        return saved;
    }

    @Transactional
    public FriendshipEntity acceptFriendRequest(Long friendshipId, String userEmail) {
        Optional<FriendshipEntity> friendshipOpt = friendshipRepository.findById(friendshipId);
        Optional<UserEntity> userOpt = userRepository.findByEmail(userEmail);
        
        if(friendshipOpt.isEmpty() || userOpt.isEmpty()) {
            throw new IllegalArgumentException("Friendship or user not found");
        }
        
        FriendshipEntity friendship = friendshipOpt.get();
        if(!friendship.getUser2().getEmail().equals(userEmail)) {
            throw new IllegalArgumentException("You can only accept requests sent to you");
        }
        
        if(!"PENDING".equals(friendship.getStatus())) {
            throw new IllegalArgumentException("Friendship request is not pending");
        }
        
        friendship.setStatus("ACCEPTED");
        FriendshipEntity saved = friendshipRepository.save(friendship);
        
        // Create notification for requester
        notificationService.createNotification(
            friendship.getUser1().getEmail(),
            "FRIEND_ACCEPTED",
            userOpt.get().getUsername() + " accepted your friend request",
            saved.getId()
        );
        
        return saved;
    }

    @Transactional
    public void rejectFriendRequest(Long friendshipId, String userEmail) {
        Optional<FriendshipEntity> friendshipOpt = friendshipRepository.findById(friendshipId);
        if(friendshipOpt.isPresent()) {
            FriendshipEntity friendship = friendshipOpt.get();
            if(friendship.getUser2().getEmail().equals(userEmail)) {
                friendshipRepository.delete(friendship);
            }
        }
    }

    @Transactional
    public void removeFriend(String userEmail, String friendEmail) {
        Optional<UserEntity> userOpt = userRepository.findByEmail(userEmail);
        Optional<UserEntity> friendOpt = userRepository.findByEmail(friendEmail);
        
        if(userOpt.isPresent() && friendOpt.isPresent()) {
            Optional<FriendshipEntity> friendship = friendshipRepository.findFriendship(userOpt.get(), friendOpt.get());
            friendship.ifPresent(friendshipRepository::delete);
        }
    }

    public List<UserEntity> getFriends(String userEmail) {
        Optional<UserEntity> userOpt = userRepository.findByEmail(userEmail);
        if(userOpt.isEmpty()) {
            return List.of();
        }
        
        List<FriendshipEntity> friendships = friendshipRepository.findAcceptedFriendships(userOpt.get());
        return friendships.stream()
                .map(f -> f.getUser1().getEmail().equals(userEmail) ? f.getUser2() : f.getUser1())
                .collect(Collectors.toList());
    }

    public List<FriendshipEntity> getPendingFriendRequests(String userEmail) {
        Optional<UserEntity> userOpt = userRepository.findByEmail(userEmail);
        if(userOpt.isEmpty()) {
            return List.of();
        }
        return friendshipRepository.findPendingFriendRequests(userOpt.get());
    }
}

