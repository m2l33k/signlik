package org.example.backendsignlik.service;

import org.example.backendsignlik.entity.NotificationEntity;
import org.example.backendsignlik.entity.UserEntity;
import org.example.backendsignlik.repository.NotificationRepository;
import org.example.backendsignlik.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class NotificationService {

    @Autowired
    private NotificationRepository notificationRepository;
    
    @Autowired
    private UserRepository userRepository;

    @Transactional
    public NotificationEntity createNotification(String userEmail, String type, String content, Long relatedId) {
        Optional<UserEntity> userOpt = userRepository.findByEmail(userEmail);
        if(userOpt.isEmpty()) {
            throw new IllegalArgumentException("User not found");
        }
        
        NotificationEntity notification = new NotificationEntity();
        notification.setUser(userOpt.get());
        notification.setType(type);
        notification.setContent(content);
        notification.setRelatedId(relatedId);
        notification.setTimestamp(LocalDateTime.now());
        notification.setIsRead(false);
        
        return notificationRepository.save(notification);
    }

    public List<NotificationEntity> getUserNotifications(String userEmail) {
        Optional<UserEntity> userOpt = userRepository.findByEmail(userEmail);
        if(userOpt.isEmpty()) {
            return List.of();
        }
        return notificationRepository.findByUserOrderByTimestampDesc(userOpt.get());
    }

    public List<NotificationEntity> getUnreadNotifications(String userEmail) {
        Optional<UserEntity> userOpt = userRepository.findByEmail(userEmail);
        if(userOpt.isEmpty()) {
            return List.of();
        }
        return notificationRepository.findByUserAndIsReadFalse(userOpt.get());
    }

    public Long getUnreadNotificationCount(String userEmail) {
        Optional<UserEntity> userOpt = userRepository.findByEmail(userEmail);
        if(userOpt.isEmpty()) {
            return 0L;
        }
        return notificationRepository.countByUserAndIsReadFalse(userOpt.get());
    }

    @Transactional
    public void markAsRead(Long notificationId, String userEmail) {
        Optional<NotificationEntity> notificationOpt = notificationRepository.findById(notificationId);
        Optional<UserEntity> userOpt = userRepository.findByEmail(userEmail);
        
        if(notificationOpt.isPresent() && userOpt.isPresent()) {
            NotificationEntity notification = notificationOpt.get();
            if(notification.getUser().getEmail().equals(userEmail)) {
                notification.setIsRead(true);
                notificationRepository.save(notification);
            }
        }
    }

    @Transactional
    public void markAllAsRead(String userEmail) {
        Optional<UserEntity> userOpt = userRepository.findByEmail(userEmail);
        if(userOpt.isPresent()) {
            List<NotificationEntity> notifications = notificationRepository.findByUserAndIsReadFalse(userOpt.get());
            notifications.forEach(n -> n.setIsRead(true));
            notificationRepository.saveAll(notifications);
        }
    }

    @Transactional
    public void deleteNotification(Long notificationId, String userEmail) {
        Optional<NotificationEntity> notificationOpt = notificationRepository.findById(notificationId);
        if(notificationOpt.isPresent()) {
            NotificationEntity notification = notificationOpt.get();
            if(notification.getUser().getEmail().equals(userEmail)) {
                notificationRepository.delete(notification);
            }
        }
    }
}

