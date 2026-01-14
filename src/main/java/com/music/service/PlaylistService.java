package com.music.service;

import com.music.entity.Music;
import com.music.entity.Playlist;
import com.music.entity.User;
import com.music.repository.PlaylistRepository;
import com.music.dto.PlaylistDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@Transactional
public class PlaylistService {
    @Autowired
    private PlaylistRepository playlistRepository;

    public Playlist createPlaylist(Playlist playlist) {
        return playlistRepository.save(playlist);
    }

    public List<Playlist> getMyPlaylists(Long userId) {
        return playlistRepository.findByUserId(userId);
    }

    public List<Playlist> getPublicPlaylists() {
        return playlistRepository.findByIsPublicTrue();
    }

    public Optional<Playlist> getPlaylistById(Long id) {
        return playlistRepository.findById(id);
    }

    public void deletePlaylist(Long id) {
        playlistRepository.deleteById(id);
    }

    public Playlist updatePlaylist(Playlist playlist) {
        return playlistRepository.save(playlist);
    }

    public List<PlaylistDTO> getMyPlaylistsDTO(Long userId) {
        return getMyPlaylists(userId).stream()
                .map(PlaylistDTO::fromPlaylist)
                .collect(Collectors.toList());
    }

    public List<PlaylistDTO> getPublicPlaylistsDTO() {
        return getPublicPlaylists().stream()
                .map(PlaylistDTO::fromPlaylist)
                .collect(Collectors.toList());
    }

    // 添加音乐到歌单
    public void addMusicToPlaylist(Long playlistId, Long musicId, Music music) {
        Playlist playlist = playlistRepository.findById(playlistId)
                .orElseThrow(() -> new RuntimeException("Playlist not found"));
        
        playlist.getMusicList().add(music);
        playlistRepository.save(playlist);
    }

    // 从歌单中移除音乐
    public void removeMusicFromPlaylist(Long playlistId, Long musicId) {
        Playlist playlist = playlistRepository.findById(playlistId)
                .orElseThrow(() -> new RuntimeException("Playlist not found"));
        
        playlist.getMusicList().removeIf(music -> music.getId().equals(musicId));
        playlistRepository.save(playlist);
    }

    // 获取歌单中的音乐列表
    public List<Music> getMusicInPlaylist(Long playlistId) {
        Playlist playlist = playlistRepository.findById(playlistId)
                .orElseThrow(() -> new RuntimeException("Playlist not found"));
        
        return playlist.getMusicList();
    }

    // 更新歌单封面
    public Playlist updatePlaylistCover(Long playlistId, String coverPath) {
        Playlist playlist = playlistRepository.findById(playlistId)
                .orElseThrow(() -> new RuntimeException("Playlist not found"));
        
        playlist.setCoverPath(coverPath);
        return playlistRepository.save(playlist);
    }

    // 增加歌单播放次数
    public void incrementPlayCount(Long playlistId) {
        Playlist playlist = playlistRepository.findById(playlistId)
                .orElseThrow(() -> new RuntimeException("Playlist not found"));
        
        playlist.setPlayCount(playlist.getPlayCount() + 1);
        playlistRepository.save(playlist);
    }
}
