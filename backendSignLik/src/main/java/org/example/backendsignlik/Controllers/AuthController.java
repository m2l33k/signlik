package org.example.backendsignlik.Controllers;


import org.example.backendsignlik.Security.JwtUtil;
import org.example.backendsignlik.dto.LoginResponse;
import org.example.backendsignlik.model.User;
import org.example.backendsignlik.Services.UserService;
import org.example.backendsignlik.service.ActivityLogService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired private UserService userService;
    @Autowired
    private JwtUtil jwtUtil;
    @Autowired
    private ActivityLogService activityLogService;

    @PostMapping("/register")
    public ResponseEntity<?> register(@Valid @RequestBody User user, HttpServletRequest request){
        // Check if user already exists
        if(userService.findByEmail(user.getEmail()).isPresent()){
            return ResponseEntity.status(409).body("User with this email already exists");
        }
        if(userService.findByUsername(user.getUsername()).isPresent()){
            return ResponseEntity.status(409).body("Username already taken");
        }
        User registeredUser = userService.register(user);
        // Don't return password in response
        registeredUser.setPassword(null);
        
        // Log activity
        activityLogService.logActivity(user.getEmail(), "REGISTER", "User registered", request);
        
        return ResponseEntity.ok(registeredUser);
    }

    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(@Valid @RequestBody User user, HttpServletRequest request){
        return userService.findByEmail(user.getEmail())
                .map(u -> {
                    if(userService.verifyPassword(user.getPassword(), u.getPassword())){
                        // Set user online
                        userService.setUserOnline(u.getEmail(), true);
                        // Generate JWT token
                        String token = jwtUtil.generateToken(u);
                        
                        // Log activity
                        activityLogService.logActivity(u.getEmail(), "LOGIN", "User logged in", request);
                        
                        LoginResponse response = new LoginResponse();
                        response.setToken(token);
                        response.setEmail(u.getEmail());
                        response.setUsername(u.getUsername());
                        response.setRole(u.getRole().toString());
                        response.setMessage("Login successful");
                        return ResponseEntity.ok(response);
                    } else {
                        // Log failed login attempt
                        activityLogService.logActivity(user.getEmail(), "LOGIN_FAILED", "Failed login attempt", request);
                        LoginResponse errorResponse = new LoginResponse();
                        errorResponse.setMessage("Wrong password");
                        return ResponseEntity.status(401).body(errorResponse);
                    }
                })
                .orElseGet(() -> {
                    LoginResponse errorResponse = new LoginResponse();
                    errorResponse.setMessage("User not found");
                    return ResponseEntity.status(404).body(errorResponse);
                });
    }
}
