package com.music.controller;

import com.music.dto.LoginRequest;
import com.music.dto.LoginResponse;
import com.music.entity.Role;
import com.music.entity.User;
import com.music.repository.RoleRepository;
import com.music.repository.UserRepository;
import com.music.util.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jakarta.validation.Valid;
import java.util.Collections;
import java.util.stream.Collectors;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@RestController
@RequestMapping("/auth")
public class AuthController {
    private static final Logger logger = LoggerFactory.getLogger(AuthController.class);
    
    @Autowired
    private AuthenticationManager authenticationManager;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private RoleRepository roleRepository;

    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody LoginRequest loginRequest) {
        logger.info("[AUTH CONTROLLER] Login request received: {}", loginRequest.getUsername());
        try {
            logger.debug("[AUTH CONTROLLER] Step 1: Authenticating user");
            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(loginRequest.getUsername(), loginRequest.getPassword())
            );

            logger.debug("[AUTH CONTROLLER] Step 2: Setting security context");
            SecurityContextHolder.getContext().setAuthentication(authentication);
            UserDetails userDetails = (UserDetails) authentication.getPrincipal();
            logger.debug("[AUTH CONTROLLER] Authenticated user: {}", userDetails.getUsername());

            logger.debug("[AUTH CONTROLLER] Step 3: Finding user in database");
            User user = userRepository.findByUsername(userDetails.getUsername())
                    .orElseThrow(() -> new RuntimeException("User not found: " + userDetails.getUsername()));
            logger.debug("[AUTH CONTROLLER] Found user: {}", user.getId());

            logger.debug("[AUTH CONTROLLER] Step 4: Processing user roles");
            // 确保角色列表不为空
            String[] roles = new String[0];
            if (user.getRoles() != null && !user.getRoles().isEmpty()) {
                roles = user.getRoles().stream()
                        .map(role -> {
                            logger.debug("[AUTH CONTROLLER] Role name: {}", role.getName());
                            return role.getName();
                        })
                        .toArray(String[]::new);
            } else {
                logger.debug("[AUTH CONTROLLER] User roles is null or empty");
            }

            logger.debug("[AUTH CONTROLLER] Step 5: Generating JWT token");
            // 使用包含角色信息的令牌生成方法
            String token = jwtUtil.generateToken(userDetails.getUsername(), roles);
            logger.debug("[AUTH CONTROLLER] Generated token: {}", token != null ? "***" : "null");

            logger.debug("[AUTH CONTROLLER] Step 6: Creating login response");
            LoginResponse response = new LoginResponse(
                    token, user.getId(), user.getUsername(), user.getNickname(), user.getAvatar(), roles
            );

            logger.debug("[AUTH CONTROLLER] Step 7: Returning successful response");
            return ResponseEntity.ok(response);
        } catch (org.springframework.security.authentication.DisabledException e) {
            logger.error("[AUTH CONTROLLER] User disabled: {}", e.getMessage());
            return ResponseEntity.status(403).body("Login failed: User is disabled");
        } catch (org.springframework.security.authentication.LockedException e) {
            logger.error("[AUTH CONTROLLER] User locked: {}", e.getMessage());
            return ResponseEntity.status(403).body("Login failed: User is locked");
        } catch (org.springframework.security.authentication.BadCredentialsException e) {
            logger.error("[AUTH CONTROLLER] Invalid username or password: {}", e.getMessage());
            return ResponseEntity.status(401).body("Login failed: Invalid username or password");
        } catch (Exception e) {
            logger.error("[AUTH CONTROLLER] Login error: {}", e.getMessage(), e);
            return ResponseEntity.status(500).body("Login failed: " + e.getMessage());
        }
    }

    @PostMapping("/register")
    public ResponseEntity<?> register(@Valid @RequestBody User user) {
        logger.info("[AUTH CONTROLLER] Register request received for username: {}", user.getUsername());
        try {
            if (userRepository.existsByUsername(user.getUsername())) {
                logger.debug("[AUTH CONTROLLER] Username already exists: {}", user.getUsername());
                return ResponseEntity.badRequest().body("Error: Username is already taken!");
            }

            if (user.getEmail() != null && !user.getEmail().isEmpty() && userRepository.existsByEmail(user.getEmail())) {
                logger.debug("[AUTH CONTROLLER] Email already exists: {}", user.getEmail());
                return ResponseEntity.badRequest().body("Error: Email is already in use!");
            }

            // 设置默认值
            logger.debug("[AUTH CONTROLLER] Step 1: Setting default values");
            user.setPassword(passwordEncoder.encode(user.getPassword()));
            user.setStatus(1);
            user.setIsMusician(0);
            if (user.getNickname() == null || user.getNickname().isEmpty()) {
                user.setNickname(user.getUsername());
            }

            // 分配默认角色ROLE_USER（若不存在则自动创建）
            logger.debug("[AUTH CONTROLLER] Step 2: Assigning default role ROLE_USER");
            Role userRole = roleRepository.findByName("ROLE_USER")
                    .orElseGet(() -> {
                        Role role = new Role();
                        role.setName("ROLE_USER");
                        role.setDescription("普通用户角色");
                        return roleRepository.save(role);
                    });
            user.setRoles(Collections.singletonList(userRole));
            logger.debug("[AUTH CONTROLLER] Assigned role: {}", userRole.getName());

            logger.debug("[AUTH CONTROLLER] Step 3: Saving user to database");
            userRepository.save(user);
            logger.info("[AUTH CONTROLLER] User registered successfully: {}", user.getUsername());
            return ResponseEntity.ok("User registered successfully!");
        } catch (Exception e) {
            logger.error("[AUTH CONTROLLER] Registration error: {}", e.getMessage(), e);
            return ResponseEntity.status(500).body("Registration failed: " + e.getMessage());
        }
    }
}
