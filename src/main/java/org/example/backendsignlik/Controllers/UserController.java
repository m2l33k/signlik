package org.example.backendsignlik.Controllers;

import org.example.backendsignlik.dto.UserProfileResponse;
import org.example.backendsignlik.model.User;
import org.example.backendsignlik.Services.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/users")
public class UserController {

    @Autowired
    private UserService userService;

    @GetMapping("/profile/{email}")
    public ResponseEntity<?> getProfile(@PathVariable String email){
        return userService.findByEmail(email)
                .map(user -> {
                    UserProfileResponse response = new UserProfileResponse();
                    response.setUsername(user.getUsername());
                    response.setEmail(user.getEmail());
                    response.setRole(user.getRole().toString());
                    return ResponseEntity.<UserProfileResponse>ok(response);
                })
                .orElse(ResponseEntity.status(404).<UserProfileResponse>body(null));
    }

    @PutMapping("/profile/{email}")
    public ResponseEntity<?> updateProfile(@PathVariable String email, @RequestBody User updatedUser){
        User updated = userService.updateUser(email, updatedUser);
        if(updated != null){
            updated.setPassword(null); // Don't return password
            return ResponseEntity.ok(updated);
        }
        return ResponseEntity.status(404).body("User not found");
    }

    @GetMapping("/search")
    public ResponseEntity<List<UserProfileResponse>> searchUsers(@RequestParam String query){
        List<User> users = userService.searchUsers(query);
        List<UserProfileResponse> responses = users.stream()
                .map(user -> {
                    UserProfileResponse response = new UserProfileResponse();
                    response.setUsername(user.getUsername());
                    response.setEmail(user.getEmail());
                    response.setRole(user.getRole().toString());
                    return response;
                })
                .collect(Collectors.toList());
        return ResponseEntity.ok(responses);
    }

    @GetMapping("/all")
    public ResponseEntity<List<UserProfileResponse>> getAllUsers(){
        List<User> users = userService.getAllUsers();
        List<UserProfileResponse> responses = users.stream()
                .map(user -> {
                    UserProfileResponse response = new UserProfileResponse();
                    response.setUsername(user.getUsername());
                    response.setEmail(user.getEmail());
                    response.setRole(user.getRole().toString());
                    return response;
                })
                .collect(Collectors.toList());
        return ResponseEntity.ok(responses);
    }
    
    @PutMapping("/{email}/online")
    public ResponseEntity<?> setUserOnline(@PathVariable String email, @RequestParam boolean online){
        userService.setUserOnline(email, online);
        return ResponseEntity.ok("User status updated");
    }
    
    @GetMapping("/online")
    public ResponseEntity<List<UserProfileResponse>> getOnlineUsers(){
        List<User> users = userService.getOnlineUsers();
        List<UserProfileResponse> responses = users.stream()
                .map(user -> {
                    UserProfileResponse response = new UserProfileResponse();
                    response.setUsername(user.getUsername());
                    response.setEmail(user.getEmail());
                    response.setRole(user.getRole().toString());
                    return response;
                })
                .collect(Collectors.toList());
        return ResponseEntity.ok(responses);
    }
}

