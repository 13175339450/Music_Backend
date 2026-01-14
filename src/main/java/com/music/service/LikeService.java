package com.music.service;

import com.music.entity.Comment;
import com.music.entity.CommentLike;
import com.music.entity.Music;
import com.music.entity.MusicLike;
import com.music.entity.Post;
import com.music.entity.PostLike;
import com.music.entity.User;
import com.music.repository.CommentLikeRepository;
import com.music.repository.CommentRepository;
import com.music.repository.MusicLikeRepository;
import com.music.repository.MusicRepository;
import com.music.repository.PostLikeRepository;
import com.music.repository.PostRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
public class LikeService {
    @Autowired
    private PostLikeRepository postLikeRepository;
    
    @Autowired
    private CommentLikeRepository commentLikeRepository;
    
    @Autowired
    private MusicLikeRepository musicLikeRepository;
    
    @Autowired
    private PostRepository postRepository;
    
    @Autowired
    private MusicRepository musicRepository;
    
    @Autowired
    private CommentRepository commentRepository;
    
    @CacheEvict(value = {"postLikeStatus", "commentLikeStatus", "musicLikeStatus"}, allEntries = true)
    public boolean togglePostLike(User user, Long postId) {
        Post post = postRepository.findById(postId).orElseThrow(() -> new RuntimeException("Post not found"));
        
        // 检查是否已经点赞
        boolean isLiked = postLikeRepository.existsByUserIdAndPostId(user.getId(), postId);
        
        if (isLiked) {
            // 取消点赞
            postLikeRepository.findByUserIdAndPostId(user.getId(), postId).ifPresent(postLikeRepository::delete);
            post.setLikeCount(post.getLikeCount() - 1);
        } else {
            // 点赞
            PostLike postLike = new PostLike();
            postLike.setUser(user);
            postLike.setPost(post);
            postLikeRepository.save(postLike);
            post.setLikeCount(post.getLikeCount() + 1);
        }
        
        postRepository.save(post);
        return !isLiked; // 返回新的点赞状态
    }
    
    @CacheEvict(value = {"postLikeStatus", "commentLikeStatus", "musicLikeStatus"}, allEntries = true)
    public boolean toggleCommentLike(User user, Long commentId) {
        Comment comment = commentRepository.findById(commentId).orElseThrow(() -> new RuntimeException("Comment not found"));
        
        // 检查是否已经点赞
        boolean isLiked = commentLikeRepository.existsByUserIdAndCommentId(user.getId(), commentId);
        
        if (isLiked) {
            // 取消点赞
            commentLikeRepository.findByUserIdAndCommentId(user.getId(), commentId).ifPresent(commentLikeRepository::delete);
            comment.setLikeCount(comment.getLikeCount() - 1);
        } else {
            // 点赞
            CommentLike commentLike = new CommentLike();
            commentLike.setUser(user);
            commentLike.setComment(comment);
            commentLikeRepository.save(commentLike);
            comment.setLikeCount(comment.getLikeCount() + 1);
        }
        
        commentRepository.save(comment);
        return !isLiked; // 返回新的点赞状态
    }
    
    @Cacheable(value = "postLikeStatus", key = "#userId + '_' + #postId")
    public boolean isPostLikedByUser(Long userId, Long postId) {
        return postLikeRepository.existsByUserIdAndPostId(userId, postId);
    }
    
    @Cacheable(value = "commentLikeStatus", key = "#userId + '_' + #commentId")
    public boolean isCommentLikedByUser(Long userId, Long commentId) {
        return commentLikeRepository.existsByUserIdAndCommentId(userId, commentId);
    }
    
    @CacheEvict(value = {"postLikeStatus", "commentLikeStatus", "musicLikeStatus"}, allEntries = true)
    public boolean toggleMusicLike(User user, Long musicId) {
        Music music = musicRepository.findById(musicId).orElseThrow(() -> new RuntimeException("Music not found"));
        
        // 检查是否已经收藏
        boolean isLiked = musicLikeRepository.existsByUserIdAndMusicId(user.getId(), musicId);
        
        if (isLiked) {
            // 取消收藏
            musicLikeRepository.findByUserIdAndMusicId(user.getId(), musicId).ifPresent(musicLikeRepository::delete);
            music.setLikeCount(music.getLikeCount() != null ? music.getLikeCount() - 1 : 0);
        } else {
            // 收藏
            MusicLike musicLike = new MusicLike();
            musicLike.setUser(user);
            musicLike.setMusic(music);
            musicLikeRepository.save(musicLike);
            music.setLikeCount(music.getLikeCount() != null ? music.getLikeCount() + 1 : 1);
        }
        
        musicRepository.save(music);
        return !isLiked; // 返回新的收藏状态
    }
    
    @Cacheable(value = "musicLikeStatus", key = "#userId + '_' + #musicId")
    public boolean isMusicLikedByUser(Long userId, Long musicId) {
        return musicLikeRepository.existsByUserIdAndMusicId(userId, musicId);
    }
}
