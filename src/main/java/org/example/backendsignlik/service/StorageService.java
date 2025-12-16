package org.example.backendsignlik.service;

import io.minio.*;
import io.minio.http.Method;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

@Service
public class StorageService {

    @Value("${storage.type:minio}")
    private String storageType;

    @Value("${storage.local.base-path:./uploads}")
    private String localBasePath;

    @Value("${storage.local.base-url:http://localhost:8081/api/files/local}")
    private String localBaseUrl;

    @Autowired(required = false)
    private io.minio.MinioClient minioClient;

    @Value("${storage.minio.bucket-name:signlik-media}")
    private String bucketName;

    @Value("${storage.url-expiration-seconds:3600}")
    private int urlExpirationSeconds;

    /**
     * Initialize storage (bucket for MinIO, directories for local)
     */
    public void initializeBucket() throws Exception {
        if ("local".equalsIgnoreCase(storageType)) {
            // Create local storage directory if it doesn't exist
            Path basePath = Paths.get(localBasePath);
            if (!Files.exists(basePath)) {
                Files.createDirectories(basePath);
            }
        } else {
            // MinIO initialization
            if (minioClient == null) {
                throw new Exception("MinIO client is not configured. Set storage.type=local to use local storage instead.");
            }
            try {
                boolean found = minioClient.bucketExists(BucketExistsArgs.builder()
                        .bucket(bucketName)
                        .build());
                
                if (!found) {
                    minioClient.makeBucket(MakeBucketArgs.builder()
                            .bucket(bucketName)
                            .build());
                }
            } catch (Exception e) {
                throw new Exception("MinIO storage is not available. Please start MinIO server or set storage.type=local. Error: " + e.getMessage(), e);
            }
        }
    }

    /**
     * Upload file to storage (local or MinIO)
     */
    public String uploadFile(MultipartFile file, String folder) throws Exception {
        initializeBucket();
        
        String fileName = UUID.randomUUID().toString() + "_" + file.getOriginalFilename();
        String objectName = folder + "/" + fileName;
        
        if ("local".equalsIgnoreCase(storageType)) {
            // Local file storage
            Path folderPath = Paths.get(localBasePath, folder);
            if (!Files.exists(folderPath)) {
                Files.createDirectories(folderPath);
            }
            
            Path filePath = folderPath.resolve(fileName);
            Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);
            
            return objectName;
        } else {
            // MinIO storage
            if (minioClient == null) {
                throw new Exception("MinIO client is not configured. Set storage.type=local to use local storage instead.");
            }
            try {
                minioClient.putObject(
                        PutObjectArgs.builder()
                                .bucket(bucketName)
                                .object(objectName)
                                .stream(file.getInputStream(), file.getSize(), -1)
                                .contentType(file.getContentType())
                                .build()
                );
                return objectName;
            } catch (Exception e) {
                throw new Exception("Failed to upload file to MinIO. Error: " + e.getMessage() + ". Consider setting storage.type=local for testing.", e);
            }
        }
    }

    /**
     * Get signed URL for file access
     */
    public String getSignedUrl(String objectName) throws Exception {
        if ("local".equalsIgnoreCase(storageType)) {
            // For local storage, return direct URL
            return localBaseUrl + "/" + objectName;
        } else {
            // MinIO presigned URL
            if (minioClient == null) {
                throw new Exception("MinIO client is not configured.");
            }
            return minioClient.getPresignedObjectUrl(
                    GetPresignedObjectUrlArgs.builder()
                            .method(Method.GET)
                            .bucket(bucketName)
                            .object(objectName)
                            .expiry(urlExpirationSeconds, TimeUnit.SECONDS)
                            .build()
            );
        }
    }

    /**
     * Download file from storage
     */
    public InputStream downloadFile(String objectName) throws Exception {
        if ("local".equalsIgnoreCase(storageType)) {
            // Local file storage
            Path filePath = Paths.get(localBasePath, objectName);
            if (!Files.exists(filePath)) {
                throw new FileNotFoundException("File not found: " + objectName);
            }
            return new FileInputStream(filePath.toFile());
        } else {
            // MinIO storage
            if (minioClient == null) {
                throw new Exception("MinIO client is not configured.");
            }
            return minioClient.getObject(
                    GetObjectArgs.builder()
                            .bucket(bucketName)
                            .object(objectName)
                            .build()
            );
        }
    }

    /**
     * Delete file from storage
     */
    public void deleteFile(String objectName) throws Exception {
        if ("local".equalsIgnoreCase(storageType)) {
            // Local file storage
            Path filePath = Paths.get(localBasePath, objectName);
            if (Files.exists(filePath)) {
                Files.delete(filePath);
            }
        } else {
            // MinIO storage
            if (minioClient == null) {
                throw new Exception("MinIO client is not configured.");
            }
            minioClient.removeObject(
                    RemoveObjectArgs.builder()
                            .bucket(bucketName)
                            .object(objectName)
                            .build()
            );
        }
    }
}
