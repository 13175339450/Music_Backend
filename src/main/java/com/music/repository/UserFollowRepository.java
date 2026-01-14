package com.music.repository;

import com.music.entity.UserFollow;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface UserFollowRepository extends JpaRepository<UserFollow, Long> {
    boolean existsByFollowerIdAndFollowingId(Long followerId, Long followingId);
    void deleteByFollowerIdAndFollowingId(Long followerId, Long followingId);
    long countByFollowingId(Long followingId); // Fan count
    long countByFollowerId(Long followerId);   // Following count
    long countByFollowingIdAndCreatedAtAfter(Long followingId, java.time.LocalDateTime date);
    long countByFollowingIdAndCreatedAtBetween(Long followingId, java.time.LocalDateTime start, java.time.LocalDateTime end);
    void deleteByFollowerId(Long followerId);
    void deleteByFollowingId(Long followingId);
    List<UserFollow> findByFollowerId(Long followerId);
    List<UserFollow> findByFollowingId(Long followingId);
}
