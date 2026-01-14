package com.music.service;

import com.music.entity.Comment;
import com.music.entity.Music;
import com.music.entity.User;
import com.music.repository.CommentRepository;
import com.music.repository.MusicRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class CommentService {
    @Autowired
    private CommentRepository commentRepository;
    
    @Autowired
    private MusicRepository musicRepository;
    
    public Comment createComment(Comment comment) {
        return commentRepository.save(comment);
    }
    
    public Comment updateComment(Comment comment) {
        return commentRepository.save(comment);
    }
    
    public void deleteComment(Long commentId) {
        commentRepository.deleteById(commentId);
    }
    
    public Optional<Comment> getCommentById(Long commentId) {
        return commentRepository.findById(commentId);
    }
    
    public List<Comment> getCommentsByPostId(Long postId) {
        return commentRepository.findByPostIdWithUser(postId);
    }
    
    public List<Comment> getCommentsByMusicId(Long musicId) {
        return commentRepository.findByMusicIdWithUser(musicId);
    }
    
    public List<Comment> getRepliesByParentCommentId(Long parentCommentId) {
        return commentRepository.findRepliesByParentCommentIdWithUser(parentCommentId);
    }
    
    public Comment createMusicComment(Long musicId, String content, User user) {
        Music music = musicRepository.findById(musicId)
                .orElseThrow(() -> new IllegalArgumentException("Music not found"));
        Comment comment = new Comment();
        comment.setContent(content);
        comment.setUser(user);
        comment.setMusic(music);
        return commentRepository.save(comment);
    }
}
