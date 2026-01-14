package com.music.repository;

import com.music.entity.Comment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;

public interface CommentRepository extends JpaRepository<Comment, Long> {
    List<Comment> findByPostId(Long postId);
    List<Comment> findByMusicId(Long musicId);
    List<Comment> findByParentCommentId(Long parentCommentId);
    
    @Query("SELECT c FROM Comment c JOIN FETCH c.user LEFT JOIN FETCH c.replies r WHERE c.post.id = :postId AND c.parentComment IS NULL ORDER BY c.createdAt DESC")
    List<Comment> findByPostIdWithUser(@Param("postId") Long postId);
    
    @Query("SELECT c FROM Comment c JOIN FETCH c.user LEFT JOIN FETCH c.replies r WHERE c.music.id = :musicId AND c.parentComment IS NULL ORDER BY c.createdAt DESC")
    List<Comment> findByMusicIdWithUser(@Param("musicId") Long musicId);
    
    @Query("SELECT c FROM Comment c JOIN FETCH c.user WHERE c.parentComment.id = :parentCommentId ORDER BY c.createdAt ASC")
    List<Comment> findRepliesByParentCommentIdWithUser(@Param("parentCommentId") Long parentCommentId);

    @Query("SELECT c FROM Comment c JOIN FETCH c.user JOIN FETCH c.music WHERE c.music.musicianId = :musicianId ORDER BY c.createdAt DESC")
    List<Comment> findByMusicianIdWithUserAndMusic(@Param("musicianId") Long musicianId);

    @Query("SELECT c FROM Comment c JOIN FETCH c.user JOIN FETCH c.music WHERE c.music.id IN :musicIds ORDER BY c.createdAt DESC")
    List<Comment> findByMusicIdInWithUserAndMusic(@Param("musicIds") List<Long> musicIds);
}
