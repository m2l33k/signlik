package org.example.backendsignlik.service;

import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@Service
public class VirusScanService {

    // Allowed content types for sign registration (video and image)
    private static final List<String> ALLOWED_CONTENT_TYPES = List.of(
        "video/mp4", "video/webm", "video/quicktime", "video/x-msvideo",
        "image/jpeg", "image/png", "image/gif", "image/webp"
    );
    
    // Allowed file extensions (as fallback when content type is not available)
    private static final List<String> ALLOWED_EXTENSIONS = List.of(
        ".mp4", ".webm", ".mov", ".avi",
        ".jpg", ".jpeg", ".png", ".gif", ".webp"
    );
    
    private static final long MAX_FILE_SIZE = 100 * 1024 * 1024; // 100MB

    /**
     * Virus scanning service (stub implementation)
     * In production, this would integrate with ClamAV or similar antivirus service
     */
    public boolean scanFile(MultipartFile file) {
        try {
            // Stub: In production, this would:
            // 1. Send file to ClamAV daemon
            // 2. Check for viruses/malware
            // 3. Return true if clean, false if infected
            
            // Basic validation
            if (file == null || file.isEmpty()) {
                return false;
            }
            
            // Check file size
            if (file.getSize() > MAX_FILE_SIZE) {
                return false;
            }
            
            // Check content type first (more reliable)
            String contentType = file.getContentType();
            if (contentType != null && ALLOWED_CONTENT_TYPES.contains(contentType)) {
                // TODO: Integrate with ClamAV
                // Example integration:
                // ClamAVClient client = new ClamAVClient("localhost", 3310);
                // byte[] reply = client.scan(file.getInputStream());
                // return ClamAVClient.isCleanReply(reply);
                return true;
            }
            
            // Fallback: Check file extension if content type is not available
            String fileName = file.getOriginalFilename();
            if (fileName != null) {
                String lowerName = fileName.toLowerCase();
                for (String ext : ALLOWED_EXTENSIONS) {
                    if (lowerName.endsWith(ext)) {
                        return true;
                    }
                }
            }
            
            // If neither content type nor extension matches, reject
            return false;
        } catch (Exception e) {
            // Log error but don't expose details
            System.err.println("Error in virus scan: " + e.getMessage());
            return false;
        }
    }
}

