package org.example.backendsignlik.service;

import org.example.backendsignlik.entity.UserEntity;
import org.example.backendsignlik.entity.UserPreferencesEntity;
import org.example.backendsignlik.repository.UserPreferencesRepository;
import org.example.backendsignlik.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.Optional;

@Service
public class UserPreferencesService {

    @Autowired
    private UserPreferencesRepository preferencesRepository;
    
    @Autowired
    private UserRepository userRepository;

    public UserPreferencesEntity getPreferences(String userEmail) {
        Optional<UserEntity> userOpt = userRepository.findByEmail(userEmail);
        if(userOpt.isEmpty()) {
            throw new IllegalArgumentException("User not found");
        }
        
        Optional<UserPreferencesEntity> prefsOpt = preferencesRepository.findByUser(userOpt.get());
        if(prefsOpt.isPresent()) {
            return prefsOpt.get();
        }
        
        // Create default preferences if they don't exist
        UserPreferencesEntity prefs = new UserPreferencesEntity(userOpt.get());
        return preferencesRepository.save(prefs);
    }

    @Transactional
    public UserPreferencesEntity updatePreferences(String userEmail, UserPreferencesEntity updatedPrefs) {
        Optional<UserEntity> userOpt = userRepository.findByEmail(userEmail);
        if(userOpt.isEmpty()) {
            throw new IllegalArgumentException("User not found");
        }
        
        UserPreferencesEntity prefs = getPreferences(userEmail);
        
        // Update fields
        if(updatedPrefs.getLanguage() != null) {
            prefs.setLanguage(updatedPrefs.getLanguage());
        }
        if(updatedPrefs.getTheme() != null) {
            prefs.setTheme(updatedPrefs.getTheme());
        }
        if(updatedPrefs.getNotificationsEnabled() != null) {
            prefs.setNotificationsEnabled(updatedPrefs.getNotificationsEnabled());
        }
        if(updatedPrefs.getEmailNotifications() != null) {
            prefs.setEmailNotifications(updatedPrefs.getEmailNotifications());
        }
        if(updatedPrefs.getPushNotifications() != null) {
            prefs.setPushNotifications(updatedPrefs.getPushNotifications());
        }
        if(updatedPrefs.getAutoPlayMedia() != null) {
            prefs.setAutoPlayMedia(updatedPrefs.getAutoPlayMedia());
        }
        if(updatedPrefs.getShowOnlineStatus() != null) {
            prefs.setShowOnlineStatus(updatedPrefs.getShowOnlineStatus());
        }
        if(updatedPrefs.getAllowFriendRequests() != null) {
            prefs.setAllowFriendRequests(updatedPrefs.getAllowFriendRequests());
        }
        if(updatedPrefs.getMessageSoundEnabled() != null) {
            prefs.setMessageSoundEnabled(updatedPrefs.getMessageSoundEnabled());
        }
        
        return preferencesRepository.save(prefs);
    }
}

