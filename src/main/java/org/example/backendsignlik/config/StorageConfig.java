package org.example.backendsignlik.config;

import io.minio.MinioClient;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;


@Configuration
public class StorageConfig {

    @Value("${storage.minio.endpoint}")
    private String endpoint;

    @Value("${storage.minio.access-key}")
    private String accessKey;

    @Value("${storage.minio.secret-key}")
    private String secretKey;

    /**
     * Only create MinioClient bean when storage.type is not "local"
     * This allows the app to start without MinIO when using local storage
     */
    @Bean
    @ConditionalOnProperty(name = "storage.type", havingValue = "minio", matchIfMissing = true)
    public MinioClient minioClient() {
        return MinioClient.builder()
                .endpoint(endpoint)
                .credentials(accessKey, secretKey)
                .build();
    }
}

