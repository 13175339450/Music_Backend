package com.music.controller;

import com.music.entity.Comment;
import com.music.dto.CommentDTO;
import com.music.entity.Music;
import com.music.entity.User;
import com.music.repository.CommentRepository;
import com.music.repository.MusicRepository;
import com.music.service.MusicService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/musician")
@PreAuthorize("hasRole('MUSICIAN')")
public class MusicianController {

    @Autowired
    private MusicService musicService;

    @Autowired
    private MusicRepository musicRepository;

    @Autowired
    private CommentRepository commentRepository;

    @Autowired
    private com.music.service.UserFollowService userFollowService;

    @Autowired
    private com.music.repository.PlayRecordRepository playRecordRepository;

    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getMusicianStats(@AuthenticationPrincipal User user) {
        List<Music> myMusic = musicRepository.findByMusicianId(user.getId());
        
        long totalPlays = myMusic.stream().mapToLong(m -> m.getPlayCount() == null ? 0 : m.getPlayCount()).sum();
        long totalDownloads = myMusic.stream().mapToLong(m -> m.getDownloadCount() == null ? 0 : m.getDownloadCount()).sum();
        long totalComments = myMusic.stream().mapToLong(m -> m.getCommentCount() == null ? 0 : m.getCommentCount()).sum();
        long totalLikes = myMusic.stream().mapToLong(m -> m.getLikeCount() == null ? 0 : m.getLikeCount()).sum();
        long totalShares = myMusic.stream().mapToLong(m -> m.getShareCount() == null ? 0 : m.getShareCount()).sum();
        
        long totalFans = userFollowService.getFollowerCount(user.getId());
        
        // Calculate fan growth
        java.time.LocalDateTime now = java.time.LocalDateTime.now();
        java.time.LocalDateTime oneWeekAgo = now.minusDays(7);
        java.util.Date oneWeekAgoDate = java.util.Date.from(oneWeekAgo.atZone(java.time.ZoneId.systemDefault()).toInstant());
        
        long newFansLastWeek = userFollowService.getNewFollowersCountBetween(user.getId(), oneWeekAgo, now);
        long totalFansLastWeek = totalFans - newFansLastWeek;
        
        double followersChange = 0;
        if (totalFansLastWeek > 0) {
            followersChange = ((double) newFansLastWeek / totalFansLastWeek) * 100;
        } else if (totalFans > 0) {
            followersChange = 100.0;
        }

        // Calculate plays growth
        long playsLastWeek = playRecordRepository.countByMusicianIdAndPlayTimeAfter(user.getId(), oneWeekAgo);
        long totalPlaysLastWeek = totalPlays - playsLastWeek;
        double playsChange = 0;
        if (totalPlaysLastWeek > 0) {
            playsChange = ((double) playsLastWeek / totalPlaysLastWeek) * 100;
        } else if (totalPlays > 0) {
            playsChange = 100.0;
        }

        // Calculate likes growth
        long newLikesLastWeek = myMusic.stream()
                .filter(m -> m.getCreateTime() != null && m.getCreateTime().after(oneWeekAgoDate))
                .mapToLong(m -> m.getLikeCount() == null ? 0 : m.getLikeCount())
                .sum();
        long totalLikesLastWeek = totalLikes - newLikesLastWeek;
        double likesChange = 0;
        if (totalLikesLastWeek > 0) {
            likesChange = ((double) newLikesLastWeek / totalLikesLastWeek) * 100;
        } else if (totalLikes > 0) {
            likesChange = 100.0;
        }

        // Calculate music growth
        long newMusicLastWeek = myMusic.stream()
                .filter(m -> m.getCreateTime() != null && m.getCreateTime().after(oneWeekAgoDate))
                .count();
        long totalMusicLastWeek = myMusic.size() - newMusicLastWeek;
        double musicChange = 0;
        if (totalMusicLastWeek > 0) {
            musicChange = ((double) newMusicLastWeek / totalMusicLastWeek) * 100;
        } else if (myMusic.size() > 0) {
            musicChange = 100.0;
        }

        Map<String, Object> stats = new HashMap<>();
        stats.put("totalMusic", myMusic.size());
        stats.put("totalPlays", totalPlays);
        stats.put("totalDownloads", totalDownloads);
        stats.put("totalComments", totalComments);
        stats.put("totalLikes", totalLikes);
        stats.put("totalShares", totalShares);
        stats.put("totalFans", totalFans);
        stats.put("totalFollowers", totalFans);
        stats.put("followersChange", Math.round(followersChange * 10.0) / 10.0);
        stats.put("playsChange", Math.round(playsChange * 10.0) / 10.0);
        stats.put("likesChange", Math.round(likesChange * 10.0) / 10.0);
        stats.put("musicChange", Math.round(musicChange * 10.0) / 10.0);
        
        return ResponseEntity.ok(stats);
    }
    
    @GetMapping("/stats/plays")
    public ResponseEntity<java.util.List<java.util.Map<String, Object>>> getPlaysTrend(@AuthenticationPrincipal User user, @RequestParam(value = "days", defaultValue = "7") int days) {
        java.time.LocalDate today = java.time.LocalDate.now();
        java.util.List<java.util.Map<String, Object>> trend = new java.util.ArrayList<>();
        for (int i = days - 1; i >= 0; i--) {
            java.time.LocalDate d = today.minusDays(i);
            java.time.LocalDateTime start = d.atStartOfDay();
            java.time.LocalDateTime end = d.plusDays(1).atStartOfDay();
            long count = playRecordRepository.countByMusicMusicianIdAndPlayTimeBetween(user.getId(), start, end);
            java.util.Map<String, Object> item = new java.util.HashMap<>();
            item.put("date", d.toString());
            item.put("count", count);
            trend.add(item);
        }
        return ResponseEntity.ok(trend);
    }
    
    @GetMapping("/stats/fans")
    public ResponseEntity<java.util.List<java.util.Map<String, Object>>> getFansGrowth(@AuthenticationPrincipal User user, @RequestParam(value = "days", defaultValue = "30") int days) {
        java.time.LocalDate today = java.time.LocalDate.now();
        java.util.List<java.util.Map<String, Object>> growth = new java.util.ArrayList<>();
        for (int i = days - 1; i >= 0; i--) {
            java.time.LocalDate d = today.minusDays(i);
            java.time.LocalDateTime start = d.atStartOfDay();
            java.time.LocalDateTime end = d.plusDays(1).atStartOfDay();
            long count = userFollowService.getNewFollowersCountBetween(user.getId(), start, end);
            java.util.Map<String, Object> item = new java.util.HashMap<>();
            item.put("date", d.toString());
            item.put("count", count);
            growth.add(item);
        }
        return ResponseEntity.ok(growth);
    }

    @GetMapping("/music")
    public ResponseEntity<List<Music>> getMyMusic(@AuthenticationPrincipal User user) {
        List<Music> myMusic = musicRepository.findByMusicianId(user.getId());
        return ResponseEntity.ok(myMusic);
    }

    @PostMapping("/upload")
    public ResponseEntity<?> uploadMusic(
            @RequestParam("title") String title,
            @RequestParam("artist") String artist,
            @RequestParam("description") String description,
            @RequestParam(value = "copyright", required = false) String copyright,
            @RequestParam("audioFile") MultipartFile audioFile,
            @RequestParam(value = "coverFile", required = false) MultipartFile coverFile,
            @AuthenticationPrincipal User user) {
        try {
            Music music = new Music();
            music.setTitle(title);
            music.setArtist(artist);
            music.setDescription(description);
            music.setCopyrightInfo(copyright);
            music.setMusicianId(user.getId());
            
            // Set some defaults
            music.setDuration(0); // This should ideally be extracted from the file
            music.setAlbum("Single"); // Default album
            music.setGenre("Pop"); // Default genre

            Music savedMusic = musicService.uploadMusic(music, audioFile, coverFile);
            return ResponseEntity.ok(savedMusic);
        } catch (IOException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Upload failed: " + e.getMessage());
        }
    }

    @GetMapping("/comments")
    public ResponseEntity<List<CommentDTO>> getMyComments(@AuthenticationPrincipal User user) {
        // 1. Get all music by this musician
        List<Music> myMusic = musicRepository.findByMusicianId(user.getId());
        
        if (myMusic.isEmpty()) {
            return ResponseEntity.ok(Collections.emptyList());
        }
        
        // 2. Extract IDs
        List<Long> musicIds = myMusic.stream().map(Music::getId).collect(Collectors.toList());
        
        // 3. Fetch comments
        List<Comment> comments = commentRepository.findByMusicIdInWithUserAndMusic(musicIds);
        
        // 4. Convert to DTOs
        List<CommentDTO> commentDTOs = comments.stream()
                .map(CommentDTO::fromComment)
                .collect(Collectors.toList());
                
        return ResponseEntity.ok(commentDTOs);
    }

    @GetMapping("/debug/comments")
    public ResponseEntity<Map<String, Object>> debugComments(@AuthenticationPrincipal User user) {
        Map<String, Object> debugInfo = new HashMap<>();
        debugInfo.put("userId", user.getId());
        debugInfo.put("username", user.getUsername());
        
        List<Music> myMusic = musicRepository.findByMusicianId(user.getId());
        debugInfo.put("musicCount", myMusic.size());
        
        List<Long> musicIds = myMusic.stream().map(Music::getId).collect(Collectors.toList());
        debugInfo.put("musicIds", musicIds);
        
        if (!musicIds.isEmpty()) {
            List<Comment> comments = commentRepository.findByMusicIdInWithUserAndMusic(musicIds);
            debugInfo.put("commentsFound", comments.size());
            if (!comments.isEmpty()) {
                debugInfo.put("firstCommentContent", comments.get(0).getContent());
                debugInfo.put("firstCommentMusicId", comments.get(0).getMusic() != null ? comments.get(0).getMusic().getId() : "null");
            }
        } else {
            debugInfo.put("commentsFound", 0);
        }
        
        return ResponseEntity.ok(debugInfo);
    }

    @DeleteMapping("/music/{id}")
    public ResponseEntity<?> deleteMusic(@PathVariable Long id, @AuthenticationPrincipal User user) {
        return musicRepository.findById(id)
                .map(music -> {
                    if (!music.getMusicianId().equals(user.getId())) {
                        return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Access denied");
                    }
                    musicService.deleteMusic(id);
                    return ResponseEntity.ok("Music deleted successfully");
                })
                .orElse(ResponseEntity.notFound().build());
    }
    
    @PutMapping("/music/{id}")
    public ResponseEntity<?> updateMusic(@PathVariable Long id, @RequestBody Music updated, @AuthenticationPrincipal User user) {
        return musicRepository.findById(id)
                .map(existing -> {
                    if (!existing.getMusicianId().equals(user.getId())) {
                        return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Access denied");
                    }
                    if (updated.getTitle() != null) {
                        existing.setTitle(updated.getTitle());
                    }
                    if (updated.getArtist() != null) {
                        existing.setArtist(updated.getArtist());
                    }
                    if (updated.getDescription() != null) {
                        existing.setDescription(updated.getDescription());
                    }
                    if (updated.getCopyrightInfo() != null) {
                        existing.setCopyrightInfo(updated.getCopyrightInfo());
                    }
                    Music saved = musicService.updateMusic(existing);
                    return ResponseEntity.ok(saved);
                })
                .orElse(ResponseEntity.notFound().build());
    }
}
