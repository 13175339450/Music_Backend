package com.music.dto;

import com.music.entity.Post;

public class PostDTO {
    private Long id;
    private String content;
    private UserDTO user;
    private String imageUrls;
    private String createdAt;
    private String updatedAt;
    private int likeCount;
    private int commentCount;
    private int shareCount;
    private Integer status; // 1: 待审核, 2: 已通过, 3: 未通过
    private boolean isLiked; // 当前用户是否点赞

    // 从Post实体转换为DTO的方法
    public static PostDTO fromPost(Post post, boolean isLiked) {
        PostDTO dto = new PostDTO();
        dto.setId(post.getId());
        dto.setContent(post.getContent());
        dto.setUser(UserDTO.fromUser(post.getUser()));
        
        dto.setImageUrls(post.getImageUrls());
        dto.setCreatedAt(post.getCreatedAt().toString());
        dto.setUpdatedAt(post.getUpdatedAt().toString());
        dto.setLikeCount(post.getLikeCount());
        dto.setCommentCount(post.getCommentCount());
        dto.setShareCount(post.getShareCount());
        dto.setStatus(post.getStatus());
        dto.setLiked(isLiked);
        
        return dto;
    }
    
    // 手动实现getter/setter方法
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

    public UserDTO getUser() {
        return user;
    }

    public void setUser(UserDTO user) {
        this.user = user;
    }

    public String getImageUrls() {
        return imageUrls;
    }

    public void setImageUrls(String imageUrls) {
        this.imageUrls = imageUrls;
    }

    public String getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }

    public String getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(String updatedAt) {
        this.updatedAt = updatedAt;
    }

    public int getLikeCount() {
        return likeCount;
    }

    public void setLikeCount(int likeCount) {
        this.likeCount = likeCount;
    }

    public int getCommentCount() {
        return commentCount;
    }

    public void setCommentCount(int commentCount) {
        this.commentCount = commentCount;
    }

    public int getShareCount() {
        return shareCount;
    }

    public void setShareCount(int shareCount) {
        this.shareCount = shareCount;
    }

    public Integer getStatus() {
        return status;
    }

    public void setStatus(Integer status) {
        this.status = status;
    }

    public boolean isLiked() {
        return isLiked;
    }

    public void setLiked(boolean liked) {
        isLiked = liked;
    }
}