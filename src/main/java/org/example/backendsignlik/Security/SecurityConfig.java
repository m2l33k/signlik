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
                        .requestMatchers("/ws/**").permitAll() // Allow WebSocket connections
                        .requestMatchers("/api/auth/**").permitAll()
                        .requestMatchers("/api/users/search").permitAll() // Allow search without auth
                        .requestMatchers("/api/users/all").permitAll() // Allow listing users without auth
                        .requestMatchers("/api/signs").permitAll() // Allow viewing all signs
                        .requestMatchers("/api/signs/search").permitAll() // Allow searching signs
                        .requestMatchers("/api/signs/category/**").permitAll() // Allow viewing by category
                        .requestMatchers("/api/signs/popular").permitAll() // Allow viewing popular signs
                        .requestMatchers("/api/signs/recent").permitAll() // Allow viewing recent signs
                        .requestMatchers("/api/signs/specialist/**").permitAll() // Allow viewing signs by specialist
                        // Protected endpoints - must come before the general permitAll pattern
                        .requestMatchers("/api/signs/add").authenticated() // Protect sign creation
                        .requestMatchers("/api/signs/*/approve").authenticated() // Protect sign approval (more specific pattern)
                        .requestMatchers("/api/signs/*/delete").authenticated() // Protect sign deletion if exists
                        .requestMatchers("/api/signs/{id}").permitAll() // Allow viewing sign by ID (GET only, PUT/DELETE handled above)
                        .requestMatchers("/api/signs/**").permitAll() // Allow other sign endpoints
                        .requestMatchers("/api/files/local/**").permitAll() // Allow public access to local files
                        .requestMatchers("/api/files/**").authenticated() // Protect other file endpoints
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
                )
                .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}
