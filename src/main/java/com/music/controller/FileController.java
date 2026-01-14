package com.music.controller;

import com.music.util.FileUploadUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/files")
public class FileController {

    @Autowired
    private FileUploadUtil fileUploadUtil;

    // 上传图片
    @PostMapping("/upload/image")
    public ResponseEntity<Map<String, String>> uploadImage(@RequestParam("file") MultipartFile file) {
        Map<String, String> response = new HashMap<>();
        
        try {
            String fileName = fileUploadUtil.uploadImageFile(file);
            response.put("success", "true");
            response.put("message", "图片上传成功");
            response.put("url", "/api/files/image/" + fileName);
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (IOException e) {
            response.put("success", "false");
            response.put("message", "图片上传失败: " + e.getMessage());
            return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    // 上传视频
    @PostMapping("/upload/video")
    public ResponseEntity<Map<String, String>> uploadVideo(@RequestParam("file") MultipartFile file) {
        Map<String, String> response = new HashMap<>();
        
        try {
            String fileName = fileUploadUtil.uploadVideoFile(file);
            response.put("success", "true");
            response.put("message", "视频上传成功");
            response.put("url", "/files/video/" + fileName);
            return new ResponseEntity<>(response, HttpStatus.OK);
        } catch (IOException e) {
            response.put("success", "false");
            response.put("message", "视频上传失败: " + e.getMessage());
            return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    // 获取图片
    @org.springframework.web.bind.annotation.GetMapping("/image/{filename}")
    public org.springframework.http.ResponseEntity<org.springframework.core.io.Resource> getImage(@org.springframework.web.bind.annotation.PathVariable String filename) {
        try {
            java.io.File file = new java.io.File(fileUploadUtil.getImageFilePath(filename));
            if (!file.exists()) {
                return org.springframework.http.ResponseEntity.notFound().build();
            }
            
            org.springframework.core.io.Resource resource = new org.springframework.core.io.FileSystemResource(file);
            return org.springframework.http.ResponseEntity.ok()
                    .contentType(org.springframework.http.MediaType.IMAGE_JPEG)
                    .body(resource);
        } catch (Exception e) {
            return org.springframework.http.ResponseEntity.internalServerError().build();
        }
    }

    // 获取视频
    @org.springframework.web.bind.annotation.GetMapping("/video/{filename}")
    public org.springframework.http.ResponseEntity<org.springframework.core.io.Resource> getVideo(@org.springframework.web.bind.annotation.PathVariable String filename) {
        try {
            java.io.File file = new java.io.File(fileUploadUtil.getVideoFilePath(filename));
            if (!file.exists()) {
                return org.springframework.http.ResponseEntity.notFound().build();
            }
            
            org.springframework.core.io.Resource resource = new org.springframework.core.io.FileSystemResource(file);
            return org.springframework.http.ResponseEntity.ok()
                    .contentType(org.springframework.http.MediaType.parseMediaType("video/mp4"))
                    .body(resource);
        } catch (Exception e) {
            return org.springframework.http.ResponseEntity.internalServerError().build();
        }
    }
}
