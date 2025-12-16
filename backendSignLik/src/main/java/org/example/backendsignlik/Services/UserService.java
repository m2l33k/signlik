package org.example.backendsignlik.Services;

import org.example.backendsignlik.entity.UserEntity;
import org.example.backendsignlik.mapper.UserMapper;
import org.example.backendsignlik.model.User;
import org.example.backendsignlik.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private UserMapper userMapper;
    
    private final PasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    @Transactional
    public User register(User user){
        // Hash password before storing
        String hashedPassword = passwordEncoder.encode(user.getPassword());
        user.setPassword(hashedPassword);
        
        UserEntity entity = userMapper.toEntity(user);
        entity.setIsOnline(false);
        entity.setLastSeen(LocalDateTime.now());
        UserEntity saved = userRepository.save(entity);
        return userMapper.toModel(saved);
    }

    public Optional<User> findByEmail(String email){
        return userRepository.findByEmail(email)
                .map(userMapper::toModel);
    }
    
    public Optional<UserEntity> findEntityByEmail(String email){
        return userRepository.findByEmail(email);
    }

    public Optional<User> findByUsername(String username){
        return userRepository.findByUsername(username)
                .map(userMapper::toModel);
    }

    public List<User> searchUsers(String query){
        List<UserEntity> entities = userRepository.findByUsernameContainingIgnoreCaseOrEmailContainingIgnoreCase(query, query);
        return entities.stream()
                .map(userMapper::toModel)
                .collect(Collectors.toList());
    }

    public boolean verifyPassword(String rawPassword, String encodedPassword){
        return passwordEncoder.matches(rawPassword, encodedPassword);
    }

    @Transactional
    public User updateUser(String email, User updatedUser){
        return userRepository.findByEmail(email)
                .map(entity -> {
                    if(updatedUser.getUsername() != null && !updatedUser.getUsername().isEmpty()){
                        entity.setUsername(updatedUser.getUsername());
                    }
                    if(updatedUser.getPassword() != null && !updatedUser.getPassword().isEmpty()){
                        entity.setPassword(passwordEncoder.encode(updatedUser.getPassword()));
                    }
                    if(updatedUser.getRole() != null){
                        entity.setRole(updatedUser.getRole());
                    }
                    UserEntity saved = userRepository.save(entity);
                    return userMapper.toModel(saved);
                })
                .orElse(null);
    }

    public List<User> getAllUsers(){
        return userRepository.findAll().stream()
                .map(userMapper::toModel)
                .collect(Collectors.toList());
    }
    
    @Transactional
    public void setUserOnline(String email, boolean isOnline){
        userRepository.findByEmail(email).ifPresent(user -> {
            user.setIsOnline(isOnline);
            user.setLastSeen(LocalDateTime.now());
            userRepository.save(user);
        });
    }
    
    public List<User> getOnlineUsers(){
        return userRepository.findByIsOnlineTrue().stream()
                .map(userMapper::toModel)
                .collect(Collectors.toList());
    }
}
