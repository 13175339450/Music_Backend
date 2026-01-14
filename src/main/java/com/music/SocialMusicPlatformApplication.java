package com.music;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@SpringBootApplication
@EnableJpaRepositories(basePackages = "com.music.repository")
@EntityScan(basePackages = "com.music.entity")
public class SocialMusicPlatformApplication {
    public static void main(String[] args) {
        SpringApplication.run(SocialMusicPlatformApplication.class, args);
    }
}