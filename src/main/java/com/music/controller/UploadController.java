package com.music.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/upload")
public class UploadController {

    @Value("${file.upload.image.path}")
    private String imageUploadPath;

    @Value("${file.upload.video.path}")
    private String videoUploadPath;

    @Value("${file.access.image.url}")
    private String imageAccessUrl;

    @Value("${file.access.video.url}")
    private String videoAccessUrl;

    // 上传图片
    @PostMapping("/images")
    public ResponseEntity<List<String>> uploadImages(@RequestParam("files") MultipartFile[] files) throws IOException {
        List<String> imageUrls = new ArrayList<>();
        
        for (MultipartFile file : files) {
            if (!file.isEmpty()) {
                String imageUrl = saveFile(file, imageUploadPath, imageAccessUrl);
                imageUrls.add(imageUrl);
            }
        }
        
        return new ResponseEntity<>(imageUrls, HttpStatus.OK);
    }

    // 上传视频
    @PostMapping("/video")
    public ResponseEntity<String> uploadVideo(@RequestParam("file") MultipartFile file) throws IOException {
        if (file.isEmpty()) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
        
        String videoUrl = saveFile(file, videoUploadPath, videoAccessUrl);
        return new ResponseEntity<>(videoUrl, HttpStatus.OK);
    }

    // 保存文件到本地并返回访问URL
    private String saveFile(MultipartFile file, String uploadPath, String accessUrl) throws IOException {
        // 确保上传目录存在
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        // 生成唯一的文件名
        String originalFilename = file.getOriginalFilename();
        String extension = originalFilename != null ? originalFilename.substring(originalFilename.lastIndexOf(".")) : ".jpg";
        String uniqueFilename = UUID.randomUUID().toString() + extension;

        // 保存文件
        Path filePath = Paths.get(uploadPath, uniqueFilename);
        Files.write(filePath, file.getBytes());

        // 返回文件访问URL
        return accessUrl + uniqueFilename;
    }
}