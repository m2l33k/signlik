package org.example.backendsignlik.controller;

import org.example.backendsignlik.dto.FileUploadResponse;
import org.example.backendsignlik.service.StorageService;
import org.example.backendsignlik.service.VirusScanService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import jakarta.servlet.http.HttpServletRequest;
import java.io.File;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

@RestController
@RequestMapping("/api/files")
public class FileController {

    @Autowired
    private StorageService storageService;
    
    @Autowired
    private VirusScanService virusScanService;

    @Value("${storage.local.base-path:./uploads}")
    private String localBasePath;

    @PostMapping("/upload")
    public ResponseEntity<?> uploadFile(
            @RequestParam("file") MultipartFile file,
            @RequestParam(value = "folder", defaultValue = "general") String folder) {
        
        try {
            // Virus scan
            if (!virusScanService.scanFile(file)) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body("File failed virus scan or validation");
            }
            
            // Upload to storage
            String objectName = storageService.uploadFile(file, folder);
            String signedUrl = storageService.getSignedUrl(objectName);
            
            FileUploadResponse response = new FileUploadResponse();
            response.setFileId(objectName);
            response.setFileName(file.getOriginalFilename());
            response.setFileUrl(objectName);
            response.setSignedUrl(signedUrl);
            response.setFileSize(file.getSize());
            response.setContentType(file.getContentType());
            response.setMessage("File uploaded successfully");
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error uploading file: " + e.getMessage());
        }
    }

    @GetMapping("/download/{fileId}")
    public ResponseEntity<?> downloadFile(@PathVariable String fileId) {
        try {
            InputStream fileStream = storageService.downloadFile(fileId);
            
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_OCTET_STREAM);
            headers.setContentDispositionFormData("attachment", fileId);
            
            return ResponseEntity.ok()
                    .headers(headers)
                    .body(fileStream);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body("File not found: " + e.getMessage());
        }
    }

    @GetMapping("/url/{fileId}")
    public ResponseEntity<?> getSignedUrl(@PathVariable String fileId) {
        try {
            String signedUrl = storageService.getSignedUrl(fileId);
            FileUploadResponse response = new FileUploadResponse();
            response.setFileId(fileId);
            response.setFileUrl(fileId);
            response.setSignedUrl(signedUrl);
            response.setMessage("Signed URL generated");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body("Error generating signed URL: " + e.getMessage());
        }
    }

    @DeleteMapping("/{fileId}")
    public ResponseEntity<?> deleteFile(@PathVariable String fileId) {
        try {
            storageService.deleteFile(fileId);
            return ResponseEntity.ok("File deleted successfully");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error deleting file: " + e.getMessage());
        }
    }

    /**
     * Serve local files directly (for local storage mode)
     * This endpoint allows direct access to files stored locally
     * Example: /api/files/local/signs/abc123_video.mp4
     */
    @GetMapping("/local/**")
    public ResponseEntity<?> serveLocalFile(HttpServletRequest request) {
        try {
            // Get the path after /api/files/local/
            String requestPath = request.getRequestURI();
            String filePath = requestPath.replaceFirst("^/api/files/local/", "");
            
            if (filePath == null || filePath.isEmpty()) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body("Invalid file path");
            }
            
            Path file = Paths.get(localBasePath, filePath).normalize();
            
            // Security check: ensure the resolved path is within the base directory
            Path basePath = Paths.get(localBasePath).normalize().toAbsolutePath();
            Path resolvedPath = file.toAbsolutePath();
            if (!resolvedPath.startsWith(basePath)) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body("Access denied: path traversal detected");
            }
            
            Resource resource = new FileSystemResource(file.toFile());
            
            if (!resource.exists() || !resource.isReadable()) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body("File not found: " + filePath);
            }
            
            // Determine content type
            String contentType = "application/octet-stream";
            try {
                String detectedType = Files.probeContentType(file);
                if (detectedType != null && !detectedType.isEmpty()) {
                    contentType = detectedType;
                } else {
                    // Try to guess from extension
                    String fileName = file.getFileName().toString().toLowerCase();
                    if (fileName.endsWith(".mp4") || fileName.endsWith(".mov")) {
                        contentType = "video/mp4";
                    } else if (fileName.endsWith(".webm")) {
                        contentType = "video/webm";
                    } else if (fileName.endsWith(".avi")) {
                        contentType = "video/x-msvideo";
                    } else if (fileName.endsWith(".jpg") || fileName.endsWith(".jpeg")) {
                        contentType = "image/jpeg";
                    } else if (fileName.endsWith(".png")) {
                        contentType = "image/png";
                    } else if (fileName.endsWith(".gif")) {
                        contentType = "image/gif";
                    } else if (fileName.endsWith(".webp")) {
                        contentType = "image/webp";
                    }
                    // If still not set, keep default "application/octet-stream"
                }
            } catch (Exception e) {
                // Use default "application/octet-stream"
                System.err.println("Warning: Could not determine content type for file: " + filePath);
            }
            
            // Ensure contentType is never null or empty
            if (contentType == null || contentType.isEmpty()) {
                contentType = "application/octet-stream";
            }
            
            return ResponseEntity.ok()
                    .contentType(MediaType.parseMediaType(contentType))
                    .header(HttpHeaders.CONTENT_DISPOSITION, "inline; filename=\"" + file.getFileName() + "\"")
                    .body(resource);
        } catch (Exception e) {
            // Log the error for debugging
            System.err.println("Error serving local file: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error serving file: " + e.getMessage());
        }
    }
}

