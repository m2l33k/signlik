package org.example.backendsignlik.service;

import org.example.backendsignlik.entity.ActivityLogEntity;
import org.example.backendsignlik.entity.UserEntity;
import org.example.backendsignlik.repository.ActivityLogRepository;
import org.example.backendsignlik.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import jakarta.servlet.http.HttpServletRequest;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class ActivityLogService {

    @Autowired
    private ActivityLogRepository activityLogRepository;
    
    @Autowired
    private UserRepository userRepository;

    @Transactional
    public ActivityLogEntity logActivity(String userEmail, String action, String description, HttpServletRequest request) {
        Optional<UserEntity> userOpt = userRepository.findByEmail(userEmail);
        UserEntity user = userOpt.orElse(null);
        
        ActivityLogEntity log = new ActivityLogEntity();
        log.setUser(user);
        log.setAction(action);
        log.setDescription(description);
        
        if(request != null) {
            log.setIpAddress(getClientIpAddress(request));
            log.setUserAgent(request.getHeader("User-Agent"));
        }
        
        return activityLogRepository.save(log);
    }

    public List<ActivityLogEntity> getUserActivity(String userEmail) {
        Optional<UserEntity> userOpt = userRepository.findByEmail(userEmail);
        if(userOpt.isEmpty()) {
            return List.of();
        }
        return activityLogRepository.findByUserOrderByTimestampDesc(userOpt.get());
    }

    public List<ActivityLogEntity> getUserActivitySince(String userEmail, LocalDateTime since) {
        Optional<UserEntity> userOpt = userRepository.findByEmail(userEmail);
        if(userOpt.isEmpty()) {
            return List.of();
        }
        return activityLogRepository.findByUserSince(userOpt.get(), since);
    }

    private String getClientIpAddress(HttpServletRequest request) {
        String xForwardedFor = request.getHeader("X-Forwarded-For");
        if(xForwardedFor != null && !xForwardedFor.isEmpty()) {
            return xForwardedFor.split(",")[0].trim();
        }
        String xRealIp = request.getHeader("X-Real-IP");
        if(xRealIp != null && !xRealIp.isEmpty()) {
            return xRealIp;
        }
        return request.getRemoteAddr();
    }
}

