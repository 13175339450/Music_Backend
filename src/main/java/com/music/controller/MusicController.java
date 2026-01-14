package com.music.controller;

import com.music.entity.Music;
import com.music.service.MusicService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/music")
public class MusicController {
    @Autowired
    private MusicService musicService;

    // 上传音乐(仅音乐人)
    @PostMapping("/upload")
    @PreAuthorize("hasRole('MUSICIAN')")
    public ResponseEntity<?> uploadMusic(
            @RequestPart("music") Music music,
            @RequestPart("musicFile") MultipartFile musicFile,
            @RequestPart(value = "coverFile", required = false) MultipartFile coverFile) {
        try {
            Music uploadedMusic = musicService.uploadMusic(music, musicFile, coverFile);
            return ResponseEntity.ok(uploadedMusic);
        } catch (IOException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("File upload failed: " + e.getMessage());
        }
    }

    // 获取音乐列表
    @GetMapping("/list")
    public ResponseEntity<List<Music>> getMusicList() {
        List<Music> musicList = musicService.getMusicList();
        return ResponseEntity.ok(musicList);
    }

    // 根据ID获取音乐
    @GetMapping("/detail/{id}")
    public ResponseEntity<?> getMusicDetail(@PathVariable Long id) {
        Optional<Music> music = musicService.getMusicById(id);
        return music.map(ResponseEntity::ok).orElseGet(() -> ResponseEntity.notFound().build());
    }

    @Autowired
    private com.music.repository.PlayRecordRepository playRecordRepository;

    @Autowired
    private com.music.repository.UserRepository userRepository;

    // 播放音乐
    @GetMapping("/play/{id}")
    public ResponseEntity<Resource> playMusic(@PathVariable Long id) {
        Optional<Music> optionalMusic = musicService.getMusicById(id);
        if (!optionalMusic.isPresent()) {
            return ResponseEntity.notFound().build();
        }

        Music music = optionalMusic.get();
        File musicFile = musicService.getMusicFile(music.getFilePath());
        if (!musicFile.exists()) {
            return ResponseEntity.notFound().build();
        }

        // 更新播放量
        musicService.updatePlayCount(id);
        
        // 记录播放历史 (如果用户已登录)
        try {
            org.springframework.security.core.Authentication auth = org.springframework.security.core.context.SecurityContextHolder.getContext().getAuthentication();
            if (auth != null && auth.isAuthenticated() && !"anonymousUser".equals(auth.getPrincipal())) {
                String username = null;
                if (auth.getPrincipal() instanceof org.springframework.security.core.userdetails.UserDetails) {
                    username = ((org.springframework.security.core.userdetails.UserDetails) auth.getPrincipal()).getUsername();
                } else if (auth.getPrincipal() instanceof String) {
                    username = (String) auth.getPrincipal();
                }
                
                if (username != null) {
                    java.util.Optional<com.music.entity.User> userOpt = userRepository.findByUsername(username);
                    if (userOpt.isPresent()) {
                        com.music.entity.PlayRecord record = new com.music.entity.PlayRecord();
                        record.setUser(userOpt.get());
                        record.setMusic(music);
                        record.setPlayDuration(music.getDuration()); // 默认记录完整时长
                        playRecordRepository.save(record);
                    }
                }
            }
        } catch (Exception e) {
            // 忽略记录失败，不影响播放
            e.printStackTrace();
        }

        // 返回音乐文件
        Resource resource = new FileSystemResource(musicFile);

        HttpHeaders headers = new HttpHeaders();
        headers.add(HttpHeaders.CONTENT_DISPOSITION, "inline; filename=\"" + music.getTitle() + ".mp3\"");
        headers.add(HttpHeaders.CONTENT_TYPE, "audio/mpeg");

        return ResponseEntity.ok()
                .headers(headers)
                .contentLength(musicFile.length())
                .body(resource);
    }

    // 下载音乐
    @GetMapping("/download/{id}")
    public ResponseEntity<Resource> downloadMusic(@PathVariable Long id) {
        Optional<Music> optionalMusic = musicService.getMusicById(id);
        if (!optionalMusic.isPresent()) {
            return ResponseEntity.notFound().build();
        }

        Music music = optionalMusic.get();
        File musicFile = musicService.getMusicFile(music.getFilePath());
        if (!musicFile.exists()) {
            return ResponseEntity.notFound().build();
        }

        // 更新下载量
        musicService.updateDownloadCount(id);

        // 返回音乐文件
        Resource resource = new FileSystemResource(musicFile);
        HttpHeaders headers = new HttpHeaders();
        headers.add(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + music.getTitle() + ".mp3\"");
        headers.add(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_OCTET_STREAM_VALUE);

        return ResponseEntity.ok()
                .headers(headers)
                .contentLength(musicFile.length())
                .body(resource);
    }

    // 获取封面图片
    @GetMapping("/cover/{id}")
    public ResponseEntity<Resource> getCoverImage(@PathVariable Long id) {
        Optional<Music> optionalMusic = musicService.getMusicById(id);
        if (!optionalMusic.isPresent() || optionalMusic.get().getCoverPath() == null) {
            return ResponseEntity.notFound().build();
        }

        Music music = optionalMusic.get();
        File coverFile = musicService.getCoverFile(music.getCoverPath());
        if (!coverFile.exists()) {
            return ResponseEntity.notFound().build();
        }

        Resource resource = new FileSystemResource(coverFile);
        java.util.Optional<MediaType> mediaType = org.springframework.http.MediaTypeFactory.getMediaType(coverFile.getName());
        return ResponseEntity.ok()
                .contentType(mediaType.orElse(MediaType.APPLICATION_OCTET_STREAM))
                .contentLength(coverFile.length())
                .body(resource);
    }

    // 搜索音乐
    @GetMapping("/search")
    public ResponseEntity<List<Music>> searchMusic(@RequestParam String keyword) {
        List<Music> musicList = musicService.searchMusic(keyword);
        return ResponseEntity.ok(musicList);
    }

    // 根据艺术家获取音乐
    @GetMapping("/artist/{artist}")
    public ResponseEntity<List<Music>> getMusicByArtist(@PathVariable String artist) {
        List<Music> musicList = musicService.getMusicByArtist(artist);
        return ResponseEntity.ok(musicList);
    }

    // 根据风格获取音乐
    @GetMapping("/genre/{genre}")
    public ResponseEntity<List<Music>> getMusicByGenre(@PathVariable String genre) {
        List<Music> musicList = musicService.getMusicByGenre(genre);
        return ResponseEntity.ok(musicList);
    }

    // 删除音乐(仅音乐人或管理员)
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('MUSICIAN') or hasRole('ADMIN')")
    public ResponseEntity<?> deleteMusic(@PathVariable Long id) {
        boolean deleted = musicService.deleteMusic(id);
        return deleted ? ResponseEntity.ok().build() : ResponseEntity.notFound().build();
    }
}
