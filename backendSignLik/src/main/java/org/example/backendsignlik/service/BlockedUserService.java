package org.example.backendsignlik.service;

import org.example.backendsignlik.entity.BlockedUserEntity;
import org.example.backendsignlik.entity.UserEntity;
import org.example.backendsignlik.repository.BlockedUserRepository;
import org.example.backendsignlik.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class BlockedUserService {

    @Autowired
    private BlockedUserRepository blockedUserRepository;
    
    @Autowired
    private UserRepository userRepository;

    @Transactional
    public BlockedUserEntity blockUser(String userEmail, String blockedUserEmail, String reason) {
        Optional<UserEntity> userOpt = userRepository.findByEmail(userEmail);
        Optional<UserEntity> blockedUserOpt = userRepository.findByEmail(blockedUserEmail);
        
        if(userOpt.isEmpty() || blockedUserOpt.isEmpty()) {
            throw new IllegalArgumentException("User not found");
        }
        
        if(userEmail.equals(blockedUserEmail)) {
            throw new IllegalArgumentException("Cannot block yourself");
        }
        
        // Check if already blocked
        Optional<BlockedUserEntity> existing = blockedUserRepository.findBlock(userOpt.get(), blockedUserOpt.get());
        if(existing.isPresent()) {
            throw new IllegalArgumentException("User is already blocked");
        }
        
        BlockedUserEntity block = new BlockedUserEntity();
        block.setUser(userOpt.get());
        block.setBlockedUser(blockedUserOpt.get());
        block.setReason(reason);
        
        return blockedUserRepository.save(block);
    }

    @Transactional
    public void unblockUser(String userEmail, String blockedUserEmail) {
        Optional<UserEntity> userOpt = userRepository.findByEmail(userEmail);
        Optional<UserEntity> blockedUserOpt = userRepository.findByEmail(blockedUserEmail);
        
        if(userOpt.isPresent() && blockedUserOpt.isPresent()) {
            Optional<BlockedUserEntity> block = blockedUserRepository.findBlock(userOpt.get(), blockedUserOpt.get());
            block.ifPresent(blockedUserRepository::delete);
        }
    }

    public List<UserEntity> getBlockedUsers(String userEmail) {
        Optional<UserEntity> userOpt = userRepository.findByEmail(userEmail);
        if(userOpt.isEmpty()) {
            return List.of();
        }
        
        List<BlockedUserEntity> blocks = blockedUserRepository.findByUser(userOpt.get());
        return blocks.stream()
                .map(BlockedUserEntity::getBlockedUser)
                .collect(Collectors.toList());
    }

    public boolean isBlocked(String user1Email, String user2Email) {
        Optional<UserEntity> user1Opt = userRepository.findByEmail(user1Email);
        Optional<UserEntity> user2Opt = userRepository.findByEmail(user2Email);
        
        if(user1Opt.isEmpty() || user2Opt.isEmpty()) {
            return false;
        }
        
        List<BlockedUserEntity> blocks = blockedUserRepository.findBlockBetweenUsers(user1Opt.get(), user2Opt.get());
        return !blocks.isEmpty();
    }
}

