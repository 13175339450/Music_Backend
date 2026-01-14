package com.music.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Value("${file.upload.image.path}")
    private String imageUploadPath;

    @Value("${file.upload.video.path}")
    private String videoUploadPath;

    @Value("${file.upload.cover.path}")
    private String coverUploadPath;

    @Value("${file.upload.avatar.path}")
    private String avatarUploadPath;

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // 配置图片资源访问路径
        registry.addResourceHandler("/files/image/**")
                .addResourceLocations("file:" + imageUploadPath);

        // 配置视频资源访问路径
        registry.addResourceHandler("/files/video/**")
                .addResourceLocations("file:" + videoUploadPath);

        // 配置封面资源访问路径
        registry.addResourceHandler("/files/cover/**")
                .addResourceLocations("file:" + coverUploadPath);

        // 配置头像资源访问路径
        registry.addResourceHandler("/files/avatar/**")
                .addResourceLocations("file:" + avatarUploadPath);
    }
}
