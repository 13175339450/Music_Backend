-- =============================================
-- 音乐社交平台数据库优化版本
-- 针对查询性能进行了全面优化
-- =============================================

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

-- 用户表 - 优化索引
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
    
    -- 优化索引
    UNIQUE KEY `uk_username` (`username`),
    UNIQUE KEY `uk_email` (`email`),
    UNIQUE KEY `uk_phone` (`phone`),
    INDEX idx_username_password (`username`, `password`), -- 登录查询优化
    INDEX idx_email_status (`email`, `status`),
    INDEX idx_phone_status (`phone`, `status`),
    INDEX idx_status_register_time (`status`, `register_time`), -- 用户列表查询优化
    INDEX idx_is_musician_status (`is_musician`, `status`),
    INDEX idx_location (`location`),
    INDEX idx_register_time (`register_time`),
    INDEX idx_last_login_time (`last_login_time`),
    INDEX idx_musician_id (`musician_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- 用户角色关联表
CREATE TABLE IF NOT EXISTS `user_role` (
    `user_id` BIGINT NOT NULL,
    `role_id` BIGINT NOT NULL,
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`user_id`, `role_id`),
    INDEX idx_user_id (`user_id`),
    INDEX idx_role_id (`role_id`),
    INDEX idx_create_time (`create_time`),
    
    -- 外键约束
    CONSTRAINT `fk_user_role_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_user_role_role` FOREIGN KEY (`role_id`) REFERENCES `role` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户角色关联表';

-- 音乐人表 - 优化索引
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
    
    -- 优化索引
    UNIQUE KEY `uk_user_id` (`user_id`),
    UNIQUE KEY `uk_id_card` (`id_card`),
    INDEX idx_stage_name (`stage_name`),
    INDEX idx_verified_follower_count (`verified`, `follower_count`), -- 热门音乐人查询
    INDEX idx_genre_verified (`genre`, `verified`),
    INDEX idx_create_time (`create_time`),
    INDEX idx_follower_count (`follower_count`),
    
    -- 外键约束
    CONSTRAINT `fk_musician_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='音乐人表';

-- 音乐表 - 优化索引和结构
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
    
    -- 优化索引
    INDEX idx_title_artist (`title`, `artist`), -- 搜索优化
    INDEX idx_artist_genre (`artist`, `genre`),
    INDEX idx_status_create_time (`status`, `create_time`), -- 审核列表查询
    INDEX idx_musician_id_status (`musician_id`, `status`),
    INDEX idx_play_count_create_time (`play_count`, `create_time`), -- 热门歌曲查询
    INDEX idx_like_count_create_time (`like_count`, `create_time`),
    INDEX idx_genre_status (`genre`, `status`),
    INDEX idx_is_original_status (`is_original`, `status`),
    INDEX idx_create_time (`create_time`),
    INDEX idx_update_time (`update_time`),
    
    -- 全文索引（用于搜索）
    FULLTEXT INDEX `ft_music_search` (`title`, `artist`, `album`, `genre`),
    
    -- 外键约束
    CONSTRAINT `fk_music_musician` FOREIGN KEY (`musician_id`) REFERENCES `musician` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='音乐表';

-- 歌单表 - 优化索引
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
    
    -- 优化索引
    INDEX idx_creator_id_is_public (`creator_id`, `is_public`), -- 用户歌单查询
    INDEX idx_is_public_play_count (`is_public`, `play_count`), -- 热门歌单查询
    INDEX idx_is_public_create_time (`is_public`, `create_time`), -- 最新歌单查询
    INDEX idx_music_count (`music_count`),
    INDEX idx_create_time (`create_time`),
    INDEX idx_update_time (`update_time`),
    
    -- 全文索引
    FULLTEXT INDEX `ft_playlist_search` (`name`, `description`),
    
    -- 外键约束
    CONSTRAINT `fk_playlist_user` FOREIGN KEY (`creator_id`) REFERENCES `user` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='歌单表';

-- 歌单歌曲关联表 - 优化索引
CREATE TABLE IF NOT EXISTS `playlist_music` (
    `playlist_id` BIGINT NOT NULL,
    `music_id` BIGINT NOT NULL,
    `add_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '添加时间',
    `sort_order` INT DEFAULT 0 COMMENT '排序顺序',
    PRIMARY KEY (`playlist_id`, `music_id`),
    INDEX idx_playlist_id (`playlist_id`),
    INDEX idx_music_id (`music_id`),
    INDEX idx_add_time (`add_time`),
    INDEX idx_playlist_sort (`playlist_id`, `sort_order`), -- 歌单内歌曲排序
    
    -- 外键约束
    CONSTRAINT `fk_playlist_music_playlist` FOREIGN KEY (`playlist_id`) REFERENCES `playlist` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_playlist_music_music` FOREIGN KEY (`music_id`) REFERENCES `music` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='歌单歌曲关联表';

-- 动态表 - 优化索引
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
    
    -- 优化索引
    INDEX idx_user_id_status (`user_id`, `status`), -- 用户动态查询
    INDEX idx_status_created_at (`status`, `created_at`), -- 动态流查询
    INDEX idx_music_id_status (`music_id`, `status`),
    INDEX idx_like_count_created_at (`like_count`, `created_at`), -- 热门动态
    INDEX idx_comment_count_created_at (`comment_count`, `created_at`),
    INDEX idx_created_at (`created_at`),
    INDEX idx_updated_at (`updated_at`),
    
    -- 全文索引
    FULLTEXT INDEX `ft_posts_content` (`content`),
    
    -- 外键约束
    CONSTRAINT `fk_posts_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_posts_music` FOREIGN KEY (`music_id`) REFERENCES `music` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='动态表';

-- 评论表 - 优化索引
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
    
    -- 优化索引
    INDEX idx_user_id_created_at (`user_id`, `created_at`), -- 用户评论查询
    INDEX idx_post_id_created_at (`post_id`, `created_at`), -- 动态评论查询
    INDEX idx_music_id_created_at (`music_id`, `created_at`), -- 音乐评论查询
    INDEX idx_parent_id_created_at (`parent_id`, `created_at`), -- 回复查询
    INDEX idx_like_count_created_at (`like_count`, `created_at`), -- 热门评论
    INDEX idx_created_at (`created_at`),
    
    -- 全文索引
    FULLTEXT INDEX `ft_comments_content` (`content`),
    
    -- 外键约束
    CONSTRAINT `fk_comments_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_comments_post` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_comments_music` FOREIGN KEY (`music_id`) REFERENCES `music` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_comments_parent` FOREIGN KEY (`parent_id`) REFERENCES `comments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='评论表';

-- 动态点赞表
CREATE TABLE IF NOT EXISTS `post_likes` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `user_id` BIGINT NOT NULL,
    `post_id` BIGINT NOT NULL,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY `uk_user_post` (`user_id`, `post_id`),
    INDEX idx_user_id (`user_id`),
    INDEX idx_post_id (`post_id`),
    INDEX idx_created_at (`created_at`),
    
    -- 外键约束
    CONSTRAINT `fk_post_likes_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_post_likes_post` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='动态点赞表';

-- 评论点赞表
CREATE TABLE IF NOT EXISTS `comment_likes` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `user_id` BIGINT NOT NULL,
    `comment_id` BIGINT NOT NULL,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY `uk_user_comment` (`user_id`, `comment_id`),
    INDEX idx_user_id (`user_id`),
    INDEX idx_comment_id (`comment_id`),
    INDEX idx_created_at (`created_at`),
    
    -- 外键约束
    CONSTRAINT `fk_comment_likes_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_comment_likes_comment` FOREIGN KEY (`comment_id`) REFERENCES `comments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='评论点赞表';

-- 音乐点赞表
CREATE TABLE IF NOT EXISTS `music_likes` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `user_id` BIGINT NOT NULL,
    `music_id` BIGINT NOT NULL,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY `uk_user_music_like` (`user_id`, `music_id`),
    INDEX idx_user_id (`user_id`),
    INDEX idx_music_id (`music_id`),
    INDEX idx_created_at (`created_at`),
    
    -- 外键约束
    CONSTRAINT `fk_music_likes_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_music_likes_music` FOREIGN KEY (`music_id`) REFERENCES `music` (`id`) ON DELETE CASCADE
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
    INDEX idx_create_time (`create_time`),
    
    -- 外键约束
    CONSTRAINT `fk_follow_follower` FOREIGN KEY (`follower_id`) REFERENCES `user` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_follow_following` FOREIGN KEY (`following_id`) REFERENCES `user` (`id`) ON DELETE CASCADE
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
    INDEX idx_create_time (`create_time`),
    
    -- 外键约束
    CONSTRAINT `fk_collection_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_collection_music` FOREIGN KEY (`music_id`) REFERENCES `music` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='收藏表';

-- 播放记录表 - 优化索引（大数据量表）
CREATE TABLE IF NOT EXISTS `play_record` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `music_id` BIGINT NOT NULL COMMENT '音乐ID',
    `play_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '播放时间',
    `play_duration` INT COMMENT '播放时长(秒)',
    `play_type` TINYINT DEFAULT 0 COMMENT '播放类型(0:完整播放,1:部分播放)',
    INDEX idx_user_id_play_time (`user_id`, `play_time`), -- 用户播放历史查询
    INDEX idx_music_id_play_time (`music_id`, `play_time`), -- 音乐播放统计
    INDEX idx_play_time (`play_time`),
    INDEX idx_user_music_play_time (`user_id`, `music_id`, `play_time`), -- 用户对特定音乐的播放记录
    
    -- 外键约束
    CONSTRAINT `fk_play_record_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_play_record_music` FOREIGN KEY (`music_id`) REFERENCES `music` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='播放记录表';

-- =============================================
-- 新增表：搜索记录表（用于优化搜索性能）
-- =============================================
CREATE TABLE IF NOT EXISTS `search_history` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `user_id` BIGINT COMMENT '用户ID（可为空，表示匿名搜索）',
    `keyword` VARCHAR(100) NOT NULL COMMENT '搜索关键词',
    `search_type` TINYINT DEFAULT 0 COMMENT '搜索类型(0:音乐,1:用户,2:歌单,3:动态)',
    `result_count` INT DEFAULT 0 COMMENT '搜索结果数量',
    `search_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_id_search_time (`user_id`, `search_time`),
    INDEX idx_keyword_search_time (`keyword`, `search_time`),
    INDEX idx_search_type_search_time (`search_type`, `search_time`),
    
    -- 外键约束
    CONSTRAINT `fk_search_history_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='搜索记录表';

-- =============================================
-- 新增表：缓存表（用于热点数据缓存）
-- =============================================
CREATE TABLE IF NOT EXISTS `cache_data` (
    `cache_key` VARCHAR(200) PRIMARY KEY COMMENT '缓存键',
    `cache_value` TEXT NOT NULL COMMENT '缓存值',
    `expire_time` DATETIME NOT NULL COMMENT '过期时间',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_expire_time (`expire_time`),
    INDEX idx_create_time (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='缓存数据表';

-- =============================================
-- 插入默认数据
-- =============================================

-- 1. 插入默认用户（所有用户统一使用指定的BCrypt加密密码）
INSERT IGNORE INTO `user` (
    `username`, `password`, `nickname`, `email`,
    `status`, `is_musician`, `register_time`
) VALUES
-- 管理员用户
('admin', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '管理员', 'admin@example.com', 1, 0, CURRENT_TIMESTAMP),
-- 普通用户
('user', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '普通用户', 'user@example.com', 1, 0, CURRENT_TIMESTAMP),
-- 音乐人用户
('musician', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '音乐人', 'musician@example.com', 1, 1, CURRENT_TIMESTAMP);

-- 2. 插入用户角色关联数据
INSERT IGNORE INTO `user_role` (`user_id`, `role_id`)
SELECT u.id, r.id FROM `user` u, `role` r WHERE u.username = 'admin' AND r.name = 'ROLE_ADMIN';

INSERT IGNORE INTO `user_role` (`user_id`, `role_id`)
SELECT u.id, r.id FROM `user` u, `role` r WHERE u.username = 'user' AND r.name = 'ROLE_USER';

INSERT IGNORE INTO `user_role` (`user_id`, `role_id`)
SELECT u.id, r.id FROM `user` u, `role` r WHERE u.username = 'musician' AND r.name = 'ROLE_MUSICIAN';

-- =============================================
-- 插入音乐人数据
-- =============================================

-- 3. 插入用户数据（其他热门歌手数据）
-- 插入user
INSERT IGNORE INTO `user` (
    `username`, `password`, `nickname`, `email`, `status`, `is_musician`, `register_time`
) VALUES
-- 经典歌手
('zhoujielun', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '周杰伦', 'zhoujielun@example.com', 1, 1, CURRENT_TIMESTAMP),
('sunyanzi', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '孙燕姿', 'sunyanzi@example.com', 1, 1, CURRENT_TIMESTAMP),
('linjunjie', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '林俊杰', 'linjunjie@example.com', 1, 1, CURRENT_TIMESTAMP),
('chenyixun', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '陈奕迅', 'chenyixun@example.com', 1, 1, CURRENT_TIMESTAMP),
('wangfei', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '王菲', 'wangfei@example.com', 1, 1, CURRENT_TIMESTAMP),
('zhangxueyou', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '张学友', 'zhangxueyou@example.com', 1, 1, CURRENT_TIMESTAMP),
('liudehua', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '刘德华', 'liudehua@example.com', 1, 1, CURRENT_TIMESTAMP),
('nayin', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '那英', 'nayin@example.com', 1, 1, CURRENT_TIMESTAMP),
('zhaoxueyan', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '赵学而', 'zhaoxueyan@example.com', 1, 1, CURRENT_TIMESTAMP),
('wangleehom', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '王力宏', 'wangleehom@example.com', 1, 1, CURRENT_TIMESTAMP),
('taozhe', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '陶喆', 'taozhe@example.com', 1, 1, CURRENT_TIMESTAMP),
('caiyilin', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '蔡依林', 'caiyilin@example.com', 1, 1, CURRENT_TIMESTAMP),
('zhangshaohan', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '张韶涵', 'zhangshaohan@example.com', 1, 1, CURRENT_TIMESTAMP),
('yangchenglin', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '杨丞琳', 'yangchenglin@example.com', 1, 1, CURRENT_TIMESTAMP),
('luozhixiang', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '罗志祥', 'luozhixiang@example.com', 1, 1, CURRENT_TIMESTAMP),
('xiaojingteng', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '萧敬腾', 'xiaojingteng@example.com', 1, 1, CURRENT_TIMESTAMP),
('huyanbin', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '胡彦斌', 'huyanbin@example.com', 1, 1, CURRENT_TIMESTAMP),
('zhouhuajian', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '周华健', 'zhouhuajian@example.com', 1, 1, CURRENT_TIMESTAMP),
('lizongsheng', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '李宗盛', 'lizongsheng@example.com', 1, 1, CURRENT_TIMESTAMP),
('luodayou', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '罗大佑', 'luodayou@example.com', 1, 1, CURRENT_TIMESTAMP),
('qiqin', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '齐秦', 'qiqin@example.com', 1, 1, CURRENT_TIMESTAMP),
('wangjie', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '王杰', 'wangjie@example.com', 1, 1, CURRENT_TIMESTAMP),
('tongange', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '童安格', 'tongange@example.com', 1, 1, CURRENT_TIMESTAMP),
('jiangyuheng', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '姜育恒', 'jiangyuheng@example.com', 1, 1, CURRENT_TIMESTAMP),
('zhangxinzhe', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '张信哲', 'zhangxinzhe@example.com', 1, 1, CURRENT_TIMESTAMP),
('taizhengxiao', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '邰正宵', 'taizhengxiao@example.com', 1, 1, CURRENT_TIMESTAMP),
('yuchengqing', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '庾澄庆', 'yuchengqing@example.com', 1, 1, CURRENT_TIMESTAMP),
('zhangyu', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '张宇', 'zhangyu@example.com', 1, 1, CURRENT_TIMESTAMP),
('renxianqi', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '任贤齐', 'renxianqi@example.com', 1, 1, CURRENT_TIMESTAMP),
('guangliang', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '光良', 'guangliang@example.com', 1, 1, CURRENT_TIMESTAMP),
('pingguan', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '品冠', 'pingguan@example.com', 1, 1, CURRENT_TIMESTAMP),
('adu', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '阿杜', 'adu@example.com', 1, 1, CURRENT_TIMESTAMP),
('chenxiaochun', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '陈小春', 'chenxiaochun@example.com', 1, 1, CURRENT_TIMESTAMP),
('zhengyijian', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '郑伊健', 'zhengyijian@example.com', 1, 1, CURRENT_TIMESTAMP),
('xuzhian', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '许志安', 'xuzhian@example.com', 1, 1, CURRENT_TIMESTAMP),
('suyongkang', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '苏永康', 'suyongkang@example.com', 1, 1, CURRENT_TIMESTAMP),
('zhangweijian', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '张卫健', 'zhangweijian@example.com', 1, 1, CURRENT_TIMESTAMP),
('linzhiying', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '林志颖', 'linzhiying@example.com', 1, 1, CURRENT_TIMESTAMP),
('wuqilong', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '吴奇隆', 'wuqilong@example.com', 1, 1, CURRENT_TIMESTAMP),
('suyoupeng', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '苏有朋', 'suyoupeng@example.com', 1, 1, CURRENT_TIMESTAMP),
('chenzhipeng', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '陈志朋', 'chenzhipeng@example.com', 1, 1, CURRENT_TIMESTAMP),
('panweibo', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '潘玮柏', 'panweibo@example.com', 1, 1, CURRENT_TIMESTAMP),
('tangyuzhe', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '唐禹哲', 'tangyuzhe@example.com', 1, 1, CURRENT_TIMESTAMP),
('wudongcheng', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '汪东城', 'wudongcheng@example.com', 1, 1, CURRENT_TIMESTAMP),
('yanyalun', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '炎亚纶', 'yanyalun@example.com', 1, 1, CURRENT_TIMESTAMP),
('chenyiru', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '辰亦儒', 'chenyiru@example.com', 1, 1, CURRENT_TIMESTAMP),
('wuzun', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '吴尊', 'wuzun@example.com', 1, 1, CURRENT_TIMESTAMP),
('wuyi', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '伍佰', 'wuyi@example.com', 1, 1, CURRENT_TIMESTAMP),
('xietingfeng', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '谢霆锋', 'xietingfeng@example.com', 1, 1, CURRENT_TIMESTAMP),
-- 女歌手（经典）
('dengziqi', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '邓紫棋', 'dengziqi@example.com', 1, 1, CURRENT_TIMESTAMP),
('lianjingru', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '梁静茹', 'lianjingru@example.com', 1, 1, CURRENT_TIMESTAMP),
('liuruoying', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '刘若英', 'liuruoying@example.com', 1, 1, CURRENT_TIMESTAMP),
('fanweiqi', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '范玮琪', 'fanweiqi@example.com', 1, 1, CURRENT_TIMESTAMP),
('daipenni', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '戴佩妮', 'daipenni@example.com', 1, 1, CURRENT_TIMESTAMP),
('caijianya', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '蔡健雅', 'caijianya@example.com', 1, 1, CURRENT_TIMESTAMP),
('tianfuzhen', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '田馥甄', 'tianfuzhen@example.com', 1, 1, CURRENT_TIMESTAMP),
('chenqizhen', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '陈绮贞', 'chenqizhen@example.com', 1, 1, CURRENT_TIMESTAMP),
('mowenwei', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '莫文蔚', 'mowenwei@example.com', 1, 1, CURRENT_TIMESTAMP);

-- 4. 插入音乐人数据
-- 插入musician
INSERT IGNORE INTO `musician` (
    `user_id`, `stage_name`, `genre`, `verified`, `follower_count`, `create_time`
)
SELECT
    u.id,
    CASE u.username
        -- 经典男歌手
        WHEN 'zhoujielun' THEN '周杰伦'
        WHEN 'sunyanzi' THEN '孙燕姿'
        WHEN 'linjunjie' THEN '林俊杰'
        WHEN 'chenyixun' THEN '陈奕迅'
        WHEN 'wangfei' THEN '王菲'
        WHEN 'zhangxueyou' THEN '张学友'
        WHEN 'liudehua' THEN '刘德华'
        WHEN 'nayin' THEN '那英'
        WHEN 'zhaoxueyan' THEN '赵学而'
        WHEN 'wangleehom' THEN '王力宏'
        WHEN 'taozhe' THEN '陶喆'
        WHEN 'caiyilin' THEN '蔡依林'
        WHEN 'zhangshaohan' THEN '张韶涵'
        WHEN 'yangchenglin' THEN '杨丞琳'
        WHEN 'luozhixiang' THEN '罗志祥'
        WHEN 'xiaojingteng' THEN '萧敬腾'
        WHEN 'huyanbin' THEN '胡彦斌'
        WHEN 'zhouhuajian' THEN '周华健'
        WHEN 'lizongsheng' THEN '李宗盛'
        WHEN 'luodayou' THEN '罗大佑'
        WHEN 'qiqin' THEN '齐秦'
        WHEN 'wangjie' THEN '王杰'
        WHEN 'tongange' THEN '童安格'
        WHEN 'jiangyuheng' THEN '姜育恒'
        WHEN 'zhangxinzhe' THEN '张信哲'
        WHEN 'taizhengxiao' THEN '邰正宵'
        WHEN 'yuchengqing' THEN '庾澄庆'
        WHEN 'zhangyu' THEN '张宇'
        WHEN 'renxianqi' THEN '任贤齐'
        WHEN 'guangliang' THEN '光良'
        WHEN 'pingguan' THEN '品冠'
        WHEN 'adu' THEN '阿杜'
        WHEN 'chenxiaochun' THEN '陈小春'
        WHEN 'zhengyijian' THEN '郑伊健'
        WHEN 'xuzhian' THEN '许志安'
        WHEN 'suyongkang' THEN '苏永康'
        WHEN 'zhangweijian' THEN '张卫健'
        WHEN 'linzhiying' THEN '林志颖'
        WHEN 'wuqilong' THEN '吴奇隆'
        WHEN 'suyoupeng' THEN '苏有朋'
        WHEN 'chenzhipeng' THEN '陈志朋'
        WHEN 'panweibo' THEN '潘玮柏'
        WHEN 'tangyuzhe' THEN '唐禹哲'
        WHEN 'wudongcheng' THEN '汪东城'
        WHEN 'yanyalun' THEN '炎亚纶'
        WHEN 'chenyiru' THEN '辰亦儒'
        WHEN 'wuzun' THEN '吴尊'
        WHEN 'wuyi' THEN '伍佰'
        WHEN 'xietingfeng' THEN '谢霆锋'
        -- 经典女歌手
        WHEN 'dengziqi' THEN '邓紫棋'
        WHEN 'lianjingru' THEN '梁静茹'
        WHEN 'liuruoying' THEN '刘若英'
        WHEN 'fanweiqi' THEN '范玮琪'
        WHEN 'daipenni' THEN '戴佩妮'
        WHEN 'caijianya' THEN '蔡健雅'
        WHEN 'tianfuzhen' THEN '田馥甄'
        WHEN 'chenqizhen' THEN '陈绮贞'
        WHEN 'mowenwei' THEN '莫文蔚'
        ELSE u.nickname
        END AS stage_name,
    CASE u.username
        WHEN 'zhoujielun' THEN '华语流行、中国风'
        WHEN 'linjunjie' THEN '华语流行、R&B'
        WHEN 'chenyixun' THEN '华语流行、抒情'
        WHEN 'dengziqi' THEN '华语流行、灵魂乐'
        WHEN 'zhoushen' THEN '美声、流行、古风'
        ELSE '华语流行'
        END AS genre,
    1 AS verified,
    FLOOR(RAND() * 1000000 + 100000) AS follower_count,
    CURRENT_TIMESTAMP AS create_time
FROM `user` u
WHERE u.username IN (
     'zhoujielun', 'sunyanzi', 'linjunjie', 'chenyixun', 'wangfei', 'zhangxueyou', 'liudehua', 'nayin',
     'zhaoxueyan', 'wangleehom', 'taozhe', 'caiyilin', 'zhangshaohan', 'yangchenglin', 'luozhixiang',
     'xiaojingteng', 'huyanbin', 'zhouhuajian', 'lizongsheng', 'luodayou', 'qiqin', 'wangjie', 'tongange',
     'jiangyuheng', 'zhangxinzhe', 'taizhengxiao', 'yuchengqing', 'zhangyu', 'renxianqi', 'guangliang',
     'pingguan', 'adu', 'chenxiaochun', 'zhengyijian', 'xuzhian', 'suyongkang', 'zhangweijian', 'linzhiying',
     'wuqilong', 'suyoupeng', 'chenzhipeng', 'panweibo', 'tangyuzhe', 'wudongcheng', 'yanyalun', 'chenyiru',
     'wuzun', 'wuyi', 'xietingfeng', 'dengziqi', 'lianjingru', 'liuruoying', 'fanweiqi', 'daipenni',
     'caijianya', 'tianfuzhen', 'chenqizhen', 'mowenwei'
);

-- 5. 关联音乐人用户与ROLE_MUSICIAN角色
INSERT IGNORE INTO `user_role` (`user_id`, `role_id`)
SELECT
    u.id, r.id
FROM `user` u
         CROSS JOIN `role` r
WHERE r.name = 'ROLE_MUSICIAN'
  AND u.username IN (
    'zhoujielun', 'sunyanzi', 'linjunjie', 'chenyixun', 'wangfei', 'zhangxueyou', 'liudehua', 'nayin',
    'zhaoxueyan', 'wangleehom', 'taozhe', 'caiyilin', 'zhangshaohan', 'yangchenglin', 'luozhixiang',
    'xiaojingteng', 'huyanbin', 'zhouhuajian', 'lizongsheng', 'luodayou', 'qiqin', 'wangjie', 'tongange',
    'jiangyuheng', 'zhangxinzhe', 'taizhengxiao', 'yuchengqing', 'zhangyu', 'renxianqi', 'guangliang',
    'pingguan', 'adu', 'chenxiaochun', 'zhengyijian', 'xuzhian', 'suyongkang', 'zhangweijian', 'linzhiying',
    'wuqilong', 'suyoupeng', 'chenzhipeng', 'panweibo', 'tangyuzhe', 'wudongcheng', 'yanyalun', 'chenyiru',
    'wuzun', 'wuyi', 'xietingfeng', 'dengziqi', 'lianjingru', 'liuruoying', 'fanweiqi', 'daipenni',
    'caijianya', 'tianfuzhen', 'chenqizhen', 'mowenwei'
);

-- =============================================
-- 创建存储过程：用于数据统计和清理
-- =============================================

DELIMITER //

-- 存储过程：清理过期缓存
CREATE PROCEDURE `clean_expired_cache`()
BEGIN
    DELETE FROM `cache_data` WHERE `expire_time` < NOW();
END //

-- 存储过程：更新音乐统计数据
CREATE PROCEDURE `update_music_statistics`(IN music_id BIGINT)
BEGIN
    UPDATE `music` m 
    SET 
        `play_count` = (SELECT COUNT(*) FROM `play_record` WHERE `music_id` = music_id),
        `like_count` = (SELECT COUNT(*) FROM `music_likes` WHERE `music_id` = music_id),
        `comment_count` = (SELECT COUNT(*) FROM `comments` WHERE `music_id` = music_id)
    WHERE m.`id` = music_id;
END //

-- 存储过程：获取用户推荐音乐
CREATE PROCEDURE `get_user_recommendations`(IN user_id BIGINT, IN limit_count INT)
BEGIN
    -- 基于用户播放历史和关注的人推荐音乐
    SELECT DISTINCT m.* 
    FROM `music` m
    LEFT JOIN `play_record` pr ON m.`id` = pr.`music_id` AND pr.`user_id` = user_id
    LEFT JOIN `follow` f ON f.`follower_id` = user_id
    LEFT JOIN `music` fm ON fm.`musician_id` = f.`following_id`
    WHERE m.`status` = 1 
    AND (pr.`music_id` IS NULL OR pr.`play_time` < DATE_SUB(NOW(), INTERVAL 7 DAY))
    ORDER BY m.`play_count` DESC, m.`like_count` DESC
    LIMIT limit_count;
END //

DELIMITER ;

-- =============================================
-- 创建事件：定期维护任务
-- =============================================

-- 每天凌晨清理过期缓存
CREATE EVENT IF NOT EXISTS `event_clean_cache`
ON SCHEDULE EVERY 1 DAY STARTS '2025-01-01 03:00:00'
DO CALL `clean_expired_cache`();

-- 每周更新热门音乐统计数据
CREATE EVENT IF NOT EXISTS `event_update_hot_music`
ON SCHEDULE EVERY 1 WEEK STARTS '2025-01-01 04:00:00'
DO 
    UPDATE `music` 
    SET `play_count` = (SELECT COUNT(*) FROM `play_record` WHERE `music_id` = `music`.`id`),
        `like_count` = (SELECT COUNT(*) FROM `music_likes` WHERE `music_id` = `music`.`id`)
    WHERE `status` = 1;

-- =============================================
-- 优化建议和说明
-- =============================================

/*
优化总结：
1. 添加了复合索引，显著提升多条件查询性能
2. 添加了全文索引，支持高效的文本搜索
3. 添加了外键约束，保证数据一致性
4. 优化了表结构，添加了必要的字段
5. 创建了存储过程和事件，自动化维护任务
6. 添加了缓存表，支持热点数据缓存

使用建议：
1. 对于大数据量表（如play_record），考虑按时间分区
2. 定期分析查询性能，使用EXPLAIN分析慢查询
3. 考虑使用Redis等缓存系统进一步提升性能
4. 监控数据库连接数，合理配置连接池
*/

-- 启用事件调度器
SET GLOBAL event_scheduler = ON;