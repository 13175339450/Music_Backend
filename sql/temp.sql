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
    INDEX idx_username (`username`),
    INDEX idx_email (`email`),
    INDEX idx_phone (`phone`),
    INDEX idx_status (`status`),
    INDEX idx_musician_id (`musician_id`),
    -- 新增复合索引，优化管理员查询
    INDEX idx_register_time_status (`register_time`, `status`),
    INDEX idx_is_musician_status (`is_musician`, `status`)
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
    INDEX idx_verified (`verified`),
    INDEX idx_create_time (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='音乐人表';

-- 音乐表 - 优化索引
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
    INDEX idx_play_count (`play_count`),
    -- 新增复合索引，优化管理员查询
    INDEX idx_status_create_time (`status`, `create_time`),
    INDEX idx_musician_status (`musician_id`, `status`)
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
    INDEX idx_user_id (`user_id`),
    INDEX idx_music_id (`music_id`),
    INDEX idx_status (`status`),
    INDEX idx_created_at (`created_at`),
    -- 新增复合索引，优化管理员查询
    INDEX idx_status_created_at (`status`, `created_at`),
    INDEX idx_user_status (`user_id`, `status`)
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
    INDEX idx_user_id (`user_id`),
    INDEX idx_post_id (`post_id`),
    INDEX idx_music_id (`music_id`),
    INDEX idx_parent_id (`parent_id`),
    INDEX idx_created_at (`created_at`),
    -- 新增索引，优化管理员查询
    INDEX idx_post_status (`post_id`, `created_at`),
    INDEX idx_music_status (`music_id`, `created_at`)
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

-- 播放记录表 - 优化索引
CREATE TABLE IF NOT EXISTS `play_record` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `music_id` BIGINT NOT NULL COMMENT '音乐ID',
    `play_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '播放时间',
    `play_duration` INT COMMENT '播放时长(秒)',
    INDEX idx_user_id (`user_id`),
    INDEX idx_music_id (`music_id`),
    INDEX idx_play_time (`play_time`),
    INDEX idx_user_play_time (`user_id`, `play_time`),
    -- 新增索引，优化统计查询
    INDEX idx_music_play_time (`music_id`, `play_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='播放记录表';

-- 统计表（新增）- 用于缓存统计数据，减少实时计算
CREATE TABLE IF NOT EXISTS `stats_cache` (
    `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
    `stat_key` VARCHAR(100) NOT NULL COMMENT '统计键名',
    `stat_value` BIGINT NOT NULL COMMENT '统计值',
    `stat_date` DATE COMMENT '统计日期',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY `uk_key_date` (`stat_key`, `stat_date`),
    INDEX idx_key (`stat_key`),
    INDEX idx_date (`stat_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='统计缓存表';

-- 插入默认用户（所有用户统一使用指定的BCrypt加密密码）
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

-- 插入用户角色关联数据
INSERT IGNORE INTO `user_role` (`user_id`, `role_id`)
SELECT u.id, r.id FROM `user` u, `role` r WHERE u.username = 'admin' AND r.name = 'ROLE_ADMIN';

INSERT IGNORE INTO `user_role` (`user_id`, `role_id`)
SELECT u.id, r.id FROM `user` u, `role` r WHERE u.username = 'user' AND r.name = 'ROLE_USER';

INSERT IGNORE INTO `user_role` (`user_id`, `role_id`)
SELECT u.id, r.id FROM `user` u, `role` r WHERE u.username = 'musician' AND r.name = 'ROLE_MUSICIAN';

-- 插入100个中国音乐人用户数据
INSERT IGNORE INTO `user` (
    `username`, `password`, `nickname`, `email`, `gender`, `birthday`, `introduction`, `location`,
    `status`, `is_musician`, `register_time`
) VALUES
-- 经典歌手
('zhoujielun', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '周杰伦', 'zhoujielun@example.com', 1, '1979-01-18', '华语流行音乐天王，代表作《七里香》、《青花瓷》', '台湾省台北市', 1, 1, CURRENT_TIMESTAMP),
('sunyanzi', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '孙燕姿', 'sunyanzi@example.com', 2, '1978-07-23', '新加坡华语流行女歌手，代表作《遇见》、《绿光》', '新加坡', 1, 1, CURRENT_TIMESTAMP),
('linjunjie', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '林俊杰', 'linjunjie@example.com', 1, '1981-03-27', '新加坡华语流行男歌手，代表作《江南》、《曹操》', '新加坡', 1, 1, CURRENT_TIMESTAMP),
('chenyixun', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '陈奕迅', 'chenyixun@example.com', 1, '1974-07-27', '香港著名男歌手，代表作《十年》、《浮夸》', '香港特别行政区', 1, 1, CURRENT_TIMESTAMP),
('wangfei', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '王菲', 'wangfei@example.com', 2, '1969-08-08', '华语流行乐女歌手，代表作《红豆》、《容易受伤的女人》', '北京市', 1, 1, CURRENT_TIMESTAMP),
('zhangxueyou', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '张学友', 'zhangxueyou@example.com', 1, '1961-07-10', '香港著名男歌手，代表作《吻别》、《一千个伤心的理由》', '香港特别行政区', 1, 1, CURRENT_TIMESTAMP),
('liudehua', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '刘德华', 'liudehua@example.com', 1, '1961-09-27', '香港著名男歌手、演员，代表作《忘情水》、《冰雨》', '香港特别行政区', 1, 1, CURRENT_TIMESTAMP),
('nayin', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '那英', 'nayin@example.com', 2, '1967-11-27', '中国内地女歌手，代表作《征服》、《默》', '辽宁省沈阳市', 1, 1, CURRENT_TIMESTAMP),
('caiyilin', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '蔡依林', 'caiyilin@example.com', 2, '1980-09-15', '台湾省女歌手，代表作《舞娘》、《日不落》', '台湾省台北市', 1, 1, CURRENT_TIMESTAMP),
('zhangshaohan', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '张韶涵', 'zhangshaohan@example.com', 2, '1982-01-19', '台湾省女歌手，代表作《隐形的翅膀》、《欧若拉》', '台湾省台北市', 1, 1, CURRENT_TIMESTAMP),
-- 新生代歌手
('dengziqi', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '邓紫棋', 'dengziqi@example.com', 2, '1991-08-16', '香港创作型女歌手，代表作《泡沫》、《光年之外》', '香港特别行政区', 1, 1, CURRENT_TIMESTAMP),
('huaxichen', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '华晨宇', 'huaxichen@example.com', 1, '1990-02-07', '中国内地男歌手，代表作《烟火里的尘埃》、《齐天》', '湖北省十堰市', 1, 1, CURRENT_TIMESTAMP),
('zhoubichang', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '周笔畅', 'zhoubichang@example.com', 2, '1985-07-26', '中国内地女歌手，代表作《笔记》、《谁动了我的琴弦》', '湖南省长沙市', 1, 1, CURRENT_TIMESTAMP),
('liyuchun', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '李宇春', 'liyuchun@example.com', 2, '1984-03-10', '中国内地女歌手，代表作《下个路口见》、《蜀绣》', '四川省成都市', 1, 1, CURRENT_TIMESTAMP),
('zhangjie', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '张杰', 'zhangjie@example.com', 1, '1982-12-20', '中国内地男歌手，代表作《这就是爱》、《天下》', '四川省成都市', 1, 1, CURRENT_TIMESTAMP),
('xuezhiqian', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '薛之谦', 'xuezhiqian@example.com', 1, '1983-07-17', '中国内地男歌手，代表作《演员》、《丑八怪》', '上海市', 1, 1, CURRENT_TIMESTAMP),
('mahuan', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '马頔', 'mahuan@example.com', 1, '1989-01-15', '中国内地民谣歌手，代表作《南山南》、《傲寒》', '北京市', 1, 1, CURRENT_TIMESTAMP),
('songdongye', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '宋冬野', 'songdongye@example.com', 1, '1987-11-10', '中国内地民谣歌手，代表作《董小姐》、《安和桥》', '北京市', 1, 1, CURRENT_TIMESTAMP),
('chenli', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '陈粒', 'chenli@example.com', 2, '1990-07-26', '中国内地民谣女歌手，代表作《奇妙能力歌》、《小半》', '贵州省贵阳市', 1, 1, CURRENT_TIMESTAMP),
('haodong', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '好妹妹', 'haodong@example.com', 1, '1990-12-04', '中国内地民谣组合，代表作《一个人的北京》、《我说今晚月光那么美》', '江苏省南京市', 1, 1, CURRENT_TIMESTAMP),
-- 摇滚乐队
('wuyue', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '五月天', 'wuyue@example.com', 1, '1997-03-29', '台湾省摇滚乐队，代表作《倔强》、《突然好想你》', '台湾省台北市', 1, 1, CURRENT_TIMESTAMP),
('sodagreen', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '苏打绿', 'sodagreen@example.com', 1, '2001-05-01', '台湾省独立音乐乐队，代表作《小情歌》、《无与伦比的美丽》', '台湾省台北市', 1, 1, CURRENT_TIMESTAMP),
('naying', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '那英', 'naying@example.com', 2, '1967-11-27', '中国内地女歌手，代表作《征服》、《默》', '辽宁省沈阳市', 1, 1, CURRENT_TIMESTAMP),
('wangfeng', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '汪峰', 'wangfeng@example.com', 1, '1971-06-29', '中国内地摇滚歌手，代表作《飞得更高》、《春天里》', '北京市', 1, 1, CURRENT_TIMESTAMP),
('cuiyongyuan', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '崔永元', 'cuiyongyuan@example.com', 1, '1963-02-20', '中国内地主持人、音乐人', '天津市', 1, 1, CURRENT_TIMESTAMP),
-- 更多音乐人...
('liangbo', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '梁博', 'liangbo@example.com', 1, '1991-03-25', '中国内地男歌手，代表作《男孩》、《出现又离开》', '吉林省长春市', 1, 1, CURRENT_TIMESTAMP),
('majingrui', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '马敬瑞', 'majingrui@example.com', 1, '1985-08-12', '中国内地民谣歌手', '陕西省西安市', 1, 1, CURRENT_TIMESTAMP),
('zhangwei', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '张玮', 'zhangwei@example.com', 1, '1988-08-30', '中国内地男歌手', '内蒙古自治区包头市', 1, 1, CURRENT_TIMESTAMP),
('liuhuan', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '刘欢', 'liuhuan@example.com', 1, '1963-08-26', '中国内地男歌手，代表作《好汉歌》、《从头再来》', '天津市', 1, 1, CURRENT_TIMESTAMP),
('hanhong', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '韩红', 'hanhong@example.com', 2, '1971-09-26', '中国内地女歌手，代表作《天路》、《那片海》', '西藏自治区昌都市', 1, 1, CURRENT_TIMESTAMP),
('sunyue', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '孙悦', 'sunyue@example.com', 2, '1972-06-29', '中国内地女歌手，代表作《祝你平安》、《魅力无限》', '黑龙江省哈尔滨市', 1, 1, CURRENT_TIMESTAMP),
('tengger', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '腾格尔', 'tengger@example.com', 1, '1960-01-15', '中国内地男歌手，代表作《天堂》、《蒙古人》', '内蒙古自治区鄂尔多斯市', 1, 1, CURRENT_TIMESTAMP),
('caiqing', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '蔡琴', 'caiqing@example.com', 2, '1957-12-22', '台湾省女歌手，代表作《恰似你的温柔》、《被遗忘的时光》', '台湾省台北市', 1, 1, CURRENT_TIMESTAMP),
('feiyuqing', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '费玉清', 'feiyuqing@example.com', 1, '1955-07-17', '台湾省男歌手，代表作《一剪梅》、《千里之外》', '台湾省台北市', 1, 1, CURRENT_TIMESTAMP),
('zhangguorong', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '张国荣', 'zhangguorong@example.com', 1, '1956-09-12', '香港著名歌手、演员，代表作《风继续吹》、《Monica》', '香港特别行政区', 1, 1, CURRENT_TIMESTAMP),
('meiyanfang', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '梅艳芳', 'meiyanfang@example.com', 2, '1963-10-10', '香港著名女歌手、演员，代表作《女人花》、《亲密爱人》', '香港特别行政区', 1, 1, CURRENT_TIMESTAMP),
('tanjing', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '谭晶', 'tanjing@example.com', 2, '1977-09-11', '中国内地女歌手，代表作《在那东山顶上》、《龙文》', '山西省侯马市', 1, 1, CURRENT_TIMESTAMP),
('liuwen', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '刘文正', 'liuwen@example.com', 1, '1952-11-12', '台湾省男歌手，代表作《三月里的小雨》、《兰花草》', '台湾省台北市', 1, 1, CURRENT_TIMESTAMP),
('denglijun', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '邓丽君', 'denglijun@example.com', 2, '1953-01-29', '华语乐坛传奇女歌手，代表作《月亮代表我的心》、《甜蜜蜜》', '台湾省台北市', 1, 1, CURRENT_TIMESTAMP),
('luoxiao', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '罗大佑', 'luoxiao@example.com', 1, '1954-07-20', '台湾省创作型歌手，代表作《童年》、《恋曲1990》', '台湾省台北市', 1, 1, CURRENT_TIMESTAMP),
('lizongsheng', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '李宗盛', 'lizongsheng@example.com', 1, '1958-07-19', '台湾省创作型歌手，代表作《山丘》、《鬼迷心窍》', '台湾省台北市', 1, 1, CURRENT_TIMESTAMP),
('zhouhuajian', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '周华健', 'zhouhuajian@example.com', 1, '1960-12-22', '台湾省男歌手，代表作《朋友》、《花心》', '台湾省台北市', 1, 1, CURRENT_TIMESTAMP),
('qiqin', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '齐秦', 'qiqin@example.com', 1, '1960-01-12', '台湾省男歌手，代表作《大约在冬季》、《外面的世界》', '台湾省台北市', 1, 1, CURRENT_TIMESTAMP),
('wangjie', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '王杰', 'wangjie@example.com', 1, '1962-10-20', '台湾省男歌手，代表作《一场游戏一场梦》、《安妮》', '台湾省台北市', 1, 1, CURRENT_TIMESTAMP),
('tongange', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '童安格', 'tongange@example.com', 1, '1959-07-26', '台湾省男歌手，代表作《其实你不懂我的心》、《明天你是否依然爱我》', '台湾省台北市', 1, 1, CURRENT_TIMESTAMP),
('jiangyuheng', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '姜育恒', 'jiangyuheng@example.com', 1, '1958-11-15', '台湾省男歌手，代表作《再回首》、《跟往事干杯》', '台湾省台北市', 1, 1, CURRENT_TIMESTAMP),
('zhangxinzhe', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '张信哲', 'zhangxinzhe@example.com', 1, '1967-03-26', '台湾省男歌手，代表作《爱如潮水》、《过火》', '台湾省台北市', 1, 1, CURRENT_TIMESTAMP),
('taizhengxiao', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '邰正宵', 'taizhengxiao@example.com', 1, '1966-11-06', '台湾省男歌手，代表作《九百九十九朵玫瑰》、《千纸鹤》', '台湾省台北市', 1, 1, CURRENT_TIMESTAMP),
('yuchengqing', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '庾澄庆', 'yuchengqing@example.com', 1, '1961-07-28', '台湾省男歌手，代表作《情非得已》、《让我一次爱个够》', '台湾省台北市', 1, 1, CURRENT_TIMESTAMP),
('zhangyu', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '张宇', 'zhangyu@example.com', 1, '1967-04-30', '台湾省男歌手，代表作《雨一直下》、《月亮惹的祸》', '台湾省台北市', 1, 1, CURRENT_TIMESTAMP),
('renxianqi', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '任贤齐', 'renxianqi@example.com', 1, '1966-06-23', '台湾省男歌手，代表作《心太软》、《对面的女孩看过来》', '台湾省台北市', 1, 1, CURRENT_TIMESTAMP),
('guangliang', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '光良', 'guangliang@example.com', 1, '1970-08-30', '马来西亚华语男歌手，代表作《童话》、《第一次》', '马来西亚', 1, 1, CURRENT_TIMESTAMP),
('pingguan', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '品冠', 'pingguan@example.com', 1, '1972-02-26', '马来西亚华语男歌手，代表作《掌心》、《我以为》', '马来西亚', 1, 1, CURRENT_TIMESTAMP),
('adu', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '阿杜', 'adu@example.com', 1, '1973-03-11', '新加坡华语男歌手，代表作《他一定很爱你》、《天黑》', '新加坡', 1, 1, CURRENT_TIMESTAMP),
('chenxiaochun', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '陈小春', 'chenxiaochun@example.com', 1, '1967-07-08', '香港男歌手、演员，代表作《算你狠》、《独家记忆》', '香港特别行政区', 1, 1, CURRENT_TIMESTAMP),
('zhengyijian', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '郑伊健', 'zhengyijian@example.com', 1, '1967-10-04', '香港男歌手、演员，代表作《友情岁月》、《发现》', '香港特别行政区', 1, 1, CURRENT_TIMESTAMP),
('xuzhian', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '许志安', 'xuzhian@example.com', 1, '1967-08-12', '香港男歌手，代表作《为什么你背着我爱别人》、《上弦月》', '香港特别行政区', 1, 1, CURRENT_TIMESTAMP),
('suyongkang', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '苏永康', 'suyongkang@example.com', 1, '1967-09-24', '香港男歌手，代表作《爱一个人好难》、《男人不该让女人流泪》', '香港特别行政区', 1, 1, CURRENT_TIMESTAMP),
('zhangweijian', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '张卫健', 'zhangweijian@example.com', 1, '1965-02-08', '香港男歌手、演员，代表作《真英雄》、《你爱我像谁》', '香港特别行政区', 1, 1, CURRENT_TIMESTAMP),
('linzhiying', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '林志颖', 'linzhiying@example.com', 1, '1974-10-15', '台湾省男歌手、演员，代表作《十七岁的雨季》、《快乐至上》', '台湾省台北市', 1, 1, CURRENT_TIMESTAMP),
('wuqilong', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '吴奇隆', 'wuqilong@example.com', 1, '1970-10-31', '台湾省男歌手、演员，代表作《祝你一路顺风》、《追风少年》', '台湾省台北市', 1, 1, CURRENT_TIMESTAMP),
('suyoupeng', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '苏有朋', 'suyoupeng@example.com', 1, '1973-09-11', '台湾省男歌手、演员，代表作《背包》、《珍惜》', '台湾省台北市', 1, 1, CURRENT_TIMESTAMP),
('chenzhipeng', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '陈志朋', 'chenzhipeng@example.com', 1, '1971-05-19', '台湾省男歌手、演员，代表作《爱》、《让爱跟着青春走》', '台湾省台北市', 1, 1, CURRENT_TIMESTAMP),
('panweibo', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '潘玮柏', 'panweibo@example.com', 1, '1980-08-06', '台湾省男歌手，代表作《快乐崇拜》、《不得不爱》', '台湾省台北市', 1, 1, CURRENT_TIMESTAMP),
('tangyuzhe', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '唐禹哲', 'tangyuzhe@example.com', 1, '1984-09-02', '台湾省男歌手、演员，代表作《爱我》、《分开以后》', '台湾省台北市', 1, 1, CURRENT_TIMESTAMP),
('wudongcheng', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '汪东城', 'wudongcheng@example.com', 1, '1981-08-24', '台湾省男歌手、演员，代表作《我应该去爱你》、《假装我们没爱过》', '台湾省台北市', 1, 1, CURRENT_TIMESTAMP),
('yanyalun', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '炎亚纶', 'yanyalun@example.com', 1, '1985-11-20', '台湾省男歌手、演员，代表作《下一个炎亚纶》、《纪念日》', '台湾省台北市', 1, 1, CURRENT_TIMESTAMP),
('chenyiru', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '辰亦儒', 'chenyiru@example.com', 1, '1980-11-10', '台湾省男歌手、演员，代表作《还在夏天呢》、《闻七起武》', '台湾省台北市', 1, 1, CURRENT_TIMESTAMP),
('wuzun', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '吴尊', 'wuzun@example.com', 1, '1979-10-10', '文莱华语男歌手、演员，代表作《只对你有感觉》、《新窝》', '文莱', 1, 1, CURRENT_TIMESTAMP),
('wuyi', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '伍佰', 'wuyi@example.com', 1, '1968-01-14', '台湾省男歌手，代表作《挪威的森林》、《突然的自我》', '台湾省台北市', 1, 1, CURRENT_TIMESTAMP),
('xietingfeng', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '谢霆锋', 'xietingfeng@example.com', 1, '1980-08-29', '香港男歌手、演员，代表作《因为爱所以爱》、《谢谢你的爱1999》', '香港特别行政区', 1, 1, CURRENT_TIMESTAMP),
('lianjingru', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '梁静茹', 'lianjingru@example.com', 2, '1978-06-16', '马来西亚华语女歌手，代表作《勇气》、《分手快乐》', '马来西亚', 1, 1, CURRENT_TIMESTAMP),
('liuruoying', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '刘若英', 'liuruoying@example.com', 2, '1970-06-01', '台湾省女歌手、演员，代表作《后来》、《为爱痴狂》', '台湾省台北市', 1, 1, CURRENT_TIMESTAMP),
('fanweiqi', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '范玮琪', 'fanweiqi@example.com', 2, '1976-03-18', '台湾省女歌手，代表作《最初的梦想》、《一个像夏天一个像秋天》', '台湾省台北市', 1, 1, CURRENT_TIMESTAMP),
('daipenni', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '戴佩妮', 'daipenni@example.com', 2, '1978-04-22', '马来西亚华语女歌手，代表作《怎样》、《你要的爱》', '马来西亚', 1, 1, CURRENT_TIMESTAMP),
('caijianya', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '蔡健雅', 'caijianya@example.com', 2, '1975-01-28', '新加坡华语女歌手，代表作《红色高跟鞋》、《达尔文》', '新加坡', 1, 1, CURRENT_TIMESTAMP),
('tianfuzhen', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '田馥甄', 'tianfuzhen@example.com', 2, '1983-03-30', '台湾省女歌手，代表作《小幸运》、《魔鬼中的天使》', '台湾省台北市', 1, 1, CURRENT_TIMESTAMP),
('chenqizhen', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '陈绮贞', 'chenqizhen@example.com', 2, '1975-06-06', '台湾省创作型女歌手，代表作《旅行的意义》、《还是会寂寞》', '台湾省台北市', 1, 1, CURRENT_TIMESTAMP),
('mowenwei', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '莫文蔚', 'mowenwei@example.com', 2, '1970-06-02', '香港女歌手、演员，代表作《阴天》、《如果没有你》', '香港特别行政区', 1, 1, CURRENT_TIMESTAMP),
('yangchenglin', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '杨丞琳', 'yangchenglin@example.com', 2, '1984-06-04', '台湾省女歌手、演员，代表作《暧昧》、《雨爱》', '台湾省台北市', 1, 1, CURRENT_TIMESTAMP),
('luozhixiang', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '罗志祥', 'luozhixiang@example.com', 1, '1979-07-30', '台湾省男歌手、演员，代表作《爱转角》、《精舞门》', '台湾省台北市', 1, 1, CURRENT_TIMESTAMP),
('xiaojingteng', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '萧敬腾', 'xiaojingteng@example.com', 1, '1987-03-30', '台湾省男歌手，代表作《王妃》、《新不了情》', '台湾省台北市', 1, 1, CURRENT_TIMESTAMP),
('huyanbin', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '胡彦斌', 'huyanbin@example.com', 1, '1983-07-04', '中国内地男歌手，代表作《红颜》、《月光》', '上海市', 1, 1, CURRENT_TIMESTAMP),
('yangkun', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '杨坤', 'yangkun@example.com', 1, '1972-12-18', '中国内地男歌手，代表作《无所谓》、《空城》', '内蒙古自治区包头市', 1, 1, CURRENT_TIMESTAMP),
('shaoyeqi', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '沙宝亮', 'shaoyeqi@example.com', 1, '1972-01-01', '中国内地男歌手，代表作《暗香》、《飘》', '北京市', 1, 1, CURRENT_TIMESTAMP),
('sunlan', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '孙楠', 'sunlan@example.com', 1, '1969-02-18', '中国内地男歌手，代表作《不见不散》、《拯救》', '辽宁省大连市', 1, 1, CURRENT_TIMESTAMP),
('lijingjie', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '李健', 'lijingjie@example.com', 1, '1974-09-23', '中国内地男歌手，代表作《贝加尔湖畔》、《传奇》', '黑龙江省哈尔滨市', 1, 1, CURRENT_TIMESTAMP),
('pantao', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '朴树', 'pantao@example.com', 1, '1973-11-08', '中国内地男歌手，代表作《平凡之路》、《那些花儿》', '江苏省南京市', 1, 1, CURRENT_TIMESTAMP),
('xuxian', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '许巍', 'xuxian@example.com', 1, '1968-07-21', '中国内地男歌手，代表作《蓝莲花》、《曾经的你》', '陕西省西安市', 1, 1, CURRENT_TIMESTAMP),
('zhangzhenyue', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '张震岳', 'zhangzhenyue@example.com', 1, '1974-05-02', '台湾省男歌手，代表作《爱我别走》、《思念是一种病》', '台湾省台北市', 1, 1, CURRENT_TIMESTAMP),
('reliang', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '热狗', 'reliang@example.com', 1, '1978-04-10', '台湾省说唱歌手，代表作《差不多先生》、《贫民百万歌星》', '台湾省台北市', 1, 1, CURRENT_TIMESTAMP),
('wanglihong', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '王力宏', 'wanglihong@example.com', 1, '1976-05-17', '美籍华语男歌手，代表作《唯一》、《心中的日月》', '美国纽约', 1, 1, CURRENT_TIMESTAMP),
('taozhe', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '陶喆', 'taozhe@example.com', 1, '1969-07-11', '台湾省男歌手，代表作《爱很简单》、《今天你要嫁给我》', '台湾省台北市', 1, 1, CURRENT_TIMESTAMP),
('fangdatong', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '方大同', 'fangdatong@example.com', 1, '1983-09-14', '香港男歌手，代表作《三人游》、《Love Song》', '香港特别行政区', 1, 1, CURRENT_TIMESTAMP),
('linyoujia', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '林宥嘉', 'linyoujia@example.com', 1, '1987-07-01', '台湾省男歌手，代表作《说谎》、《残酷月光》', '台湾省台北市', 1, 1, CURRENT_TIMESTAMP),
('xiaoijing', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '萧敬腾', 'xiaoijing@example.com', 1, '1987-03-30', '台湾省男歌手，代表作《王妃》、《新不了情》', '台湾省台北市', 1, 1, CURRENT_TIMESTAMP),
('lironghao', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '李荣浩', 'lironghao@example.com', 1, '1985-07-11', '中国内地男歌手，代表作《模特》、《李白》', '安徽省蚌埠市', 1, 1, CURRENT_TIMESTAMP),
('maobuyi', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '毛不易', 'maobuyi@example.com', 1, '1994-10-01', '中国内地男歌手，代表作《消愁》、《像我这样的人》', '黑龙江省齐齐哈尔市', 1, 1, CURRENT_TIMESTAMP),
('zhouyan', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '周延', 'zhouyan@example.com', 1, '1987-03-22', '中国内地说唱歌手，代表作《沧海一声笑》、《虎山行》', '四川省成都市', 1, 1, CURRENT_TIMESTAMP),
('wangjiaer', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '王嘉尔', 'wangjiaer@example.com', 1, '1994-03-28', '香港男歌手，代表作《Papillon》、《Different Game》', '香港特别行政区', 1, 1, CURRENT_TIMESTAMP),
('yangsikai', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '杨和苏', 'yangsikai@example.com', 1, '1995-07-28', '中国内地说唱歌手，代表作《小丑女》、《逆流》', '四川省成都市', 1, 1, CURRENT_TIMESTAMP),
('vava', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', 'VaVa', 'vava@example.com', 2, '1995-10-29', '中国内地说唱女歌手，代表作《我的新衣》、《Life is a struggle》', '四川省雅安市', 1, 1, CURRENT_TIMESTAMP),
('gai', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', 'GAI', 'gai@example.com', 1, '1987-03-22', '中国内地说唱歌手，代表作《沧海一声笑》、《虎山行》', '四川省内江市', 1, 1, CURRENT_TIMESTAMP),
('bridge', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', 'Bridge', 'bridge@example.com', 1, '1993-11-04', '中国内地说唱歌手，代表作《老大》、《长河》', '重庆市', 1, 1, CURRENT_TIMESTAMP),
('keyl', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', 'Key.L', 'keyl@example.com', 1, '1993-08-03', '中国内地说唱歌手，代表作《Hey Kong》、《经济舱》', '湖南省长沙市', 1, 1, CURRENT_TIMESTAMP),
('psyp', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', 'Psy.P', 'psyp@example.com', 1, '1992-07-28', '中国内地说唱歌手，代表作《街头霸王》、《刘玉玲》', '四川省成都市', 1, 1, CURRENT_TIMESTAMP),
('melo', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', 'Melo', 'melo@example.com', 1, '1993-11-04', '中国内地说唱歌手，代表作《成都集团2020 Cypher》', '四川省成都市', 1, 1, CURRENT_TIMESTAMP),
('knowknow', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', 'KnowKnow', 'knowknow@example.com', 1, '1996-05-28', '中国内地说唱歌手，代表作《R&B All Night》、《经济舱》', '江苏省南京市', 1, 1, CURRENT_TIMESTAMP),
('mai', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', 'Mai', 'mai@example.com', 1, '1989-04-04', '中国内地音乐制作人，代表作多首热门歌曲编曲', '湖南省长沙市', 1, 1, CURRENT_TIMESTAMP),
('higherbrothers', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', 'Higher Brothers', 'higherbrothers@example.com', 1, '2015-01-01', '中国内地说唱组合，代表作《Made in China》、《Black Cab》', '四川省成都市', 1, 1, CURRENT_TIMESTAMP);

-- 为音乐人用户分配ROLE_MUSICIAN角色
INSERT IGNORE INTO `user_role` (`user_id`, `role_id`)
SELECT u.id, r.id FROM `user` u, `role` r 
WHERE u.is_musician = 1 AND r.name = 'ROLE_MUSICIAN';

-- 插入音乐人详细信息
INSERT IGNORE INTO `musician` (`user_id`, `stage_name`, `real_name`, `genre`, `verified`, `follower_count`)
SELECT id, nickname, nickname, 
       CASE 
           WHEN nickname IN ('周杰伦', '林俊杰', '陈奕迅', '张学友', '刘德华') THEN '流行'
           WHEN nickname IN ('邓紫棋', '张韶涵', '蔡依林') THEN '流行'
           WHEN nickname IN ('华晨宇', '薛之谦', '张杰') THEN '流行'
           WHEN nickname IN ('马頔', '宋冬野', '陈粒') THEN '民谣'
           WHEN nickname IN ('五月天', '苏打绿', '汪峰') THEN '摇滚'
           WHEN nickname IN ('GAI', 'VaVa', 'Bridge') THEN '说唱'
           ELSE '流行'
       END,
       1, -- 已认证
       CASE 
           WHEN nickname IN ('周杰伦', '陈奕迅', '张学友') THEN 5000000
           WHEN nickname IN ('邓紫棋', '林俊杰', '蔡依林') THEN 3000000
           WHEN nickname IN ('华晨宇', '薛之谦', '张杰') THEN 2000000
           WHEN nickname IN ('GAI', 'VaVa', 'Bridge') THEN 1000000
           ELSE 500000
       END
FROM `user` 
WHERE is_musician = 1;