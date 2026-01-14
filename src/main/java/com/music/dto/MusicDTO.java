package com.music.dto;

import com.music.entity.Music;

public class MusicDTO {
    private Long id;
    private String title;
    private String artist;
    private String album;
    private String coverUrl;
    private String audioUrl;

    // 从Music实体转换为DTO的方法
    public static MusicDTO fromMusic(Music music) {
        MusicDTO dto = new MusicDTO();
        dto.setId(music.getId());
        dto.setTitle(music.getTitle());
        dto.setArtist(music.getArtist());
        dto.setAlbum(music.getAlbum());
        dto.setCoverUrl(music.getCoverPath());
        dto.setAudioUrl(music.getFilePath());
        return dto;
    }

    // 手动实现getter/setter方法
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getArtist() {
        return artist;
    }

    public void setArtist(String artist) {
        this.artist = artist;
    }

    public String getAlbum() {
        return album;
    }

    public void setAlbum(String album) {
        this.album = album;
    }

    public String getCoverUrl() {
        return coverUrl;
    }

    public void setCoverUrl(String coverUrl) {
        this.coverUrl = coverUrl;
    }

    public String getAudioUrl() {
        return audioUrl;
    }

    public void setAudioUrl(String audioUrl) {
        this.audioUrl = audioUrl;
    }
}