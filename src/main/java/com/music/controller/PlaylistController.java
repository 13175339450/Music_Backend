package com.music.controller;

import com.music.entity.Music;
import com.music.entity.Playlist;
import com.music.entity.User;
import com.music.service.MusicService;
import com.music.service.PlaylistService;
import com.music.dto.PlaylistDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/playlist")
public class PlaylistController {

    @Autowired
    private PlaylistService playlistService;

    @Autowired
    private MusicService musicService;

    @PostMapping
    public ResponseEntity<Playlist> createPlaylist(@RequestBody Playlist playlist, @AuthenticationPrincipal User user) {
        playlist.setUser(user);
        Playlist createdPlaylist = playlistService.createPlaylist(playlist);
        return new ResponseEntity<>(createdPlaylist, HttpStatus.CREATED);
    }

    @GetMapping("/my")
    public ResponseEntity<List<PlaylistDTO>> getMyPlaylists(@AuthenticationPrincipal User user) {
        List<PlaylistDTO> playlists = playlistService.getMyPlaylistsDTO(user.getId());
        return ResponseEntity.ok(playlists);
    }

    @GetMapping("/public")
    public ResponseEntity<List<PlaylistDTO>> getPublicPlaylists() {
        List<PlaylistDTO> playlists = playlistService.getPublicPlaylistsDTO();
        return ResponseEntity.ok(playlists);
    }

    @GetMapping("/{id}")
    public ResponseEntity<PlaylistDTO> getPlaylistById(@PathVariable Long id) {
        Optional<Playlist> playlist = playlistService.getPlaylistById(id);
        return playlist.map(p -> ResponseEntity.ok(PlaylistDTO.fromPlaylist(p)))
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<Playlist> updatePlaylist(@PathVariable Long id, @RequestBody Playlist playlist, @AuthenticationPrincipal User user) {
        Optional<Playlist> existingPlaylistOpt = playlistService.getPlaylistById(id);
        if (existingPlaylistOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Playlist existingPlaylist = existingPlaylistOpt.get();
        if (!existingPlaylist.getUser().getId().equals(user.getId())) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }

        existingPlaylist.setName(playlist.getName());
        existingPlaylist.setDescription(playlist.getDescription());
        existingPlaylist.setIsPublic(playlist.getIsPublic());
        
        Playlist updatedPlaylist = playlistService.updatePlaylist(existingPlaylist);
        return ResponseEntity.ok(updatedPlaylist);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletePlaylist(@PathVariable Long id, @AuthenticationPrincipal User user) {
        Optional<Playlist> existingPlaylistOpt = playlistService.getPlaylistById(id);
        if (existingPlaylistOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Playlist existingPlaylist = existingPlaylistOpt.get();
        if (!existingPlaylist.getUser().getId().equals(user.getId())) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }

        playlistService.deletePlaylist(id);
        return ResponseEntity.noContent().build();
    }

    // 添加音乐到歌单
    @PostMapping("/{id}/music")
    public ResponseEntity<Void> addMusicToPlaylist(@PathVariable Long id, @RequestBody MusicRequest musicRequest, @AuthenticationPrincipal User user) {
        Optional<Playlist> existingPlaylistOpt = playlistService.getPlaylistById(id);
        if (existingPlaylistOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Playlist existingPlaylist = existingPlaylistOpt.get();
        if (!existingPlaylist.getUser().getId().equals(user.getId())) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }

        Optional<Music> musicOpt = musicService.getMusicById(musicRequest.getMusicId());
        if (musicOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        playlistService.addMusicToPlaylist(id, musicRequest.getMusicId(), musicOpt.get());
        return ResponseEntity.ok().build();
    }

    // 从歌单中移除音乐
    @DeleteMapping("/{id}/music/{musicId}")
    public ResponseEntity<Void> removeMusicFromPlaylist(@PathVariable Long id, @PathVariable Long musicId, @AuthenticationPrincipal User user) {
        Optional<Playlist> existingPlaylistOpt = playlistService.getPlaylistById(id);
        if (existingPlaylistOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Playlist existingPlaylist = existingPlaylistOpt.get();
        if (!existingPlaylist.getUser().getId().equals(user.getId())) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }

        playlistService.removeMusicFromPlaylist(id, musicId);
        return ResponseEntity.ok().build();
    }

    // 获取歌单中的音乐列表
    @GetMapping("/{id}/music")
    public ResponseEntity<List<Music>> getMusicInPlaylist(@PathVariable Long id) {
        Optional<Playlist> existingPlaylistOpt = playlistService.getPlaylistById(id);
        if (existingPlaylistOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        List<Music> musicList = playlistService.getMusicInPlaylist(id);
        return ResponseEntity.ok(musicList);
    }

    // 更新歌单封面
    @PutMapping("/{id}/cover")
    public ResponseEntity<Playlist> updatePlaylistCover(@PathVariable Long id, @RequestBody CoverUpdateRequest coverUpdateRequest, @AuthenticationPrincipal User user) {
        Optional<Playlist> existingPlaylistOpt = playlistService.getPlaylistById(id);
        if (existingPlaylistOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Playlist existingPlaylist = existingPlaylistOpt.get();
        if (!existingPlaylist.getUser().getId().equals(user.getId())) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }

        Playlist updatedPlaylist = playlistService.updatePlaylistCover(id, coverUpdateRequest.getCoverPath());
        return ResponseEntity.ok(updatedPlaylist);
    }

    // 内部静态类用于接收请求参数
    static class MusicRequest {
        private Long musicId;

        public Long getMusicId() {
            return musicId;
        }

        public void setMusicId(Long musicId) {
            this.musicId = musicId;
        }
    }

    static class CoverUpdateRequest {
        private String coverPath;

        public String getCoverPath() {
            return coverPath;
        }

        public void setCoverPath(String coverPath) {
            this.coverPath = coverPath;
        }
    }
}
