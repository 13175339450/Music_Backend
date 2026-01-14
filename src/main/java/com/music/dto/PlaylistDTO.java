package com.music.dto;

import com.music.entity.Playlist;

public class PlaylistDTO {
    private Long id;
    private String name;
    private String description;
    private String coverPath;
    private Integer playCount;
    private Boolean isPublic;
    private Integer musicCount;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getCoverPath() {
        return coverPath;
    }

    public void setCoverPath(String coverPath) {
        this.coverPath = coverPath;
    }

    public Integer getPlayCount() {
        return playCount;
    }

    public void setPlayCount(Integer playCount) {
        this.playCount = playCount;
    }

    public Boolean getIsPublic() {
        return isPublic;
    }

    public void setIsPublic(Boolean isPublic) {
        this.isPublic = isPublic;
    }

    public Integer getMusicCount() {
        return musicCount;
    }

    public void setMusicCount(Integer musicCount) {
        this.musicCount = musicCount;
    }

    public static PlaylistDTO fromPlaylist(Playlist playlist) {
        PlaylistDTO dto = new PlaylistDTO();
        dto.setId(playlist.getId());
        dto.setName(playlist.getName());
        dto.setDescription(playlist.getDescription());
        dto.setCoverPath(playlist.getCoverPath());
        dto.setPlayCount(playlist.getPlayCount());
        dto.setIsPublic(playlist.getIsPublic());
        dto.setMusicCount(playlist.getMusicList() == null ? 0 : playlist.getMusicList().size());
        return dto;
    }
}
