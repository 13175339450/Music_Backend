package com.music.repository;

import com.music.entity.MusicLike;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface MusicLikeRepository extends JpaRepository<MusicLike, Long> {
    Optional<MusicLike> findByUserIdAndMusicId(Long userId, Long musicId);
    long countByMusicId(Long musicId);
    long countByUserId(Long userId);
    boolean existsByUserIdAndMusicId(Long userId, Long musicId);
    void deleteByUserId(Long userId);
}
