package com.music.service;

import com.music.entity.Music;
import com.music.repository.MusicRepository;
import com.music.repository.PlayRecordRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class RecommendationService {

    @Autowired
    private PlayRecordRepository playRecordRepository;

    @Autowired
    private MusicRepository musicRepository;

    @Cacheable(value = "recommendations", key = "#userId")
    public List<Music> getRecommendations(Long userId) {
        // Hybrid Recommendation System: Combining Content-Based and Collaborative Filtering
        
        // 1. Content-Based Filtering (based on user's favorite genres)
        List<Music> contentBased = getContentBasedRecommendations(userId);
        
        // 2. Collaborative Filtering (simulated user-based recommendation)
        List<Music> collaborative = getCollaborativeFilteringRecommendations(userId);
        
        // 3. Combine and shuffle results
        Set<Music> combined = new HashSet<>();
        if (contentBased != null) combined.addAll(contentBased);
        if (collaborative != null) combined.addAll(collaborative);
        
        List<Music> result = new ArrayList<>(combined);
        Collections.shuffle(result);
        return result.stream().limit(20).collect(Collectors.toList());
    }

    /**
     * Content-Based Filtering: Recommends music similar to what the user likes (genre-based).
     */
    private List<Music> getContentBasedRecommendations(Long userId) {
        try {
            List<Object[]> genreStats = playRecordRepository.findFavoriteGenresByUserId(userId);
            
            if (genreStats.isEmpty()) {
                return getPopularMusic();
            }

            // Get top genre
            String topGenre = (String) genreStats.get(0)[0];
            
            if (topGenre != null) {
                List<Music> recommendations = musicRepository.findByGenreAndStatus(topGenre, 1);
                Collections.shuffle(recommendations);
                return recommendations.stream().limit(10).collect(Collectors.toList());
            }
        } catch (Exception e) {
            System.err.println("Error in Content-Based Filtering: " + e.getMessage());
        }
        return new ArrayList<>();
    }

    /**
     * Collaborative Filtering: Recommends music liked by similar users.
     * (Simulated implementation for demonstration)
     */
    private List<Music> getCollaborativeFilteringRecommendations(Long userId) {
        // In a full implementation, this would:
        // 1. Compute user similarity matrix (e.g., Cosine Similarity or Pearson Correlation)
        // 2. Find top K similar users (Neighbors)
        // 3. Recommend items liked by neighbors but not yet seen by the active user
        
        // Simulation: Randomly select high-quality music to mimic "discovery"
        List<Music> allMusic = musicRepository.findAll();
        Collections.shuffle(allMusic);
        return allMusic.stream()
                .filter(m -> m.getStatus() != null && m.getStatus() == 1)
                .limit(10)
                .collect(Collectors.toList());
    }

    private List<Music> getPopularMusic() {
        return musicRepository.findAll(Sort.by(Sort.Direction.DESC, "playCount"))
                .stream()
                .filter(m -> m.getStatus() != null && m.getStatus() == 1)
                .limit(20)
                .collect(Collectors.toList());
    }
}
