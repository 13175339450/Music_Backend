package com.music.dto;

import com.music.entity.Comment;
import com.music.dto.UserDTO;
import com.fasterxml.jackson.annotation.JsonFormat;

import java.time.LocalDateTime;

public class CommentDTO {
    private Long id;
    private String content;
    private int likeCount;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;
    
    private UserDTO user;
    private MusicDTO music;
    private java.util.List<CommentDTO> replies;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public int getLikeCount() {
        return likeCount;
    }

    public void setLikeCount(int likeCount) {
        this.likeCount = likeCount;
    }

    public LocalDateTime getCreateTime() {
        return createTime;
    }

    public void setCreateTime(LocalDateTime createTime) {
        this.createTime = createTime;
    }

    public UserDTO getUser() {
        return user;
    }

    public void setUser(UserDTO user) {
        this.user = user;
    }

    public MusicDTO getMusic() {
        return music;
    }

    public void setMusic(MusicDTO music) {
        this.music = music;
    }

    public java.util.List<CommentDTO> getReplies() {
        return replies;
    }

    public void setReplies(java.util.List<CommentDTO> replies) {
        this.replies = replies;
    }

    public static CommentDTO fromComment(Comment comment) {
        CommentDTO dto = new CommentDTO();
        dto.setId(comment.getId());
        dto.setContent(comment.getContent());
        dto.setLikeCount(comment.getLikeCount());
        dto.setCreateTime(comment.getCreatedAt());
        dto.setUser(UserDTO.fromUser(comment.getUser()));
        if (comment.getMusic() != null) {
            dto.setMusic(MusicDTO.fromMusic(comment.getMusic()));
        }
        
        if (comment.getReplies() != null && !comment.getReplies().isEmpty()) {
            dto.setReplies(comment.getReplies().stream()
                .map(CommentDTO::fromComment)
                .collect(java.util.stream.Collectors.toList()));
        }
        
        return dto;
    }
}
