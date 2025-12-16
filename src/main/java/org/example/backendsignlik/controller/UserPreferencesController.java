package org.example.backendsignlik.controller;

import org.example.backendsignlik.entity.UserPreferencesEntity;
import org.example.backendsignlik.service.UserPreferencesService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/preferences")
public class UserPreferencesController {

    @Autowired
    private UserPreferencesService preferencesService;

    @GetMapping
    public ResponseEntity<UserPreferencesEntity> getPreferences(Authentication authentication) {
        String userEmail = authentication.getName();
        return ResponseEntity.ok(preferencesService.getPreferences(userEmail));
    }

    @PutMapping
    public ResponseEntity<UserPreferencesEntity> updatePreferences(
            @RequestBody UserPreferencesEntity preferences,
            Authentication authentication) {
        String userEmail = authentication.getName();
        return ResponseEntity.ok(preferencesService.updatePreferences(userEmail, preferences));
    }
}

