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

-- 2. 插入用户角色关联数据（关联用户与对应角色，保证权限正确）
INSERT IGNORE INTO `user_role` (`user_id`, `role_id`)
SELECT u.id, r.id FROM `user` u, `role` r WHERE u.username = 'admin' AND r.name = 'ROLE_ADMIN';

INSERT IGNORE INTO `user_role` (`user_id`, `role_id`)
SELECT u.id, r.id FROM `user` u, `role` r WHERE u.username = 'user' AND r.name = 'ROLE_USER';

INSERT IGNORE INTO `user_role` (`user_id`, `role_id`)
SELECT u.id, r.id FROM `user` u, `role` r WHERE u.username = 'musician' AND r.name = 'ROLE_MUSICIAN';

-- 3. 插入用户角色关联数据（其他热门歌手数据）
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
('mowenwei', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '莫文蔚', 'mowenwei@example.com', 1, 1, CURRENT_TIMESTAMP),
('liangyongqi', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '梁咏琪', 'liangyongqi@example.com', 1, 1, CURRENT_TIMESTAMP),
('chenhuilin', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '陈慧琳', 'chenhuilin@example.com', 1, 1, CURRENT_TIMESTAMP),
('zhengxiuwen', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '郑秀文', 'zhengxiuwen@example.com', 1, 1, CURRENT_TIMESTAMP),
('rongzuier', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '容祖儿', 'rongzuier@example.com', 1, 1, CURRENT_TIMESTAMP),
('yangqianhua', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '杨千嬅', 'yangqianhua@example.com', 1, 1, CURRENT_TIMESTAMP),
('caizhuoyan', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '蔡卓妍', 'caizhuoyan@example.com', 1, 1, CURRENT_TIMESTAMP),
('zhongxintong', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '钟欣潼', 'zhongxintong@example.com', 1, 1, CURRENT_TIMESTAMP),
('wangxinling', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '王心凌', 'wangxinling@example.com', 1, 1, CURRENT_TIMESTAMP),
('xiaoyaxuan', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '萧亚轩', 'xiaoyaxuan@example.com', 1, 1, CURRENT_TIMESTAMP),
('wenlan', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '温岚', 'wenlan@example.com', 1, 1, CURRENT_TIMESTAMP),
('xuhuixin', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '许慧欣', 'xuhuixin@example.com', 1, 1, CURRENT_TIMESTAMP),
('jinsasha', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '金莎', 'jinsasha@example.com', 1, 1, CURRENT_TIMESTAMP),
('xianzi', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '弦子', 'xianzi@example.com', 1, 1, CURRENT_TIMESTAMP),
('xujiaying', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '徐佳莹', 'xujiaying@example.com', 1, 1, CURRENT_TIMESTAMP),
('aiyiliang', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '艾怡良', 'aiyiliang@example.com', 1, 1, CURRENT_TIMESTAMP),
('yangnaiwen', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '杨乃文', 'yangnaiwen@example.com', 1, 1, CURRENT_TIMESTAMP),
('pengjiahui', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '彭佳慧', 'pengjiahui@example.com', 1, 1, CURRENT_TIMESTAMP),
('huangqishan', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '黄绮珊', 'huangqishan@example.com', 1, 1, CURRENT_TIMESTAMP),
('tanweiwei', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '谭维维', 'tanweiwei@example.com', 1, 1, CURRENT_TIMESTAMP),
('yukewei', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '郁可唯', 'yukewei@example.com', 1, 1, CURRENT_TIMESTAMP),
('liuxijun', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '刘惜君', 'liuxijun@example.com', 1, 1, CURRENT_TIMESTAMP),
('caichunjia', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '蔡淳佳', 'caichunjia@example.com', 1, 1, CURRENT_TIMESTAMP),
('guojing', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '郭静', 'guojing@example.com', 1, 1, CURRENT_TIMESTAMP),
('liangwenyin', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '梁文音', 'liangwenyin@example.com', 1, 1, CURRENT_TIMESTAMP),
('huangliling', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '黄丽玲', 'huangliling@example.com', 1, 1, CURRENT_TIMESTAMP),
('lijiawei', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '李佳薇', 'lijiawei@example.com', 1, 1, CURRENT_TIMESTAMP),
('chenfangyu', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '陈芳语', 'chenfangyu@example.com', 1, 1, CURRENT_TIMESTAMP),
('yuwenwen', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '于文文', 'yuwenwen@example.com', 1, 1, CURRENT_TIMESTAMP),
('huangling', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '黄龄', 'huangling@example.com', 1, 1, CURRENT_TIMESTAMP),
-- 新生代男歌手
('zhoushen', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '周深', 'zhoushen@example.com', 1, 1, CURRENT_TIMESTAMP),
('maobuyi', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '毛不易', 'maobuyi@example.com', 1, 1, CURRENT_TIMESTAMP),
('lijian', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '李健', 'lijian@example.com', 1, 1, CURRENT_TIMESTAMP),
('zhangjie', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '张杰', 'zhangjie@example.com', 1, 1, CURRENT_TIMESTAMP),
('huachenyu', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '华晨宇', 'huachenyu@example.com', 1, 1, CURRENT_TIMESTAMP),
('zhangyixing', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '张艺兴', 'zhangyixing@example.com', 1, 1, CURRENT_TIMESTAMP),
('yiyangqianxi', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '易烊千玺', 'yiyangqianxi@example.com', 1, 1, CURRENT_TIMESTAMP),
('wangjunkai', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '王俊凯', 'wangjunkai@example.com', 1, 1, CURRENT_TIMESTAMP),
('wangyuan', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '王源', 'wangyuan@example.com', 1, 1, CURRENT_TIMESTAMP),
('chenweiting', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '陈伟霆', 'chenweiting@example.com', 1, 1, CURRENT_TIMESTAMP),
('gujuji', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '古巨基', 'gujuji@example.com', 1, 1, CURRENT_TIMESTAMP),
('likeqin', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '李克勤', 'likeqin@example.com', 1, 1, CURRENT_TIMESTAMP),
('weichen', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '魏晨', 'weichen@example.com', 1, 1, CURRENT_TIMESTAMP),
('yuhaoming', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '俞灏明', 'yuhaoming@example.com', 1, 1, CURRENT_TIMESTAMP),
('suxing', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '苏醒', 'suxing@example.com', 1, 1, CURRENT_TIMESTAMP),
('wangyuexin', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '王栎鑫', 'wangyuexin@example.com', 1, 1, CURRENT_TIMESTAMP),
('chenchusheng', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '陈楚生', 'chenchusheng@example.com', 1, 1, CURRENT_TIMESTAMP),
('ouhao', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '欧豪', 'ouhao@example.com', 1, 1, CURRENT_TIMESTAMP),
('baijugang', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '白举纲', 'baijugang@example.com', 1, 1, CURRENT_TIMESTAMP),
('ninghuanyu', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '宁桓宇', 'ninghuanyu@example.com', 1, 1, CURRENT_TIMESTAMP),
('yutian', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '于湉', 'yutian@example.com', 1, 1, CURRENT_TIMESTAMP),
('zhaolei', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '赵雷', 'zhaolei@example.com', 1, 1, CURRENT_TIMESTAMP),
('songdongye', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '宋冬野', 'songdongye@example.com', 1, 1, CURRENT_TIMESTAMP),
('madi', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '马頔', 'madi@example.com', 1, 1, CURRENT_TIMESTAMP),
('yanchengxu', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '言承旭', 'yanchengxu@example.com', 1, 1, CURRENT_TIMESTAMP),
('zhouyumin', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '周渝民', 'zhouyumin@example.com', 1, 1, CURRENT_TIMESTAMP),
('wujianghao', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '吴建豪', 'wujianghao@example.com', 1, 1, CURRENT_TIMESTAMP),
('zhuxiaotian', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '朱孝天', 'zhuxiaotian@example.com', 1, 1, CURRENT_TIMESTAMP),
-- 新生代女歌手
('shanyichun', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '单依纯', 'shanyichun@example.com', 1, 1, CURRENT_TIMESTAMP),
('yuanyawei', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '袁娅维', 'yuanyawei@example.com', 1, 1, CURRENT_TIMESTAMP),
('jikejunyi', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '吉克隽逸', 'jikejunyi@example.com', 1, 1, CURRENT_TIMESTAMP),
('jiangyingrong', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '江映蓉', 'jiangyingrong@example.com', 1, 1, CURRENT_TIMESTAMP),
('lixiaoyun', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '李霄云', 'lixiaoyun@example.com', 1, 1, CURRENT_TIMESTAMP),
('liuxin', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '刘忻', 'liuxin@example.com', 1, 1, CURRENT_TIMESTAMP),
('sumiaoling', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '苏妙玲', 'sumiaoling@example.com', 1, 1, CURRENT_TIMESTAMP),
('duanlinxi', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '段林希', 'duanlinxi@example.com', 1, 1, CURRENT_TIMESTAMP),
('chenli', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '陈粒', 'chenli@example.com', 1, 1, CURRENT_TIMESTAMP),
('fangdongdemao', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '房东的猫', 'fangdongdemao@example.com', 1, 1, CURRENT_TIMESTAMP),
('zhaojingyi', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '赵静怡', 'zhaojingyi@example.com', 1, 1, CURRENT_TIMESTAMP),
('liangjing', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '梁静', 'liangjing@example.com', 1, 1, CURRENT_TIMESTAMP),
('wuyi', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '吴依', 'wuyi@example.com', 1, 1, CURRENT_TIMESTAMP),
('chenxuehan', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '陈雪涵', 'chenxuehan@example.com', 1, 1, CURRENT_TIMESTAMP),
('linyixin', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '林忆欣', 'linyixin@example.com', 1, 1, CURRENT_TIMESTAMP),
('zoujuan', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '邹卷', 'zoujuan@example.com', 1, 1, CURRENT_TIMESTAMP),
('wangziwen', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '王子文', 'wangziwen@example.com', 1, 1, CURRENT_TIMESTAMP),
('liutong', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '刘桐', 'liutong@example.com', 1, 1, CURRENT_TIMESTAMP),
('zhaoman', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '赵曼', 'zhaoman@example.com', 1, 1, CURRENT_TIMESTAMP),
('sunjie', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '孙洁', 'sunjie@example.com', 1, 1, CURRENT_TIMESTAMP),
-- 组合/乐队歌手
('wuqingfeng', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '吴青峰', 'wuqingfeng@example.com', 1, 1, CURRENT_TIMESTAMP),
('axin', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '阿信', 'axin@example.com', 1, 1, CURRENT_TIMESTAMP),
('xin', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '信', 'xin@example.com', 1, 1, CURRENT_TIMESTAMP),
('sodagreen', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '苏打绿', 'sodagreen@example.com', 1, 1, CURRENT_TIMESTAMP),
('wuyuetian', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '五月天', 'wuyuetian@example.com', 1, 1, CURRENT_TIMESTAMP),
('twins', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', 'Twins', 'twins@example.com', 1, 1, CURRENT_TIMESTAMP),
('nanquanmama', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '南拳妈妈', 'nanquanmama@example.com', 1, 1, CURRENT_TIMESTAMP),
('she', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', 'S.H.E', 'she@example.com', 1, 1, CURRENT_TIMESTAMP),
('zhengyilun', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '郑逸伦', 'zhengyilun@example.com', 1, 1, CURRENT_TIMESTAMP),
('jiangjun', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '姜军', 'jiangjun@example.com', 1, 1, CURRENT_TIMESTAMP),
('chenhao', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '陈浩', 'chenhao@example.com', 1, 1, CURRENT_TIMESTAMP),
('liujun', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '刘军', 'liujun@example.com', 1, 1, CURRENT_TIMESTAMP),
('zhanghao', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '张浩', 'zhanghao@example.com', 1, 1, CURRENT_TIMESTAMP),
('wanghao', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '王浩', 'wanghao@example.com', 1, 1, CURRENT_TIMESTAMP),
('zhaojun', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '赵军', 'zhaojun@example.com', 1, 1, CURRENT_TIMESTAMP),
('sunhao', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '孙浩', 'sunhao@example.com', 1, 1, CURRENT_TIMESTAMP),
('lihao', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '李浩', 'lihao@example.com', 1, 1, CURRENT_TIMESTAMP),
('chenjun', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '陈军', 'chenjun@example.com', 1, 1, CURRENT_TIMESTAMP),
('wangjun', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '王军', 'wangjun@example.com', 1, 1, CURRENT_TIMESTAMP),
('zhangjun', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '张军', 'zhangjun@example.com', 1, 1, CURRENT_TIMESTAMP),
('lihao', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '李昊', 'lihao2@example.com', 1, 1, CURRENT_TIMESTAMP),
('chenhao', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '陈昊', 'chenhao2@example.com', 1, 1, CURRENT_TIMESTAMP),
('zhaohao', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '赵昊', 'zhaohao@example.com', 1, 1, CURRENT_TIMESTAMP),
('sunjun', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '孙军', 'sunjun@example.com', 1, 1, CURRENT_TIMESTAMP),
('zhouhao', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '周昊', 'zhouhao@example.com', 1, 1, CURRENT_TIMESTAMP),
('wuhao', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '吴昊', 'wuhao@example.com', 1, 1, CURRENT_TIMESTAMP),
('xuhao', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '徐昊', 'xuhao@example.com', 1, 1, CURRENT_TIMESTAMP),
('huhao', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '胡昊', 'huhao@example.com', 1, 1, CURRENT_TIMESTAMP),
('guohao', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '郭昊', 'guohao@example.com', 1, 1, CURRENT_TIMESTAMP),
('mahao', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '马昊', 'mahao@example.com', 1, 1, CURRENT_TIMESTAMP),
('zhanhao', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '詹昊', 'zhanhao@example.com', 1, 1, CURRENT_TIMESTAMP),
('fanghao', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '方昊', 'fanghao@example.com', 1, 1, CURRENT_TIMESTAMP),
('donghao', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '董昊', 'donghao@example.com', 1, 1, CURRENT_TIMESTAMP),
('xiehao', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '谢昊', 'xiehao@example.com', 1, 1, CURRENT_TIMESTAMP),
('wanhao', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '万昊', 'wanhao@example.com', 1, 1, CURRENT_TIMESTAMP),
('tanghao', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '唐昊', 'tanghao@example.com', 1, 1, CURRENT_TIMESTAMP),
('jianghao', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '姜昊', 'jianghao@example.com', 1, 1, CURRENT_TIMESTAMP),
('yuhao', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '于昊', 'yuhao@example.com', 1, 1, CURRENT_TIMESTAMP),
('hehao', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '何昊', 'hehao@example.com', 1, 1, CURRENT_TIMESTAMP),
('linhao', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '林昊', 'linhao@example.com', 1, 1, CURRENT_TIMESTAMP),
('gaohao', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '高昊', 'gaohao@example.com', 1, 1, CURRENT_TIMESTAMP),
('zouhao', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '邹昊', 'zouhao@example.com', 1, 1, CURRENT_TIMESTAMP),
('chaihao', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '柴昊', 'chaihao@example.com', 1, 1, CURRENT_TIMESTAMP),
('songhao', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '宋昊', 'songhao@example.com', 1, 1, CURRENT_TIMESTAMP),
('zhuhao', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '朱昊', 'zhuhao@example.com', 1, 1, CURRENT_TIMESTAMP),
('kanghao', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '康昊', 'kanghao@example.com', 1, 1, CURRENT_TIMESTAMP),
('shaohao', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '邵昊', 'shaohao@example.com', 1, 1, CURRENT_TIMESTAMP),
('wanjun', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '万军', 'wanjun@example.com', 1, 1, CURRENT_TIMESTAMP),
('tangjun', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '唐军', 'tangjun@example.com', 1, 1, CURRENT_TIMESTAMP),
('jiangjun', '$2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O', '江军', 'jiangjun2@example.com', 1, 1, CURRENT_TIMESTAMP);

-- 插入musician
-- 插入150位音乐人，通过user表username关联获取user_id
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
        WHEN 'liangyongqi' THEN '梁咏琪'
        WHEN 'chenhuilin' THEN '陈慧琳'
        WHEN 'zhengxiuwen' THEN '郑秀文'
        WHEN 'rongzuier' THEN '容祖儿'
        WHEN 'yangqianhua' THEN '杨千嬅'
        WHEN 'caizhuoyan' THEN '蔡卓妍'
        WHEN 'zhongxintong' THEN '钟欣潼'
        WHEN 'wangxinling' THEN '王心凌'
        WHEN 'xiaoyaxuan' THEN '萧亚轩'
        WHEN 'wenlan' THEN '温岚'
        WHEN 'xuhuixin' THEN '许慧欣'
        WHEN 'jinsasha' THEN '金莎'
        WHEN 'xianzi' THEN '弦子'
        WHEN 'xujiaying' THEN '徐佳莹'
        WHEN 'aiyiliang' THEN '艾怡良'
        WHEN 'yangnaiwen' THEN '杨乃文'
        WHEN 'pengjiahui' THEN '彭佳慧'
        WHEN 'huangqishan' THEN '黄绮珊'
        WHEN 'tanweiwei' THEN '谭维维'
        WHEN 'yukewei' THEN '郁可唯'
        WHEN 'liuxijun' THEN '刘惜君'
        WHEN 'caichunjia' THEN '蔡淳佳'
        WHEN 'guojing' THEN '郭静'
        WHEN 'liangwenyin' THEN '梁文音'
        WHEN 'huangliling' THEN '黄丽玲'
        WHEN 'lijiawei' THEN '李佳薇'
        WHEN 'chenfangyu' THEN '陈芳语'
        WHEN 'yuwenwen' THEN '于文文'
        WHEN 'huangling' THEN '黄龄'
        -- 新生代男歌手
        WHEN 'zhoushen' THEN '周深'
        WHEN 'maobuyi' THEN '毛不易'
        WHEN 'lijian' THEN '李健'
        WHEN 'zhangjie' THEN '张杰'
        WHEN 'huachenyu' THEN '华晨宇'
        WHEN 'zhangyixing' THEN '张艺兴'
        WHEN 'yiyangqianxi' THEN '易烊千玺'
        WHEN 'wangjunkai' THEN '王俊凯'
        WHEN 'wangyuan' THEN '王源'
        WHEN 'chenweiting' THEN '陈伟霆'
        WHEN 'gujuji' THEN '古巨基'
        WHEN 'likeqin' THEN '李克勤'
        WHEN 'weichen' THEN '魏晨'
        WHEN 'yuhaoming' THEN '俞灏明'
        WHEN 'suxing' THEN '苏醒'
        WHEN 'wangyuexin' THEN '王栎鑫'
        WHEN 'chenchusheng' THEN '陈楚生'
        WHEN 'ouhao' THEN '欧豪'
        WHEN 'baijugang' THEN '白举纲'
        WHEN 'ninghuanyu' THEN '宁桓宇'
        WHEN 'yutian' THEN '于湉'
        WHEN 'zhaolei' THEN '赵雷'
        WHEN 'songdongye' THEN '宋冬野'
        WHEN 'madi' THEN '马頔'
        WHEN 'yanchengxu' THEN '言承旭'
        WHEN 'zhouyumin' THEN '周渝民'
        WHEN 'wujianghao' THEN '吴建豪'
        WHEN 'zhuxiaotian' THEN '朱孝天'
        -- 新生代女歌手
        WHEN 'shanyichun' THEN '单依纯'
        WHEN 'yuanyawei' THEN '袁娅维'
        WHEN 'jikejunyi' THEN '吉克隽逸'
        WHEN 'jiangyingrong' THEN '江映蓉'
        WHEN 'lixiaoyun' THEN '李霄云'
        WHEN 'liuxin' THEN '刘忻'
        WHEN 'sumiaoling' THEN '苏妙玲'
        WHEN 'duanlinxi' THEN '段林希'
        WHEN 'chenli' THEN '陈粒'
        WHEN 'fangdongdemao' THEN '房东的猫'
        WHEN 'zhaojingyi' THEN '赵静怡'
        WHEN 'liangjing' THEN '梁静'
        WHEN 'wuyi' THEN '吴依'
        WHEN 'chenxuehan' THEN '陈雪涵'
        WHEN 'linyixin' THEN '林忆欣'
        WHEN 'zoujuan' THEN '邹卷'
        WHEN 'wangziwen' THEN '王子文'
        WHEN 'liutong' THEN '刘桐'
        WHEN 'zhaoman' THEN '赵曼'
        WHEN 'sunjie' THEN '孙洁'
        -- 组合/乐队歌手
        WHEN 'wuqingfeng' THEN '吴青峰'
        WHEN 'axin' THEN '阿信'
        WHEN 'xin' THEN '信'
        WHEN 'sodagreen' THEN '苏打绿'
        WHEN 'wuyuetian' THEN '五月天'
        WHEN 'twins' THEN 'Twins'
        WHEN 'nanquanmama' THEN '南拳妈妈'
        WHEN 'she' THEN 'S.H.E'
        WHEN 'zhengyilun' THEN '郑逸伦'
        WHEN 'jiangjun' THEN '姜军'
        WHEN 'chenhao' THEN '陈浩'
        WHEN 'liujun' THEN '刘军'
        WHEN 'zhanghao' THEN '张浩'
        WHEN 'wanghao' THEN '王浩'
        WHEN 'zhaojun' THEN '赵军'
        WHEN 'sunhao' THEN '孙浩'
        WHEN 'lihao' THEN '李浩'
        WHEN 'chenjun' THEN '陈军'
        WHEN 'wangjun' THEN '王军'
        WHEN 'zhangjun' THEN '张军'
        WHEN 'lihao2' THEN '李昊'
        WHEN 'chenhao2' THEN '陈昊'
        WHEN 'zhaohao' THEN '赵昊'
        WHEN 'sunjun' THEN '孙军'
        WHEN 'zhouhao' THEN '周昊'
        WHEN 'wuhao' THEN '吴昊'
        WHEN 'xuhao' THEN '徐昊'
        WHEN 'huhao' THEN '胡昊'
        WHEN 'guohao' THEN '郭昊'
        WHEN 'mahao' THEN '马昊'
        WHEN 'zhanhao' THEN '詹昊'
        WHEN 'fanghao' THEN '方昊'
        WHEN 'donghao' THEN '董昊'
        WHEN 'xiehao' THEN '谢昊'
        WHEN 'wanhao' THEN '万昊'
        WHEN 'tanghao' THEN '唐昊'
        WHEN 'jianghao' THEN '姜昊'
        WHEN 'yuhao' THEN '于昊'
        WHEN 'hehao' THEN '何昊'
        WHEN 'linhao' THEN '林昊'
        WHEN 'gaohao' THEN '高昊'
        WHEN 'zouhao' THEN '邹昊'
        WHEN 'chaihao' THEN '柴昊'
        WHEN 'songhao' THEN '宋昊'
        WHEN 'zhuhao' THEN '朱昊'
        WHEN 'kanghao' THEN '康昊'
        WHEN 'shaohao' THEN '邵昊'
        WHEN 'wanjun' THEN '万军'
        WHEN 'tangjun' THEN '唐军'
        WHEN 'jiangjun2' THEN '江军'
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
     'caijianya', 'tianfuzhen', 'chenqizhen', 'mowenwei', 'liangyongqi', 'chenhuilin', 'zhengxiuwen', 'rongzuier',
     'yangqianhua', 'caizhuoyan', 'zhongxintong', 'wangxinling', 'xiaoyaxuan', 'wenlan', 'xuhuixin', 'jinsasha',
     'xianzi', 'xujiaying', 'aiyiliang', 'yangnaiwen', 'pengjiahui', 'huangqishan', 'tanweiwei', 'yukewei',
     'liuxijun', 'caichunjia', 'guojing', 'liangwenyin', 'huangliling', 'lijiawei', 'chenfangyu', 'yuwenwen',
     'huangling', 'zhoushen', 'maobuyi', 'lijian', 'zhangjie', 'huachenyu', 'zhangyixing', 'yiyangqianxi',
     'wangjunkai', 'wangyuan', 'chenweiting', 'gujuji', 'likeqin', 'weichen', 'yuhaoming', 'suxing',
     'wangyuexin', 'chenchusheng', 'ouhao', 'baijugang', 'ninghuanyu', 'yutian', 'zhaolei', 'songdongye',
     'madi', 'yanchengxu', 'zhouyumin', 'wujianghao', 'zhuxiaotian', 'shanyichun', 'yuanyawei', 'jikejunyi',
     'jiangyingrong', 'lixiaoyun', 'liuxin', 'sumiaoling', 'duanlinxi', 'chenli', 'fangdongdemao', 'zhaojingyi',
     'liangjing', 'wuyi', 'chenxuehan', 'linyixin', 'zoujuan', 'wangziwen', 'liutong', 'zhaoman',
     'sunjie', 'wuqingfeng', 'axin', 'xin', 'sodagreen', 'wuyuetian', 'twins', 'nanquanmama',
     'she', 'zhengyilun', 'jiangjun', 'chenhao', 'liujun', 'zhanghao', 'wanghao', 'zhaojun',
     'sunhao', 'lihao', 'chenjun', 'wangjun', 'zhangjun', 'lihao2', 'chenhao2', 'zhaohao',
     'sunjun', 'zhouhao', 'wuhao', 'xuhao', 'huhao', 'guohao', 'mahao', 'zhanhao',
     'fanghao', 'donghao', 'xiehao', 'wanhao', 'tanghao', 'jianghao', 'yuhao', 'hehao',
     'linhao', 'gaohao', 'zouhao', 'chaihao', 'songhao', 'zhuhao', 'kanghao', 'shaohao',
     'wanjun', 'tangjun', 'jiangjun2'
);

-- role_user
-- 关联150位歌手用户与ROLE_MUSICIAN角色
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
    'caijianya', 'tianfuzhen', 'chenqizhen', 'mowenwei', 'liangyongqi', 'chenhuilin', 'zhengxiuwen', 'rongzuier',
    'yangqianhua', 'caizhuoyan', 'zhongxintong', 'wangxinling', 'xiaoyaxuan', 'wenlan', 'xuhuixin', 'jinsasha',
    'xianzi', 'xujiaying', 'aiyiliang', 'yangnaiwen', 'pengjiahui', 'huangqishan', 'tanweiwei', 'yukewei',
    'liuxijun', 'caichunjia', 'guojing', 'liangwenyin', 'huangliling', 'lijiawei', 'chenfangyu', 'yuwenwen',
    'huangling', 'zhoushen', 'maobuyi', 'lijian', 'zhangjie', 'huachenyu', 'zhangyixing', 'yiyangqianxi',
    'wangjunkai', 'wangyuan', 'chenweiting', 'gujuji', 'likeqin', 'weichen', 'yuhaoming', 'suxing',
    'wangyuexin', 'chenchusheng', 'ouhao', 'baijugang', 'ninghuanyu', 'yutian', 'zhaolei', 'songdongye',
    'madi', 'yanchengxu', 'zhouyumin', 'wujianghao', 'zhuxiaotian', 'shanyichun', 'yuanyawei', 'jikejunyi',
    'jiangyingrong', 'lixiaoyun', 'liuxin', 'sumiaoling', 'duanlinxi', 'chenli', 'fangdongdemao', 'zhaojingyi',
    'liangjing', 'wuyi', 'chenxuehan', 'linyixin', 'zoujuan', 'wangziwen', 'liutong', 'zhaoman',
    'sunjie', 'wuqingfeng', 'axin', 'xin', 'sodagreen', 'wuyuetian', 'twins', 'nanquanmama',
    'she', 'zhengyilun', 'jiangjun', 'chenhao', 'liujun', 'zhanghao', 'wanghao', 'zhaojun',
    'sunhao', 'lihao', 'chenjun', 'wangjun', 'zhangjun', 'lihao2', 'chenhao2', 'zhaohao',
    'sunjun', 'zhouhao', 'wuhao', 'xuhao', 'huhao', 'guohao', 'mahao', 'zhanhao',
    'fanghao', 'donghao', 'xiehao', 'wanhao', 'tanghao', 'jianghao', 'yuhao', 'hehao',
    'linhao', 'gaohao', 'zouhao', 'chaihao', 'songhao', 'zhuhao', 'kanghao', 'shaohao',
    'wanjun', 'tangjun', 'jiangjun2'
);