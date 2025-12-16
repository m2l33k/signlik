package org.example.backendsignlik.controller;

import org.example.backendsignlik.dto.FileUploadResponse;
import org.example.backendsignlik.service.StorageService;
import org.example.backendsignlik.service.VirusScanService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.InputStream;

@RestController
@RequestMapping("/api/files")
public class FileController {

    @Autowired
    private StorageService storageService;
    
    @Autowired
    private VirusScanService virusScanService;

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
}

