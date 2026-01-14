package com.music.config;

import com.music.entity.Music;
import com.music.entity.User;
import com.music.repository.MusicRepository;
import com.music.repository.UserRepository;
import com.music.util.FileUploadUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

@Component
public class ImportLocalMusicRunner implements CommandLineRunner {

    @Autowired
    private MusicRepository musicRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private FileUploadUtil fileUploadUtil;

    @Override
    public void run(String... args) throws Exception {
        File marker = new File("f:/music-upload/imported.marker");
        if (marker.exists()) {
            return;
        }
        File sourceDir = new File("f:/JavaBiShe/Design and Implementation of  Socialized Music Platform/音乐");
        if (!sourceDir.exists() || !sourceDir.isDirectory()) {
            return;
        }
        User admin = userRepository.findByUsername("admin").orElse(null);
        Long musicianId = admin != null ? admin.getId() : 1L;
        int imported = 0;
        for (File src : sourceDir.listFiles()) {
            if (src.isFile() && src.getName().toLowerCase().endsWith(".mp3")) {
                String originalName = src.getName();
                String baseName = originalName.substring(0, originalName.lastIndexOf('.'));
                String title = baseName;
                String artist = "未知";
                if (baseName.contains("-")) {
                    String[] parts = baseName.split("-");
                    if (parts.length >= 2) {
                        title = parts[0].trim();
                        artist = parts[1].trim();
                    }
                }
                String filename = UUID.randomUUID().toString() + ".mp3";
                File dest = new File(fileUploadUtil.getMusicFilePath(filename));
                dest.getParentFile().mkdirs();
                Files.copy(src.toPath(), dest.toPath(), StandardCopyOption.REPLACE_EXISTING);
                Music music = new Music();
                music.setTitle(title);
                music.setArtist(artist);
                music.setDuration(240);
                music.setFilePath(filename);
                music.setDescription("本地导入");
                music.setPlayCount(0);
                music.setDownloadCount(0);
                music.setCommentCount(0);
                music.setLikeCount(0);
                music.setShareCount(0);
                music.setMusicianId(musicianId);
                music.setIsOriginal(0);
                music.setStatus(1);
                musicRepository.save(music);
                imported++;
            }
        }
        marker.getParentFile().mkdirs();
        Files.writeString(marker.toPath(), "imported=" + imported);
    }
}
