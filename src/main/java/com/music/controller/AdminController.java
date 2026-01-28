package com.music.controller;

import com.music.entity.Music;
import com.music.entity.Post;
import com.music.entity.Playlist;
import com.music.entity.PlayRecord;
import com.music.entity.Role;
import com.music.entity.User;
import com.music.repository.MusicRepository;
import com.music.repository.CommentRepository;
import com.music.repository.PostRepository;
import com.music.repository.RoleRepository;
import com.music.repository.UserRepository;
import com.music.repository.PlaylistRepository;
import com.music.repository.PlayRecordRepository;
import com.music.repository.MusicLikeRepository;
import com.music.repository.UserFollowRepository;
import com.music.util.FileUploadUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.transaction.annotation.Transactional;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/admin")
public class AdminController {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private MusicRepository musicRepository;

    @Autowired
    private PostRepository postRepository;

    @Autowired
    private FileUploadUtil fileUploadUtil;
    
    @Autowired
    private RoleRepository roleRepository;

    @Autowired
    private com.music.service.MusicService musicService;

    @Autowired
    private com.music.service.PostService postService;
    
    @Autowired
    private org.springframework.security.crypto.password.PasswordEncoder passwordEncoder;
    
    @Autowired
    private CommentRepository commentRepository;
    
    @Autowired
    private PlaylistRepository playlistRepository;
    
    @Autowired
    private PlayRecordRepository playRecordRepository;
    
    @Autowired
    private MusicLikeRepository musicLikeRepository;
    
    @Autowired
    private UserFollowRepository userFollowRepository;

    // 获取平台概览统计数据
    @GetMapping("/dashboard")
    public ResponseEntity<Map<String, Object>> getDashboardStats() {
        Map<String, Object> stats = new HashMap<>();
        
        long totalUsers = userRepository.count();
        long totalMusic = musicRepository.count();
        long totalPosts = postRepository.count();
        
        long totalMusicians = userRepository.countMusicians();
        
        Long totalPlays = musicRepository.sumPlayCount();
        
        long totalComments = commentRepository.count();
        
        long pendingMusicCount = musicRepository.findByStatus(0).size();
        long pendingPostsCount = postRepository.findPendingPostsWithUser().size();
        long pendingContent = pendingMusicCount + pendingPostsCount;

        stats.put("totalUsers", totalUsers);
        stats.put("totalMusic", totalMusic);
        stats.put("totalPosts", totalPosts);
        stats.put("usersChange", 0);
        stats.put("musicChange", 0);
        stats.put("postsChange", 0);
        stats.put("totalMusicians", totalMusicians);
        stats.put("musiciansChange", 0);
        stats.put("totalPlays", totalPlays != null ? totalPlays : 0);
        stats.put("playsChange", 0);
        stats.put("totalComments", totalComments);
        stats.put("commentsChange", 0);
        stats.put("pendingContent", pendingContent);

        return ResponseEntity.ok(stats);
    }
    
    // 为了兼容前端调用，添加stats端点
    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getStats() {
        return getDashboardStats();
    }

    // 批量导入本地音乐文件夹中的mp3到系统
    @PostMapping("/import-local-music")
    public ResponseEntity<Map<String, Object>> importLocalMusic() throws IOException {
        Map<String, Object> result = new HashMap<>();
        // 项目根目录下的“音乐”文件夹
        File sourceDir = new File("f:/JavaBiShe/Design and Implementation of  Socialized Music Platform/音乐");
        if (!sourceDir.exists() || !sourceDir.isDirectory()) {
            result.put("success", false);
            result.put("message", "未找到本地音乐目录");
            return ResponseEntity.ok(result);
        }

        User admin = userRepository.findByUsername("admin").orElse(null);
        Long musicianId = admin != null ? admin.getId() : 1L;

        int imported = 0;
        for (File src : sourceDir.listFiles()) {
            if (src.isFile() && src.getName().toLowerCase().endsWith(".mp3")) {
                String originalName = src.getName();
                String baseName = originalName.substring(0, originalName.lastIndexOf('.'));
                String title = baseName;
                String artist = "未知";
                if (baseName.contains("-")) {
                    String[] parts = baseName.split("-");
                    if (parts.length >= 2) {
                        title = parts[0].trim();
                        artist = parts[1].trim();
                    }
                }

                String filename = UUID.randomUUID().toString() + ".mp3";
                File dest = new File(fileUploadUtil.getMusicFilePath(filename));
                dest.getParentFile().mkdirs();
                Files.copy(src.toPath(), dest.toPath(), StandardCopyOption.REPLACE_EXISTING);

                Music music = new Music();
                music.setTitle(title);
                music.setArtist(artist);
                music.setAlbum(null);
                music.setGenre(null);
                music.setDuration(240);
                music.setFilePath(filename);
                music.setCoverPath(null);
                music.setLyricPath(null);
                music.setDescription("本地导入");
                music.setPlayCount(0);
                music.setDownloadCount(0);
                music.setCommentCount(0);
                music.setLikeCount(0);
                music.setShareCount(0);
                music.setMusicianId(musicianId);
                music.setIsOriginal(0);
                music.setCopyrightInfo(null);
                music.setStatus(1); // 直接设为已通过，便于前端展示
                musicRepository.save(music);
                imported++;
            }
        }

        result.put("success", true);
        result.put("imported", imported);
        result.put("message", "导入完成");
        return ResponseEntity.ok(result);
    }

    // 获取用户列表
    @GetMapping("/users")
    public ResponseEntity<List<User>> getUsers() {
        List<User> users = userRepository.findAll();
        users.forEach(u -> {
            u.setPassword(null);
        });
        return ResponseEntity.ok(users);
    }

    // 搜索用户
    @GetMapping("/users/search")
    public ResponseEntity<List<User>> searchUsers(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String role) {
        List<User> users;
        
        if (keyword != null && !keyword.trim().isEmpty()) {
            if (role != null && !role.trim().isEmpty()) {
                String roleName = "ROLE_" + role.toUpperCase();
                users = userRepository.searchUsersByRole(keyword.trim(), roleName);
            } else {
                users = userRepository.searchUsers(keyword.trim());
            }
        } else if (role != null && !role.trim().isEmpty()) {
            String roleName = "ROLE_" + role.toUpperCase();
            users = userRepository.findAll().stream()
                    .filter(u -> u.getRoles() != null && 
                            u.getRoles().stream().anyMatch(r -> r.getName().equals(roleName)))
                    .collect(java.util.stream.Collectors.toList());
        } else {
            users = userRepository.findAll();
        }
        
        return ResponseEntity.ok(users);
    }

    // 编辑用户信息
    @PutMapping("/users/{id}")
    public ResponseEntity<User> updateUser(@PathVariable Long id, @RequestBody User user) {
        User existingUser = userRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
        
        existingUser.setUsername(user.getUsername());
        existingUser.setEmail(user.getEmail());
        existingUser.setNickname(user.getNickname());
        existingUser.setAvatar(user.getAvatar());
        existingUser.setStatus(user.getStatus());
        
        User updatedUser = userRepository.save(existingUser);
        return ResponseEntity.ok(updatedUser);
    }

    // 禁用/启用用户
    @PutMapping("/users/{id}/status")
    public ResponseEntity<User> toggleUserStatus(@PathVariable Long id, @RequestBody Map<String, String> status) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
        
        // 将字符串状态转换为整数状态
        String statusStr = status.get("status");
        int statusInt = statusStr.equals("ACTIVE") ? 1 : 0;
        user.setStatus(statusInt);
        User updatedUser = userRepository.save(user);
        return ResponseEntity.ok(updatedUser);
    }

    // 获取待审核音乐列表
    @GetMapping("/music/pending")
    public ResponseEntity<List<Music>> getPendingMusic() {
        List<Music> pendingMusic = musicRepository.findByStatus(0);
        return ResponseEntity.ok(pendingMusic);
    }
    
    // 为了兼容前端调用，添加content/pending/music端点
    @GetMapping("/content/pending/music")
    public ResponseEntity<List<Music>> getContentPendingMusic() {
        return getPendingMusic();
    }

    @PutMapping("/music/{id}/approve")
    public ResponseEntity<Music> approveMusic(@PathVariable Long id) {
        Music music = musicService.approveMusic(id);
        return ResponseEntity.ok(music);
    }

    // 为了兼容前端调用路径，提供别名
    @PutMapping("/content/music/{id}/approve")
    public ResponseEntity<Music> approveContentMusic(@PathVariable Long id) {
        return approveMusic(id);
    }

    @PutMapping("/music/{id}/reject")
    public ResponseEntity<Music> rejectMusic(@PathVariable Long id) {
        Music music = musicService.rejectMusic(id);
        return ResponseEntity.ok(music);
    }
    
    // 为了兼容前端调用
    @PutMapping("/content/music/{id}/reject")
    public ResponseEntity<Music> rejectContentMusic(@PathVariable Long id) {
        return rejectMusic(id);
    }

    @GetMapping("/content/pending/posts")
    public ResponseEntity<List<Post>> getPendingPosts() {
        return ResponseEntity.ok(postService.getPendingPosts());
    }
    
    @GetMapping("/posts/pending")
    public ResponseEntity<List<Post>> getPendingPostsAlias() {
        return getPendingPosts();
    }
    
    // 审核通过动态
    @PutMapping("/posts/{id}/approve")
    public ResponseEntity<Void> approvePost(@PathVariable Long id) {
        postService.approvePost(id);
        return ResponseEntity.ok().build();
    }

    // 拒绝动态
    @PutMapping("/posts/{id}/reject")
    public ResponseEntity<Void> rejectPost(@PathVariable Long id) {
        postService.rejectPost(id);
        return ResponseEntity.ok().build();
    }
    
    // 创建用户
    @PostMapping("/users")
    public ResponseEntity<User> createUser(@RequestBody User user) {
        // 加密密码与默认值
        String encodedPassword = passwordEncoder.encode(user.getPassword());
        user.setPassword(encodedPassword);
        if (user.getStatus() == null) {
            user.setStatus(1);
        }
        if (user.getRoles() == null || user.getRoles().isEmpty()) {
            Role userRole = roleRepository.findByName("ROLE_USER")
                    .orElseThrow(() -> new IllegalArgumentException("ROLE_USER not found"));
            user.setRoles(java.util.Collections.singletonList(userRole));
        }
        User newUser = userRepository.save(user);
        return ResponseEntity.ok(newUser);
    }
    
    // 删除用户
    @DeleteMapping("/users/{id}")
    @Transactional
    public ResponseEntity<Void> deleteUser(@PathVariable Long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
        
        List<Music> userMusics = musicRepository.findByMusicianId(user.getId());
        for (Music music : userMusics) {
            musicService.deleteMusic(music.getId());
        }
        
        List<Playlist> playlists = playlistRepository.findByUserId(id);
        if (!playlists.isEmpty()) {
            playlistRepository.deleteAll(playlists);
        }
        
        List<PlayRecord> playRecords = playRecordRepository.findByUserId(id);
        if (!playRecords.isEmpty()) {
            playRecordRepository.deleteAll(playRecords);
        }
        
        musicLikeRepository.deleteByUserId(id);
        
        userFollowRepository.deleteByFollowerId(id);
        userFollowRepository.deleteByFollowingId(id);
        
        user.setRoles(java.util.Collections.emptyList());
        userRepository.save(user);
        
        userRepository.delete(user);
        return ResponseEntity.noContent().build();
    }
    
    // 获取所有角色
    @GetMapping("/roles")
    public ResponseEntity<List<Role>> getAllRoles() {
        List<Role> roles = roleRepository.findAll();
        return ResponseEntity.ok(roles);
    }
    
    // 获取用户角色
    @GetMapping("/users/{id}/roles")
    public ResponseEntity<List<Role>> getUserRoles(@PathVariable Long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
        return ResponseEntity.ok(user.getRoles());
    }
    
    // 更新用户角色
    @PutMapping("/users/{id}/roles")
    public ResponseEntity<User> updateUserRoles(@PathVariable Long id, @RequestBody Map<String, List<String>> roleData) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
        
        List<String> roleNames = roleData.get("roles");
        List<Role> roles = roleRepository.findAll().stream()
                .filter(role -> roleNames.contains(role.getName()))
                .collect(java.util.stream.Collectors.toList());
        
        // 确保角色数量与请求的角色数量一致
        if (roles.size() != roleNames.size()) {
            throw new IllegalArgumentException("One or more roles not found");
        }
        
        user.setRoles(roles);
        
        // 更新isMusician字段
        boolean isMusician = roles.stream().anyMatch(r -> r.getName().equals("ROLE_MUSICIAN"));
        user.setIsMusician(isMusician ? 1 : 0);
        
        User updatedUser = userRepository.save(user);
        return ResponseEntity.ok(updatedUser);
    }
    
    // 获取待审核评论列表
    @GetMapping("/content/pending/comments")
    public ResponseEntity<List<Map<String, Object>>> getPendingComments() {
        // 模拟评论数据
        List<Map<String, Object>> comments = new java.util.ArrayList<>();
        return ResponseEntity.ok(comments);
    }
    
    // 审核通过评论
    @PutMapping("/content/comments/{id}/approve")
    public ResponseEntity<Void> approveComment(@PathVariable Long id) {
        // 评论审核逻辑（模拟）
        return ResponseEntity.noContent().build();
    }
    
    // 删除评论
    @DeleteMapping("/content/comments/{id}")
    public ResponseEntity<Void> deleteComment(@PathVariable Long id) {
        // 删除评论逻辑（模拟）
        return ResponseEntity.noContent().build();
    }

    // 获取用户增长统计
    @GetMapping("/stats/users")
    public ResponseEntity<List<Map<String, Object>>> getUserGrowthStats() {
        List<Map<String, Object>> stats = new java.util.ArrayList<>();
        
        // 获取过去7天的用户增长数据
        for (int i = 6; i >= 0; i--) {
            Map<String, Object> dayStats = new HashMap<>();
            java.time.LocalDate date = java.time.LocalDate.now().minusDays(i);
            dayStats.put("date", date.toString());
            
            // 查询当天注册的用户数量（按角色分别统计）
            Long totalCount = userRepository.countByRegisterTime(date.toString());
            Long userCount = userRepository.countByRegisterTimeAndRole(date.toString(), "ROLE_USER");
            Long adminCount = userRepository.countByRegisterTimeAndRole(date.toString(), "ROLE_ADMIN");
            Long musicianCount = userRepository.countByRegisterTimeAndRole(date.toString(), "ROLE_MUSICIAN");
            
            dayStats.put("total", totalCount != null ? totalCount : 0);
            dayStats.put("user", userCount != null ? userCount : 0);
            dayStats.put("admin", adminCount != null ? adminCount : 0);
            dayStats.put("musician", musicianCount != null ? musicianCount : 0);
            
            stats.add(dayStats);
        }
        
        return ResponseEntity.ok(stats);
    }

    // 获取内容统计
    @GetMapping("/stats/content")
    public ResponseEntity<Map<String, Object>> getContentStats() {
        Map<String, Object> stats = new HashMap<>();
        
        // 获取音乐分类统计数据
        Map<String, Long> musicCategoryStats = new HashMap<>();
        List<Object[]> genreCounts = musicRepository.countByGenre();
        for (Object[] row : genreCounts) {
            String genre = (String) row[0];
            Long count = (Long) row[1];
            musicCategoryStats.put(genre, count);
        }
        
        // 获取动态分类统计数据
        Map<String, Long> postCategoryStats = new HashMap<>();
        long totalPosts = postRepository.count();
        
        // 将动态平均分配到"心情动态"和"话题讨论"
        postCategoryStats.put("心情动态", totalPosts / 2);
        postCategoryStats.put("话题讨论", totalPosts - (totalPosts / 2));
        
        stats.put("musicCategory", musicCategoryStats);
        stats.put("postCategory", postCategoryStats);
        
        return ResponseEntity.ok(stats);
    }
}
