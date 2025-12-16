package org.example.backendsignlik.controller;

import org.example.backendsignlik.entity.ActivityLogEntity;
import org.example.backendsignlik.service.ActivityLogService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/activity")
public class ActivityLogController {

    @Autowired
    private ActivityLogService activityLogService;

    @GetMapping
    public ResponseEntity<List<ActivityLogEntity>> getActivity(Authentication authentication) {
        String userEmail = authentication.getName();
        return ResponseEntity.ok(activityLogService.getUserActivity(userEmail));
    }

    @GetMapping("/since")
    public ResponseEntity<List<ActivityLogEntity>> getActivitySince(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime since,
            Authentication authentication) {
        String userEmail = authentication.getName();
        return ResponseEntity.ok(activityLogService.getUserActivitySince(userEmail, since));
    }
}

