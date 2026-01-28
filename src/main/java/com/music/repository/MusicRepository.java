package com.music.repository;

import com.music.entity.Music;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MusicRepository extends JpaRepository<Music, Long> {
    List<Music> findByTitleContaining(String title);
    List<Music> findByArtistContaining(String artist);
    List<Music> findByGenre(String genre);
    List<Music> findByMusicianId(Long musicianId);
    List<Music> findByStatus(Integer status);
    List<Music> findByTitleContainingAndStatus(String title, Integer status);
    List<Music> findByArtistContainingAndStatus(String artist, Integer status);
    List<Music> findByGenreAndStatus(String genre, Integer status);

    @Query("SELECT m FROM Music m WHERE (m.title LIKE CONCAT('%', :keyword, '%') OR m.artist LIKE CONCAT('%', :keyword, '%')) AND m.status = :status")
    List<Music> findByTitleOrArtistContainingAndStatus(@Param("keyword") String keyword, @Param("status") Integer status);
    
    @Query("SELECT m.genre, COUNT(m) FROM Music m WHERE m.genre IS NOT NULL AND m.status = 1 GROUP BY m.genre")
    List<Object[]> countByGenre();
    
    @Query("SELECT SUM(m.playCount) FROM Music m")
    Long sumPlayCount();
}