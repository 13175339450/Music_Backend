package com.music.service;

import com.music.entity.Music;
import com.music.repository.MusicRepository;
import com.music.util.FileUploadUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.Optional;

@Service
public class MusicService {
    @Autowired
    private MusicRepository musicRepository;

    @Autowired
    private FileUploadUtil fileUploadUtil;

    // 上传音乐
    @CacheEvict(value = "musicList", allEntries = true)
    public Music uploadMusic(Music music, MultipartFile musicFile, MultipartFile coverFile) throws IOException {
        // 上传音乐文件
        String musicFilePath = fileUploadUtil.uploadMusicFile(musicFile);
        music.setFilePath(musicFilePath);

        // 上传封面文件
        if (coverFile != null && !coverFile.isEmpty()) {
            String coverFilePath = fileUploadUtil.uploadCoverFile(coverFile);
            music.setCoverPath(coverFilePath);
        }

        // 设置默认值
        music.setPlayCount(0);
        music.setDownloadCount(0);
        music.setCommentCount(0);
        music.setLikeCount(0);
        music.setShareCount(0);
        music.setStatus(0); // 待审核

        return musicRepository.save(music);
    }

    // 获取音乐列表
    public List<Music> getMusicList() {
        return musicRepository.findByStatus(1); // 只返回已审核通过的音乐
    }

    // 根据ID获取音乐
    @Cacheable(value = "music", key = "#id")
    public Optional<Music> getMusicById(Long id) {
        return musicRepository.findById(id);
    }

    // 根据关键词搜索音乐
    @Cacheable(value = "musicSearch", key = "#keyword")
    public List<Music> searchMusic(String keyword) {
        return musicRepository.findByTitleOrArtistContainingAndStatus(keyword, 1);
    }

    // 根据艺术家搜索音乐
    @Cacheable(value = "musicByArtist", key = "#artist")
    public List<Music> getMusicByArtist(String artist) {
        return musicRepository.findByArtistContainingAndStatus(artist, 1);
    }

    // 根据风格搜索音乐
    @Cacheable(value = "musicByGenre", key = "#genre")
    public List<Music> getMusicByGenre(String genre) {
        return musicRepository.findByGenreAndStatus(genre, 1);
    }

    // 根据音乐人ID获取音乐
    public List<Music> getMusicByMusicianId(Long musicianId) {
        return musicRepository.findByMusicianId(musicianId);
    }

    // 更新音乐播放量
    public void updatePlayCount(Long musicId) {
        Optional<Music> optionalMusic = musicRepository.findById(musicId);
        if (optionalMusic.isPresent()) {
            Music music = optionalMusic.get();
            music.setPlayCount(music.getPlayCount() + 1);
            musicRepository.save(music);
        }
    }

    // 更新音乐下载量
    public void updateDownloadCount(Long musicId) {
        Optional<Music> optionalMusic = musicRepository.findById(musicId);
        if (optionalMusic.isPresent()) {
            Music music = optionalMusic.get();
            music.setDownloadCount(music.getDownloadCount() + 1);
            musicRepository.save(music);
        }
    }

    // 获取音乐文件
    public File getMusicFile(String filePath) {
        return new File(fileUploadUtil.getMusicFilePath(filePath));
    }

    // 获取封面文件
    public File getCoverFile(String coverPath) {
        return new File(fileUploadUtil.getCoverFilePath(coverPath));
    }

    // 删除音乐
    @CacheEvict(value = {"music", "musicList", "musicSearch", "musicByArtist", "musicByGenre"}, allEntries = true)
    public boolean deleteMusic(Long musicId) {
        Optional<Music> optionalMusic = musicRepository.findById(musicId);
        if (optionalMusic.isPresent()) {
            Music music = optionalMusic.get();
            // 删除文件
            fileUploadUtil.deleteMusicFile(music.getFilePath());
            if (music.getCoverPath() != null) {
                fileUploadUtil.deleteCoverFile(music.getCoverPath());
            }
            // 删除数据库记录
            musicRepository.delete(music);
            return true;
        }
        return false;
    }

    // 更新音乐信息
    public Music updateMusic(Music music) {
        return musicRepository.save(music);
    }

    // 审核音乐（通过）
    public Music approveMusic(Long musicId) {
        Music music = musicRepository.findById(musicId)
                .orElseThrow(() -> new IllegalArgumentException("Music not found"));
        music.setStatus(1); // 1: 已通过
        return musicRepository.save(music);
    }

    // 审核音乐（拒绝）
    public Music rejectMusic(Long musicId) {
        Music music = musicRepository.findById(musicId)
                .orElseThrow(() -> new IllegalArgumentException("Music not found"));
        music.setStatus(2); // 2: 已拒绝
        return musicRepository.save(music);
    }
}