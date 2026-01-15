-- 创建数据库
CREATE DATABASE IF NOT EXISTS music_platform DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE music_platform;

-- 角色表
CREATE TABLE IF NOT EXISTS `role` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL UNIQUE COMMENT '角色名称',
    `description` VARCHAR(200) COMMENT '角色描述',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_name (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色表';

-- 插入默认角色
INSERT IGNORE INTO `role` (`name`, `description`) VALUES 
    ('ROLE_USER', '普通用户'),
    ('ROLE_MUSICIAN', '音乐人'),
    ('ROLE_ADMIN', '管理员');

-- 用户表
CREATE TABLE IF NOT EXISTS `user` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `username` VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名',
    `password` VARCHAR(100) NOT NULL COMMENT '密码',
    `nickname` VARCHAR(50) COMMENT '昵称',
    `avatar` VARCHAR(200) COMMENT '头像',
    `email` VARCHAR(100) COMMENT '邮箱',
    `phone` VARCHAR(20) COMMENT '手机号',
    `gender` TINYINT COMMENT '性别(0:未知,1:男,2:女)',
    `birthday` DATE COMMENT '生日',
    `introduction` TEXT COMMENT '个人简介',
    `location` VARCHAR(100) COMMENT '所在地',
    `register_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
    `last_login_time` DATETIME COMMENT '最后登录时间',
    `status` TINYINT DEFAULT 1 COMMENT '状态(0:禁用,1:启用)',
    `is_musician` TINYINT DEFAULT 0 COMMENT '是否为音乐人(0:否,1:是)',
    `musician_id` BIGINT COMMENT '音乐人ID(关联musician表)',
    INDEX idx_username (`username`),
    INDEX idx_email (`email`),
    INDEX idx_phone (`phone`),
    INDEX idx_status (`status`),
    INDEX idx_musician_id (`musician_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- 用户角色关联表
CREATE TABLE IF NOT EXISTS `user_role` (
    `user_id` BIGINT NOT NULL,
    `role_id` BIGINT NOT NULL,
    PRIMARY KEY (`user_id`, `role_id`),
    INDEX idx_user_id (`user_id`),
    INDEX idx_role_id (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户角色关联表';

-- 音乐人表
CREATE TABLE IF NOT EXISTS `musician` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `user_id` BIGINT NOT NULL UNIQUE COMMENT '关联用户ID',
    `stage_name` VARCHAR(50) NOT NULL COMMENT '艺名',
    `real_name` VARCHAR(50) COMMENT '真实姓名',
    `id_card` VARCHAR(20) COMMENT '身份证号',
    `company` VARCHAR(100) COMMENT '所属公司',
    `genre` VARCHAR(50) COMMENT '音乐风格',
    `verified` TINYINT DEFAULT 0 COMMENT '是否认证(0:未认证,1:已认证)',
    `follower_count` INT DEFAULT 0 COMMENT '粉丝数',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_stage_name (`stage_name`),
    INDEX idx_user_id (`user_id`),
    INDEX idx_verified (`verified`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='音乐人表';

-- 音乐表
CREATE TABLE IF NOT EXISTS `music` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `title` VARCHAR(100) NOT NULL COMMENT '歌曲标题',
    `artist` VARCHAR(100) NOT NULL COMMENT '歌手',
    `album` VARCHAR(100) COMMENT '专辑',
    `genre` VARCHAR(50) COMMENT '音乐风格',
    `duration` INT NOT NULL COMMENT '时长(秒)',
    `file_path` VARCHAR(200) NOT NULL COMMENT '音乐文件路径',
    `cover_path` VARCHAR(200) COMMENT '封面图片路径',
    `lyric_path` VARCHAR(200) COMMENT '歌词文件路径',
    `description` TEXT COMMENT '歌曲描述',
    `play_count` INT DEFAULT 0 COMMENT '播放量',
    `download_count` INT DEFAULT 0 COMMENT '下载量',
    `comment_count` INT DEFAULT 0 COMMENT '评论数',
    `like_count` INT DEFAULT 0 COMMENT '点赞数',
    `share_count` INT DEFAULT 0 COMMENT '分享数',
    `musician_id` BIGINT NOT NULL COMMENT '所属音乐人',
    `is_original` TINYINT DEFAULT 1 COMMENT '是否原创(0:翻唱,1:原创)',
    `copyright_info` TEXT COMMENT '版权信息',
    `status` TINYINT DEFAULT 0 COMMENT '状态(0:待审核,1:已通过,2:已拒绝)',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_title (`title`),
    INDEX idx_artist (`artist`),
    INDEX idx_genre (`genre`),
    INDEX idx_status (`status`),
    INDEX idx_musician_id (`musician_id`),
    INDEX idx_create_time (`create_time`),
    INDEX idx_play_count (`play_count`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='音乐表';

-- 歌单表
CREATE TABLE IF NOT EXISTS `playlist` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(100) NOT NULL COMMENT '歌单名称',
    `description` TEXT COMMENT '歌单描述',
    `cover_path` VARCHAR(200) COMMENT '封面图片路径',
    `creator_id` BIGINT NOT NULL COMMENT '创建者ID',
    `music_count` INT DEFAULT 0 COMMENT '歌曲数量',
    `play_count` INT DEFAULT 0 COMMENT '播放量',
    `share_count` INT DEFAULT 0 COMMENT '分享数',
    `is_public` TINYINT DEFAULT 1 COMMENT '是否公开(0:私有,1:公开)',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_creator_id (`creator_id`),
    INDEX idx_is_public (`is_public`),
    INDEX idx_create_time (`create_time`),
    INDEX idx_play_count (`play_count`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='歌单表';

-- 歌单歌曲关联表
CREATE TABLE IF NOT EXISTS `playlist_music` (
    `playlist_id` BIGINT NOT NULL,
    `music_id` BIGINT NOT NULL,
    `add_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '添加时间',
    PRIMARY KEY (`playlist_id`, `music_id`),
    INDEX idx_playlist_id (`playlist_id`),
    INDEX idx_music_id (`music_id`),
    INDEX idx_add_time (`add_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='歌单歌曲关联表';

-- 动态表
CREATE TABLE IF NOT EXISTS `posts` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `content` TEXT NOT NULL COMMENT '动态内容',
    `user_id` BIGINT NOT NULL COMMENT '发布用户ID',
    `music_id` BIGINT COMMENT '关联音乐ID',
    `image_urls` TEXT COMMENT '图片URL列表',
    `video_url` VARCHAR(255) COMMENT '视频URL',
    `like_count` INT DEFAULT 0 COMMENT '点赞数',
    `comment_count` INT DEFAULT 0 COMMENT '评论数',
    `share_count` INT DEFAULT 0 COMMENT '分享数',
    `status` INT DEFAULT 1 COMMENT '状态(1:待审核, 2:已通过, 3:未通过)',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user_id (`user_id`),
    INDEX idx_music_id (`music_id`),
    INDEX idx_status (`status`),
    INDEX idx_created_at (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='动态表';

-- 评论表
CREATE TABLE IF NOT EXISTS `comments` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `content` TEXT NOT NULL COMMENT '评论内容',
    `user_id` BIGINT NOT NULL COMMENT '评论用户ID',
    `post_id` BIGINT COMMENT '关联动态ID',
    `music_id` BIGINT COMMENT '关联音乐ID',
    `parent_id` BIGINT DEFAULT NULL COMMENT '父评论ID(用于回复)',
    `like_count` INT DEFAULT 0 COMMENT '点赞数',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user_id (`user_id`),
    INDEX idx_post_id (`post_id`),
    INDEX idx_music_id (`music_id`),
    INDEX idx_parent_id (`parent_id`),
    INDEX idx_created_at (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='评论表';

-- 动态点赞表
CREATE TABLE IF NOT EXISTS `post_likes` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `user_id` BIGINT NOT NULL,
    `post_id` BIGINT NOT NULL,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY `uk_user_post` (`user_id`, `post_id`),
    INDEX idx_user_id (`user_id`),
    INDEX idx_post_id (`post_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='动态点赞表';

-- 评论点赞表
CREATE TABLE IF NOT EXISTS `comment_likes` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `user_id` BIGINT NOT NULL,
    `comment_id` BIGINT NOT NULL,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY `uk_user_comment` (`user_id`, `comment_id`),
    INDEX idx_user_id (`user_id`),
    INDEX idx_comment_id (`comment_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='评论点赞表';

-- 音乐点赞表
CREATE TABLE IF NOT EXISTS `music_likes` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `user_id` BIGINT NOT NULL,
    `music_id` BIGINT NOT NULL,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY `uk_user_music_like` (`user_id`, `music_id`),
    INDEX idx_user_id (`user_id`),
    INDEX idx_music_id (`music_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='音乐点赞表';

-- 关注表
CREATE TABLE IF NOT EXISTS `follow` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `follower_id` BIGINT NOT NULL COMMENT '粉丝ID',
    `following_id` BIGINT NOT NULL COMMENT '被关注者ID',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY `uk_follower_following` (`follower_id`, `following_id`),
    INDEX idx_follower_id (`follower_id`),
    INDEX idx_following_id (`following_id`),
    INDEX idx_create_time (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='关注表';

-- 收藏表
CREATE TABLE IF NOT EXISTS `collection` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `user_id` BIGINT NOT NULL COMMENT '收藏用户ID',
    `music_id` BIGINT NOT NULL COMMENT '收藏的音乐ID',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY `uk_user_music` (`user_id`, `music_id`),
    INDEX idx_user_id (`user_id`),
    INDEX idx_music_id (`music_id`),
    INDEX idx_create_time (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='收藏表';

-- 播放记录表
CREATE TABLE IF NOT EXISTS `play_record` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `music_id` BIGINT NOT NULL COMMENT '音乐ID',
    `play_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '播放时间',
    `play_duration` INT COMMENT '播放时长(秒)',
    INDEX idx_user_id (`user_id`),
    INDEX idx_music_id (`music_id`),
    INDEX idx_play_time (`play_time`),
    INDEX idx_user_play_time (`user_id`, `play_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='播放记录表';