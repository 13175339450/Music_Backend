package com.music.repository;

import com.music.entity.PlayRecord;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PlayRecordRepository extends JpaRepository<PlayRecord, Long> {
    List<PlayRecord> findByUserId(Long userId);
    
    @Query("SELECT p.music.genre, COUNT(p) as count FROM PlayRecord p WHERE p.user.id = :userId GROUP BY p.music.genre ORDER BY count DESC")
    List<Object[]> findFavoriteGenresByUserId(@Param("userId") Long userId);

    List<PlayRecord> findByUserIdOrderByPlayTimeDesc(Long userId);

    @Query("SELECT COUNT(p) FROM PlayRecord p WHERE p.music.musicianId = :musicianId AND p.playTime > :date")
    long countByMusicianIdAndPlayTimeAfter(@Param("musicianId") Long musicianId, @Param("date") java.time.LocalDateTime date);
    
    @Query("SELECT COUNT(p) FROM PlayRecord p WHERE p.music.musicianId = :musicianId AND p.playTime >= :start AND p.playTime < :end")
    long countByMusicMusicianIdAndPlayTimeBetween(@Param("musicianId") Long musicianId, @Param("start") java.time.LocalDateTime start, @Param("end") java.time.LocalDateTime end);
    
    @Query("SELECT COUNT(p) FROM PlayRecord p WHERE p.music.musicianId = :musicianId AND p.playTime >= :start AND p.playTime < :end")
    long countByMusic_MusicianIdAndPlayTimeBetween(@Param("musicianId") Long musicianId, @Param("start") java.time.LocalDateTime start, @Param("end") java.time.LocalDateTime end);
}
