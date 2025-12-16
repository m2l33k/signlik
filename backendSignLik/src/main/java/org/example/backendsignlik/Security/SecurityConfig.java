package org.example.backendsignlik.Security;


import org.example.backendsignlik.config.CorsConfig;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfigurationSource;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Autowired
    private JwtAuthenticationFilter jwtAuthenticationFilter;
    
    @Autowired
    private CorsConfig corsConfig;

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
                .cors(cors -> cors.configurationSource(corsConfig.corsConfigurationSource()))
                .csrf(csrf -> csrf.disable())
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/api/auth/**").permitAll()
                        .requestMatchers("/api/users/search").permitAll() // Allow search without auth
                        .requestMatchers("/api/users/all").permitAll() // Allow listing users without auth
                        .requestMatchers("/api/tsl/status", "/api/tsl/classes").permitAll() // Allow TSL status/classes check
                        .requestMatchers("/api/tsl/**").authenticated() // Protect TSL prediction endpoints
                        .requestMatchers("/api/files/**").authenticated() // Protect file endpoints
                        .requestMatchers("/api/users/**").authenticated() // Protect user profile endpoints
                        .requestMatchers("/api/messages/**").authenticated() // Protect all message endpoints
                        .requestMatchers("/api/notifications/**").authenticated() // Protect notification endpoints
                        .requestMatchers("/api/friends/**").authenticated() // Protect friendship endpoints
                        .requestMatchers("/api/reactions/**").authenticated() // Protect reaction endpoints
                        .requestMatchers("/api/groups/**").authenticated() // Protect group endpoints
                        .requestMatchers("/api/preferences/**").authenticated() // Protect preferences endpoints
                        .requestMatchers("/api/blocked/**").authenticated() // Protect blocked users endpoints
                        .requestMatchers("/api/activity/**").authenticated() // Protect activity log endpoints
                        .requestMatchers("/swagger-ui/**", "/v3/api-docs/**").permitAll() // Allow Swagger
                        .anyRequest().authenticated()
                );

        return http.build();
    }
}
