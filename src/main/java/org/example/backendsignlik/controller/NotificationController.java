package org.example.backendsignlik.controller;

import org.example.backendsignlik.entity.NotificationEntity;
import org.example.backendsignlik.service.NotificationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/notifications")
public class NotificationController {

    @Autowired
    private NotificationService notificationService;

    @GetMapping
    public ResponseEntity<List<NotificationEntity>> getNotifications(Authentication authentication) {
        String userEmail = authentication.getName();
        return ResponseEntity.ok(notificationService.getUserNotifications(userEmail));
    }

    @GetMapping("/unread")
    public ResponseEntity<List<NotificationEntity>> getUnreadNotifications(Authentication authentication) {
        String userEmail = authentication.getName();
        return ResponseEntity.ok(notificationService.getUnreadNotifications(userEmail));
    }

    @GetMapping("/unread-count")
    public ResponseEntity<Long> getUnreadCount(Authentication authentication) {
        String userEmail = authentication.getName();
        return ResponseEntity.ok(notificationService.getUnreadNotificationCount(userEmail));
    }

    @PutMapping("/{id}/read")
    public ResponseEntity<?> markAsRead(@PathVariable Long id, Authentication authentication) {
        String userEmail = authentication.getName();
        notificationService.markAsRead(id, userEmail);
        return ResponseEntity.ok("Notification marked as read");
    }

    @PutMapping("/read-all")
    public ResponseEntity<?> markAllAsRead(Authentication authentication) {
        String userEmail = authentication.getName();
        notificationService.markAllAsRead(userEmail);
        return ResponseEntity.ok("All notifications marked as read");
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteNotification(@PathVariable Long id, Authentication authentication) {
        String userEmail = authentication.getName();
        notificationService.deleteNotification(id, userEmail);
        return ResponseEntity.ok("Notification deleted");
    }
}

