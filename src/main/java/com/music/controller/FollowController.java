package com.music.controller;

import com.music.entity.User;
import com.music.service.UserFollowService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/follow")
public class FollowController {
    @Autowired
    private UserFollowService userFollowService;

    @PostMapping("/{userId}")
    public ResponseEntity<?> followUser(@PathVariable Long userId, @AuthenticationPrincipal User currentUser) {
        userFollowService.followUser(currentUser.getId(), userId);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/{userId}")
    public ResponseEntity<?> unfollowUser(@PathVariable Long userId, @AuthenticationPrincipal User currentUser) {
        userFollowService.unfollowUser(currentUser.getId(), userId);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/{userId}/status")
    public ResponseEntity<Map<String, Boolean>> getFollowStatus(@PathVariable Long userId, @AuthenticationPrincipal User currentUser) {
        boolean isFollowing = userFollowService.isFollowing(currentUser.getId(), userId);
        Map<String, Boolean> result = new HashMap<>();
        result.put("isFollowing", isFollowing);
        return ResponseEntity.ok(result);
    }

    @GetMapping("/following")
    public ResponseEntity<java.util.List<java.util.Map<String, Object>>> getFollowing(@AuthenticationPrincipal User currentUser) {
        java.util.List<User> following = userFollowService.getFollowingUsers(currentUser.getId());
        java.util.List<java.util.Map<String, Object>> result = following.stream().map(u -> {
            java.util.Map<String, Object> m = new java.util.HashMap<>();
            m.put("id", u.getId());
            m.put("username", u.getUsername());
            m.put("nickname", u.getNickname());
            m.put("avatar", u.getAvatar());
            m.put("roles", u.getRoles() == null ? java.util.List.of() : u.getRoles().stream().map(r -> r.getName()).collect(java.util.stream.Collectors.toList()));
            return m;
        }).collect(java.util.stream.Collectors.toList());
        return ResponseEntity.ok(result);
    }

    @GetMapping("/followers")
    public ResponseEntity<java.util.List<java.util.Map<String, Object>>> getFollowers(@AuthenticationPrincipal User currentUser) {
        java.util.List<User> followers = userFollowService.getFollowers(currentUser.getId());
        java.util.List<java.util.Map<String, Object>> result = followers.stream().map(u -> {
            java.util.Map<String, Object> m = new java.util.HashMap<>();
            m.put("id", u.getId());
            m.put("username", u.getUsername());
            m.put("nickname", u.getNickname());
            m.put("avatar", u.getAvatar());
            m.put("roles", u.getRoles() == null ? java.util.List.of() : u.getRoles().stream().map(r -> r.getName()).collect(java.util.stream.Collectors.toList()));
            return m;
        }).collect(java.util.stream.Collectors.toList());
        return ResponseEntity.ok(result);
    }

    @GetMapping("/following/{userId}")
    public ResponseEntity<java.util.List<java.util.Map<String, Object>>> getUserFollowing(@PathVariable Long userId) {
        java.util.List<User> following = userFollowService.getFollowingUsers(userId);
        java.util.List<java.util.Map<String, Object>> result = following.stream().map(u -> {
            java.util.Map<String, Object> m = new java.util.HashMap<>();
            m.put("id", u.getId());
            m.put("username", u.getUsername());
            m.put("nickname", u.getNickname());
            m.put("avatar", u.getAvatar());
            m.put("roles", u.getRoles() == null ? java.util.List.of() : u.getRoles().stream().map(r -> r.getName()).collect(java.util.stream.Collectors.toList()));
            return m;
        }).collect(java.util.stream.Collectors.toList());
        return ResponseEntity.ok(result);
    }

    @GetMapping("/followers/{userId}")
    public ResponseEntity<java.util.List<java.util.Map<String, Object>>> getUserFollowers(@PathVariable Long userId) {
        java.util.List<User> followers = userFollowService.getFollowers(userId);
        java.util.List<java.util.Map<String, Object>> result = followers.stream().map(u -> {
            java.util.Map<String, Object> m = new java.util.HashMap<>();
            m.put("id", u.getId());
            m.put("username", u.getUsername());
            m.put("nickname", u.getNickname());
            m.put("avatar", u.getAvatar());
            m.put("roles", u.getRoles() == null ? java.util.List.of() : u.getRoles().stream().map(r -> r.getName()).collect(java.util.stream.Collectors.toList()));
            return m;
        }).collect(java.util.stream.Collectors.toList());
        return ResponseEntity.ok(result);
    }
}
