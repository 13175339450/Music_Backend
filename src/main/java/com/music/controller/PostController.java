package com.music.controller;

import com.music.dto.PostDTO;
import com.music.entity.Post;
import com.music.entity.Role;
import com.music.entity.User;
import com.music.service.PostService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/posts")
public class PostController {
    @Autowired
    private PostService postService;
    
    // 检查用户是否为管理员
    private boolean isAdmin(User user) {
        if (user == null || user.getRoles() == null) {
            return false;
        }
        return user.getRoles().stream()
                .map(Role::getName)
                .anyMatch(roleName -> "ROLE_ADMIN".equals(roleName));
    }
    
    @PostMapping
    public ResponseEntity<Post> createPost(@RequestBody Post post, @AuthenticationPrincipal User user) {
        post.setUser(user);
        Post createdPost = postService.createPost(post);
        return new ResponseEntity<>(createdPost, HttpStatus.CREATED);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<Post> updatePost(@PathVariable Long id, @RequestBody Post post, @AuthenticationPrincipal User user) {
        Optional<Post> existingPost = postService.getPostById(id);
        if (existingPost.isEmpty()) {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
        
        // 检查是否是动态的所有者
        if (!existingPost.get().getUser().getId().equals(user.getId())) {
            return new ResponseEntity<>(HttpStatus.FORBIDDEN);
        }
        
        post.setId(id);
        post.setUser(user);
        Post updatedPost = postService.updatePost(post);
        return new ResponseEntity<>(updatedPost, HttpStatus.OK);
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletePost(@PathVariable Long id, @AuthenticationPrincipal User user) {
        Optional<Post> existingPost = postService.getPostById(id);
        if (existingPost.isEmpty()) {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
        
        // 检查是否是动态的所有者或管理员
        if (!existingPost.get().getUser().getId().equals(user.getId()) && !isAdmin(user)) {
            return new ResponseEntity<>(HttpStatus.FORBIDDEN);
        }
        
        postService.deletePost(id);
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<PostDTO> getPostById(@PathVariable Long id, @AuthenticationPrincipal User user) {
        boolean isAdmin = isAdmin(user);
        Optional<PostDTO> postDTO = postService.getPostWithLikeStatus(id, user.getId(), isAdmin);
        return postDTO.map(ResponseEntity::ok).orElseGet(() -> new ResponseEntity<>(HttpStatus.NOT_FOUND));
    }
    
    @GetMapping
    public ResponseEntity<List<PostDTO>> getAllPosts(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @AuthenticationPrincipal User user) {
        
        boolean isAdmin = isAdmin(user);
        Pageable pageable = PageRequest.of(page, size);
        List<PostDTO> postDTOs = postService.getPostsWithLikeStatus(pageable, user.getId(), isAdmin);
        return new ResponseEntity<>(postDTOs, HttpStatus.OK);
    }
    
    @GetMapping("/user/{userId}")
    public ResponseEntity<List<Post>> getPostsByUserId(@PathVariable Long userId) {
        List<Post> posts = postService.getPostsByUserId(userId);
        return new ResponseEntity<>(posts, HttpStatus.OK);
    }
    
    // 测试接口，用于调试权限问题
    @GetMapping("/test")
    public ResponseEntity<String> testPermission(@AuthenticationPrincipal User user) {
        StringBuilder response = new StringBuilder();
        response.append("User: " + user.getUsername() + "\n");
        response.append("User ID: " + user.getId() + "\n");
        response.append("Roles: ");
        user.getRoles().forEach(role -> response.append(role.getName() + " "));
        response.append("\nIs Admin: " + isAdmin(user));
        return ResponseEntity.ok(response.toString());
    }
    
    @PostMapping("/{id}/like")
    public ResponseEntity<Void> likePost(@PathVariable Long id, @AuthenticationPrincipal User user) {
        try {
            postService.likePost(id, user);
            return new ResponseEntity<>(HttpStatus.OK);
        } catch (IllegalArgumentException e) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }
    
    @DeleteMapping("/{id}/like")
    public ResponseEntity<Void> unlikePost(@PathVariable Long id, @AuthenticationPrincipal User user) {
        try {
            postService.unlikePost(id, user);
            return new ResponseEntity<>(HttpStatus.OK);
        } catch (IllegalArgumentException e) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
    }

    @PostMapping("/{id}/share")
    public ResponseEntity<Void> sharePost(@PathVariable Long id) {
        try {
            postService.sharePost(id);
            return new ResponseEntity<>(HttpStatus.OK);
        } catch (IllegalArgumentException e) {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
    }
}
