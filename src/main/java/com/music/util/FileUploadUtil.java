package com.music.util;

import org.apache.commons.io.FilenameUtils;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.util.UUID;

@Component
public class FileUploadUtil {
    @Value("${file.upload.music.path}")
    private String musicUploadPath;

    @Value("${file.upload.avatar.path}")
    private String avatarUploadPath;

    @Value("${file.upload.cover.path}")
    private String coverUploadPath;

    @Value("${file.upload.image.path}")
    private String imageUploadPath;

    @Value("${file.upload.video.path}")
    private String videoUploadPath;

    // 上传音乐文件
    public String uploadMusicFile(MultipartFile file) throws IOException {
        return uploadFile(file, musicUploadPath);
    }

    // 上传封面图片
    public String uploadCoverFile(MultipartFile file) throws IOException {
        return uploadFile(file, coverUploadPath);
    }

    // 上传动态图片
    public String uploadImageFile(MultipartFile file) throws IOException {
        return uploadFile(file, imageUploadPath);
    }

    // 上传动态视频
    public String uploadVideoFile(MultipartFile file) throws IOException {
        return uploadFile(file, videoUploadPath);
    }

    // 上传通用文件
    public String uploadFile(MultipartFile file, String uploadPath) throws IOException {
        // 检查目录是否存在，不存在则创建
        File directory = new File(uploadPath);
        if (!directory.exists()) {
            directory.mkdirs();
        }

        // 生成唯一文件名
        String originalFilename = file.getOriginalFilename();
        String extension = FilenameUtils.getExtension(originalFilename);
        String uniqueFilename = UUID.randomUUID().toString() + "." + extension;

        // 保存文件
        File dest = new File(uploadPath + uniqueFilename);
        file.transferTo(dest);

        // 返回文件路径
        return uniqueFilename;
    }

    // 删除文件
    public boolean deleteFile(String filePath, String basePath) {
        File file = new File(basePath + filePath);
        return file.exists() && file.delete();
    }

    // 删除音乐文件
    public boolean deleteMusicFile(String filePath) {
        return deleteFile(filePath, musicUploadPath);
    }

    // 删除封面文件
    public boolean deleteCoverFile(String filePath) {
        return deleteFile(filePath, coverUploadPath);
    }

    // 删除动态图片
    public boolean deleteImageFile(String filePath) {
        return deleteFile(filePath, imageUploadPath);
    }

    // 删除动态视频
    public boolean deleteVideoFile(String filePath) {
        return deleteFile(filePath, videoUploadPath);
    }

    // 获取文件存储路径
    public String getMusicFilePath(String filename) {
        return musicUploadPath + filename;
    }

    public String getCoverFilePath(String filename) {
        return coverUploadPath + filename;
    }

    public String getImageFilePath(String filename) {
        return imageUploadPath + filename;
    }

    public String getVideoFilePath(String filename) {
        return videoUploadPath + filename;
    }
}