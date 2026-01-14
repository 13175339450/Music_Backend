package com.music.repository;

import com.music.entity.Post;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;

public interface PostRepository extends JpaRepository<Post, Long> {
    List<Post> findByUserId(Long userId);
    
    @Query("SELECT p FROM Post p JOIN FETCH p.user WHERE p.status = 2 ORDER BY p.createdAt DESC")
    List<Post> findAllWithUser();
    
    @Query("SELECT p FROM Post p JOIN FETCH p.user WHERE p.user.id = :userId AND p.status = 2 ORDER BY p.createdAt DESC")
    List<Post> findByUserIdWithUser(@Param("userId") Long userId);
    
    // 分页查询已审核通过的动态
    @Query("SELECT p FROM Post p WHERE p.status = 2 ORDER BY p.createdAt DESC")
    Page<Post> findAllPosts(Pageable pageable);
    
    // 带用户信息的分页查询已审核通过的动态
    @Query("SELECT p FROM Post p LEFT JOIN FETCH p.user WHERE p.status = 2 ORDER BY p.createdAt DESC")
    List<Post> findAllWithUser(Pageable pageable);
    
    // 管理员查询所有动态（包括待审核、已通过、已拒绝）
    @Query("SELECT p FROM Post p LEFT JOIN FETCH p.user ORDER BY p.createdAt DESC")
    List<Post> findAllPostsWithUserForAdmin(Pageable pageable);
    
    // 管理员查询待审核的动态
    @Query("SELECT p FROM Post p LEFT JOIN FETCH p.user WHERE p.status = 1 ORDER BY p.createdAt DESC")
    List<Post> findPendingPostsWithUser();
    
    // 按状态查询动态（管理员使用）
    @Query("SELECT p FROM Post p LEFT JOIN FETCH p.user WHERE p.status = :status ORDER BY p.createdAt DESC")
    List<Post> findPostsByStatusWithUser(@Param("status") Integer status);
}
