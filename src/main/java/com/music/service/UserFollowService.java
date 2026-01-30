package com.music.service;

import com.music.entity.User;
import com.music.entity.UserFollow;
import com.music.repository.UserFollowRepository;
import com.music.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class UserFollowService {
    @Autowired
    private UserFollowRepository userFollowRepository;

    @Autowired
    private UserRepository userRepository;

    @Transactional
    public void followUser(Long followerId, Long followingId) {
        if (followerId.equals(followingId)) {
            throw new IllegalArgumentException("Cannot follow yourself");
        }
        if (userFollowRepository.existsByFollowerIdAndFollowingId(followerId, followingId)) {
            return; // Already following
        }
        User follower = userRepository.findById(followerId).orElseThrow(() -> new IllegalArgumentException("Follower not found"));
        User following = userRepository.findById(followingId).orElseThrow(() -> new IllegalArgumentException("Following user not found"));

        UserFollow follow = new UserFollow();
        follow.setFollower(follower);
        follow.setFollowing(following);
        userFollowRepository.save(follow);
    }

    @Transactional
    public void unfollowUser(Long followerId, Long followingId) {
        userFollowRepository.deleteByFollowerIdAndFollowingId(followerId, followingId);
    }

    public boolean isFollowing(Long followerId, Long followingId) {
        return userFollowRepository.existsByFollowerIdAndFollowingId(followerId, followingId);
    }

    public long getFollowerCount(Long userId) {
        return userFollowRepository.countByFollowingId(userId);
    }

    public long getFollowingCount(Long userId) {
        return userFollowRepository.countByFollowerId(userId);
    }

    public long getNewFollowersCount(Long userId, int days) {
        java.time.LocalDateTime startDate = java.time.LocalDateTime.now().minusDays(days);
        return userFollowRepository.countByFollowingIdAndCreateTimeAfter(userId, startDate);
    }

    public long getNewFollowersCountBetween(Long userId, java.time.LocalDateTime start, java.time.LocalDateTime end) {
        return userFollowRepository.countByFollowingIdAndCreateTimeBetween(userId, start, end);
    }

    public List<User> getFollowingUsers(Long userId) {
        List<UserFollow> follows = userFollowRepository.findByFollowerId(userId);
        return follows.stream()
                .map(UserFollow::getFollowing)
                .collect(Collectors.toList());
    }

    public List<User> getFollowers(Long userId) {
        List<UserFollow> follows = userFollowRepository.findByFollowingId(userId);
        return follows.stream()
                .map(UserFollow::getFollower)
                .collect(Collectors.toList());
    }
}
