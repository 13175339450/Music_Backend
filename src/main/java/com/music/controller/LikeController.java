package com.music.controller;

import com.music.entity.User;
import com.music.service.LikeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/likes")
public class LikeController {
    @Autowired
    private LikeService likeService;
    
    @PostMapping("/post/{postId}")
    public ResponseEntity<Map<String, Boolean>> togglePostLike(@PathVariable Long postId, @AuthenticationPrincipal User user) {
        boolean isLiked = likeService.togglePostLike(user, postId);
        Map<String, Boolean> response = new HashMap<>();
        response.put("liked", isLiked);
        return new ResponseEntity<>(response, HttpStatus.OK);
    }
    
    @PostMapping("/comment/{commentId}")
    public ResponseEntity<Map<String, Boolean>> toggleCommentLike(@PathVariable Long commentId, @AuthenticationPrincipal User user) {
        boolean isLiked = likeService.toggleCommentLike(user, commentId);
        Map<String, Boolean> response = new HashMap<>();
        response.put("liked", isLiked);
        return new ResponseEntity<>(response, HttpStatus.OK);
    }
    
    @GetMapping("/post/{postId}/status")
    public ResponseEntity<Map<String, Boolean>> getPostLikeStatus(@PathVariable Long postId, @AuthenticationPrincipal User user) {
        boolean isLiked = likeService.isPostLikedByUser(user.getId(), postId);
        Map<String, Boolean> response = new HashMap<>();
        response.put("liked", isLiked);
        return new ResponseEntity<>(response, HttpStatus.OK);
    }
    
    @GetMapping("/comment/{commentId}/status")
    public ResponseEntity<Map<String, Boolean>> getCommentLikeStatus(@PathVariable Long commentId, @AuthenticationPrincipal User user) {
        boolean isLiked = likeService.isCommentLikedByUser(user.getId(), commentId);
        Map<String, Boolean> response = new HashMap<>();
        response.put("liked", isLiked);
        return new ResponseEntity<>(response, HttpStatus.OK);
    }
    
    @PostMapping("/music/{musicId}")
    public ResponseEntity<Map<String, Boolean>> toggleMusicLike(@PathVariable Long musicId, @AuthenticationPrincipal User user) {
        boolean isLiked = likeService.toggleMusicLike(user, musicId);
        Map<String, Boolean> response = new HashMap<>();
        response.put("liked", isLiked);
        return new ResponseEntity<>(response, HttpStatus.OK);
    }
    
    @GetMapping("/music/{musicId}/status")
    public ResponseEntity<Map<String, Boolean>> getMusicLikeStatus(@PathVariable Long musicId, @AuthenticationPrincipal User user) {
        boolean isLiked = likeService.isMusicLikedByUser(user.getId(), musicId);
        Map<String, Boolean> response = new HashMap<>();
        response.put("liked", isLiked);
        return new ResponseEntity<>(response, HttpStatus.OK);
    }
}
