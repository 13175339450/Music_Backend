package com.music.controller;

import com.music.entity.Comment;
import com.music.entity.User;
import com.music.service.CommentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;
import java.util.Map;
import java.util.stream.Collectors;
import com.music.dto.CommentDTO;

@RestController
@RequestMapping("/comments")
public class CommentController {
    @Autowired
    private CommentService commentService;
    
    @PostMapping
    public ResponseEntity<CommentDTO> createComment(@RequestBody Comment comment, @AuthenticationPrincipal User user) {
        comment.setUser(user);
        Comment createdComment = commentService.createComment(comment);
        return new ResponseEntity<>(CommentDTO.fromComment(createdComment), HttpStatus.CREATED);
    }
    
    @PostMapping("/music/{musicId}")
    public ResponseEntity<CommentDTO> createMusicComment(@PathVariable Long musicId,
                                                      @RequestBody Map<String, String> body,
                                                      @AuthenticationPrincipal User user) {
        String content = body.getOrDefault("content", "").trim();
        if (content.isEmpty()) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
        Comment createdComment = commentService.createMusicComment(musicId, content, user);
        return new ResponseEntity<>(CommentDTO.fromComment(createdComment), HttpStatus.CREATED);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<Comment> updateComment(@PathVariable Long id, @RequestBody Comment comment, @AuthenticationPrincipal User user) {
        Optional<Comment> existingComment = commentService.getCommentById(id);
        if (existingComment.isEmpty()) {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
        
        // 检查是否是评论的所有者
        if (!existingComment.get().getUser().getId().equals(user.getId())) {
            return new ResponseEntity<>(HttpStatus.FORBIDDEN);
        }
        
        comment.setId(id);
        comment.setUser(user);
        Comment updatedComment = commentService.updateComment(comment);
        return new ResponseEntity<>(updatedComment, HttpStatus.OK);
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteComment(@PathVariable Long id, @AuthenticationPrincipal User user) {
        Optional<Comment> existingComment = commentService.getCommentById(id);
        if (existingComment.isEmpty()) {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
        
        // 检查是否是评论的所有者
        if (!existingComment.get().getUser().getId().equals(user.getId())) {
            return new ResponseEntity<>(HttpStatus.FORBIDDEN);
        }
        
        commentService.deleteComment(id);
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<CommentDTO> getCommentById(@PathVariable Long id) {
        Optional<Comment> comment = commentService.getCommentById(id);
        return comment.map(c -> ResponseEntity.ok(CommentDTO.fromComment(c))).orElseGet(() -> new ResponseEntity<>(HttpStatus.NOT_FOUND));
    }
    
    @GetMapping("/post/{postId}")
    public ResponseEntity<List<CommentDTO>> getCommentsByPostId(@PathVariable Long postId) {
        List<CommentDTO> dtos = commentService.getCommentsByPostId(postId).stream()
                .map(CommentDTO::fromComment).collect(Collectors.toList());
        return new ResponseEntity<>(dtos, HttpStatus.OK);
    }
    
    @GetMapping("/music/{musicId}")
    public ResponseEntity<List<CommentDTO>> getCommentsByMusicId(@PathVariable Long musicId) {
        List<CommentDTO> dtos = commentService.getCommentsByMusicId(musicId).stream()
                .map(CommentDTO::fromComment).collect(Collectors.toList());
        return new ResponseEntity<>(dtos, HttpStatus.OK);
    }
    
    @GetMapping("/replies/{parentCommentId}")
    public ResponseEntity<List<CommentDTO>> getRepliesByParentCommentId(@PathVariable Long parentCommentId) {
        List<CommentDTO> dtos = commentService.getRepliesByParentCommentId(parentCommentId).stream()
                .map(CommentDTO::fromComment).collect(Collectors.toList());
        return new ResponseEntity<>(dtos, HttpStatus.OK);
    }
    
    @PostMapping("/{parentCommentId}/reply")
    public ResponseEntity<CommentDTO> createReply(@PathVariable Long parentCommentId,
                                                @RequestBody Map<String, String> body,
                                                @AuthenticationPrincipal User user) {
        String content = body.getOrDefault("content", "").trim();
        if (content.isEmpty()) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
        
        Optional<Comment> parentComment = commentService.getCommentById(parentCommentId);
        if (parentComment.isEmpty()) {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
        
        Comment reply = new Comment();
        reply.setContent(content);
        reply.setUser(user);
        reply.setParentComment(parentComment.get());
        
        // 设置与原评论相同的音乐或动态
        if (parentComment.get().getMusic() != null) {
            reply.setMusic(parentComment.get().getMusic());
        } else if (parentComment.get().getPost() != null) {
            reply.setPost(parentComment.get().getPost());
        }
        
        Comment createdReply = commentService.createComment(reply);
        return new ResponseEntity<>(CommentDTO.fromComment(createdReply), HttpStatus.CREATED);
    }
}
