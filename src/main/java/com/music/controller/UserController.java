package com.music.controller;

import com.music.entity.PlayRecord;
import com.music.entity.Role;
import com.music.entity.User;
import com.music.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/user")
public class UserController {
    @Autowired
    private UserRepository userRepository;

    @Autowired
    private RoleRepository roleRepository;

    @Autowired
    private PlayRecordRepository playRecordRepository;

    @Autowired
    private PostRepository postRepository;

    @Autowired
    private PlaylistRepository playlistRepository;

    @Autowired
    private MusicLikeRepository musicLikeRepository;

    @Autowired
    private org.springframework.security.crypto.password.PasswordEncoder passwordEncoder;

    // 获取当前登录用户信息
    @GetMapping("/me")
    public ResponseEntity<User> getCurrentUser(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(user);
    }

    // 升级为音乐人角色
    @PostMapping("/upgrade-to-musician")
    public ResponseEntity<?> upgradeToMusician(@AuthenticationPrincipal User user) {
        try {
            // 检查用户是否已经是音乐人
            if (user.getIsMusician() != null && user.getIsMusician() == 1) {
                return ResponseEntity.badRequest().body("You are already a musician");
            }

            // 获取音乐人角色
            Role musicianRole = roleRepository.findByName("ROLE_MUSICIAN")
                    .orElseThrow(() -> new RuntimeException("ROLE_MUSICIAN not found"));

            // 更新用户信息
            user.setIsMusician(1);
            // 移除普通用户角色，添加音乐人角色
            user.setRoles(Collections.singletonList(musicianRole));
            userRepository.save(user);

            return ResponseEntity.ok("Successfully upgraded to musician");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Upgrade failed: " + e.getMessage());
        }
    }

    // 更新用户信息
    @PutMapping("/update")
    public ResponseEntity<?> updateUser(@RequestBody User updatedUser, @AuthenticationPrincipal User currentUser) {
        try {
            // 只允许更新自己的信息
            User user = userRepository.findById(currentUser.getId())
                    .orElseThrow(() -> new RuntimeException("User not found"));

            // 更新基本信息
            user.setNickname(updatedUser.getNickname());
            user.setEmail(updatedUser.getEmail());
            user.setPhone(updatedUser.getPhone());
            user.setGender(updatedUser.getGender());
            user.setBirthday(updatedUser.getBirthday());
            user.setIntroduction(updatedUser.getIntroduction());
            user.setLocation(updatedUser.getLocation());

            userRepository.save(user);
            return ResponseEntity.ok(user);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Update failed: " + e.getMessage());
        }
    }

    // 获取用户角色信息
    @GetMapping("/roles")
    public ResponseEntity<List<Role>> getUserRoles(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(user.getRoles());
    }

    // 获取用户个人资料（包含统计信息）
    @GetMapping("/profile")
    public ResponseEntity<Map<String, Object>> getUserProfile(@AuthenticationPrincipal User user) {
        Map<String, Object> profile = new HashMap<>();
        profile.put("id", user.getId());
        profile.put("username", user.getUsername());
        profile.put("nickname", user.getNickname());
        profile.put("email", user.getEmail());
        profile.put("avatar", user.getAvatar());
        profile.put("createdAt", user.getRegisterTime());
        
        // 统计信息
        profile.put("favoriteCount", musicLikeRepository.countByUserId(user.getId()));
        profile.put("postCount", postRepository.findByUserId(user.getId()).size());
        profile.put("playlistCount", playlistRepository.findByUserId(user.getId()).size());
        
        // 添加角色信息
        List<String> roles = user.getRoles().stream()
                .map(Role::getName)
                .collect(Collectors.toList());
        profile.put("roles", roles);
        
        return ResponseEntity.ok(profile);
    }

    @GetMapping("/profile/{userId}")
    public ResponseEntity<Map<String, Object>> getUserProfileById(@PathVariable Long userId) {
        User target = userRepository.findById(userId).orElseThrow(() -> new RuntimeException("User not found"));
        Map<String, Object> profile = new HashMap<>();
        profile.put("id", target.getId());
        profile.put("username", target.getUsername());
        profile.put("nickname", target.getNickname());
        profile.put("email", target.getEmail());
        profile.put("avatar", target.getAvatar());
        profile.put("createdAt", target.getRegisterTime());
        profile.put("favoriteCount", musicLikeRepository.countByUserId(target.getId()));
        profile.put("postCount", postRepository.findByUserId(target.getId()).size());
        profile.put("playlistCount", playlistRepository.findByUserId(target.getId()).size());
        List<String> roles = target.getRoles() == null ? java.util.List.of() : target.getRoles().stream().map(Role::getName).collect(Collectors.toList());
        profile.put("roles", roles);
        return ResponseEntity.ok(profile);
    }
    // 更新用户个人资料
    @PutMapping("/profile")
    public ResponseEntity<?> updateUserProfile(@RequestBody Map<String, Object> updatedProfile, @AuthenticationPrincipal User currentUser) {
        try {
            User user = userRepository.findById(currentUser.getId())
                    .orElseThrow(() -> new RuntimeException("User not found"));

            // 更新基本信息
            if (updatedProfile.containsKey("username")) {
                user.setUsername((String) updatedProfile.get("username"));
            }
            if (updatedProfile.containsKey("email")) {
                user.setEmail((String) updatedProfile.get("email"));
            }
            if (updatedProfile.containsKey("avatar")) {
                user.setAvatar((String) updatedProfile.get("avatar"));
            }
            if (updatedProfile.containsKey("nickname")) {
                user.setNickname((String) updatedProfile.get("nickname"));
            }

            // 更新密码
            if (updatedProfile.containsKey("newPassword")) {
                String newPassword = (String) updatedProfile.get("newPassword");
                System.out.println("[DEBUG] 收到新密码: " + newPassword);
                System.out.println("[DEBUG] 加密前的旧密码: " + user.getPassword());
                
                // 更新新密码（需要加密）
                String encodedPassword = passwordEncoder.encode(newPassword);
                System.out.println("[DEBUG] 加密后的新密码: " + encodedPassword);
                user.setPassword(encodedPassword);
            }

            User savedUser = userRepository.save(user);
            System.out.println("[DEBUG] 保存到数据库后的密码: " + savedUser.getPassword());
            return ResponseEntity.ok("Profile updated successfully");
        } catch (Exception e) {
            System.err.println("[ERROR] 更新用户资料失败: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Update failed: " + e.getMessage());
        }
    }

    // 获取用户最近播放记录
    @GetMapping("/recent-plays")
    public ResponseEntity<List<PlayRecord>> getRecentPlays(@AuthenticationPrincipal User user) {
        List<PlayRecord> recentPlays = playRecordRepository.findByUserIdOrderByPlayTimeDesc(user.getId());
        return ResponseEntity.ok(recentPlays);
    }

    @PostMapping("/change-password")
    public ResponseEntity<?> changePassword(@RequestBody Map<String, String> passwordMap, @AuthenticationPrincipal User currentUser) {
        try {
            String oldPassword = passwordMap.get("oldPassword");
            String newPassword = passwordMap.get("newPassword");

            if (oldPassword == null || newPassword == null) {
                return ResponseEntity.badRequest().body("Old password and new password are required");
            }

            User user = userRepository.findById(currentUser.getId())
                    .orElseThrow(() -> new RuntimeException("User not found"));

            if (!passwordEncoder.matches(oldPassword, user.getPassword())) {
                return ResponseEntity.badRequest().body("Invalid old password");
            }

            user.setPassword(passwordEncoder.encode(newPassword));
            userRepository.save(user);

            return ResponseEntity.ok("Password changed successfully");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Change password failed: " + e.getMessage());
        }
    }
}
