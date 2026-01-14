package com.music.repository;

import com.music.entity.CommentLike;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface CommentLikeRepository extends JpaRepository<CommentLike, Long> {
    Optional<CommentLike> findByUserIdAndCommentId(Long userId, Long commentId);
    int countByCommentId(Long commentId);
    boolean existsByUserIdAndCommentId(Long userId, Long commentId);
}
