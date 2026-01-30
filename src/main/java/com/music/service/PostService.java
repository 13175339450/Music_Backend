package com.music.service;

import com.music.dto.PostDTO;
import com.music.entity.Post;
import com.music.entity.PostLike;
import com.music.entity.User;
import com.music.repository.PostLikeRepository;
import com.music.repository.PostRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@Transactional
public class PostService {
    @Autowired
    private PostRepository postRepository;
    
    @Autowired
    private PostLikeRepository postLikeRepository;
    
    public Post createPost(Post post) {
        // 检查用户是否为管理员，如果是则自动通过审核
        if (isAdmin(post.getUser())) {
            post.setStatus(2); // 2表示已通过审核
        } else {
            post.setStatus(1); // 1表示待审核
        }
        return postRepository.save(post);
    }
    
    // 检查用户是否为管理员
    private boolean isAdmin(User user) {
        if (user == null || user.getRoles() == null) {
            return false;
        }
        return user.getRoles().stream()
                .anyMatch(role -> "ROLE_ADMIN".equals(role.getName()));
    }
    
    public Post updatePost(Post post) {
        Post existing = postRepository.findById(post.getId())
                .orElseThrow(() -> new IllegalArgumentException("Post not found"));
        
        if (post.getContent() != null) {
            existing.setContent(post.getContent());
        }
        if (post.getImageUrls() != null) {
            existing.setImageUrls(post.getImageUrls());
        }
        return postRepository.save(existing);
    }
    
    public void deletePost(Long postId) {
        postRepository.deleteById(postId);
    }
    
    public Optional<Post> getPostById(Long postId) {
        return postRepository.findById(postId);
    }
    
    public List<Post> getAllPosts() {
        return postRepository.findAllWithUser();
    }
    
    public List<Post> getPostsByUserId(Long userId) {
        return postRepository.findByUserIdWithUser(userId);
    }
    
    // 分页查询动态（包含点赞状态）
    public List<PostDTO> getPostsWithLikeStatus(Pageable pageable, Long currentUserId, boolean isAdmin) {
        List<Post> posts;
        if (isAdmin) {
            // 管理员可以看到所有动态（待审核、已通过、已拒绝）
            posts = postRepository.findAllPostsWithUserForAdmin(pageable);
        } else {
            // 普通用户只能看到已通过审核的动态
            posts = postRepository.findAllWithUser(pageable);
        }
        
        return posts.stream()
                .map(post -> {
                    boolean isLiked = postLikeRepository.existsByUserIdAndPostId(currentUserId, post.getId());
                    return PostDTO.fromPost(post, isLiked);
                })
                .collect(Collectors.toList());
    }
    
    // 获取单个动态（包含点赞状态）
    public Optional<PostDTO> getPostWithLikeStatus(Long postId, Long currentUserId, boolean isAdmin) {
        return postRepository.findById(postId)
                .filter(post -> isAdmin || post.getStatus() == 2) // 非管理员只能查看已通过审核的动态
                .map(post -> {
                    boolean isLiked = postLikeRepository.existsByUserIdAndPostId(currentUserId, post.getId());
                    return PostDTO.fromPost(post, isLiked);
                });
    }
    
    // 分页查询（返回Page对象）
    public Page<Post> getPostsPage(Pageable pageable) {
        return postRepository.findAllPosts(pageable);
    }
    
    public void sharePost(Long postId) {
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new IllegalArgumentException("Post not found"));
        post.setShareCount(post.getShareCount() + 1);
        postRepository.save(post);
    }
    
    // 获取待审核的动态
    public List<Post> getPendingPosts() {
        return postRepository.findPendingPostsWithUser();
    }
    
    // 管理员审核动态（通过）
    public Post approvePost(Long postId) {
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new IllegalArgumentException("Dynamic not found"));
        
        post.setStatus(2); // 2表示已通过审核
        return postRepository.save(post);
    }
    
    // 管理员审核动态（拒绝）
    public Post rejectPost(Long postId) {
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new IllegalArgumentException("Dynamic not found"));
        
        post.setStatus(3); // 3表示已拒绝
        return postRepository.save(post);
    }
    
    // 点赞动态
    public void likePost(Long postId, User user) {
        // 检查动态是否存在
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new IllegalArgumentException("Dynamic not found"));
        
        // 检查动态是否已通过审核
        if (post.getStatus() != 2) {
            throw new IllegalArgumentException("Cannot like a post that is not approved");
        }
        
        // 检查用户是否已经点赞
        if (!postLikeRepository.existsByUserIdAndPostId(user.getId(), postId)) {
            // 创建点赞记录
            PostLike postLike = new PostLike();
            postLike.setUser(user);
            postLike.setPost(post);
            postLikeRepository.save(postLike);
            
            // 更新动态的点赞数
            post.setLikeCount(post.getLikeCount() + 1);
            postRepository.save(post);
        }
    }
    
    // 取消点赞动态
    public void unlikePost(Long postId, User user) {
        // 检查动态是否存在
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new IllegalArgumentException("Dynamic not found"));
        
        // 检查动态是否已通过审核
        if (post.getStatus() != 2) {
            throw new IllegalArgumentException("Cannot unlike a post that is not approved");
        }
        
        // 检查用户是否已经点赞
        postLikeRepository.findByUserIdAndPostId(user.getId(), postId)
                .ifPresent(postLike -> {
                    // 删除点赞记录
                    postLikeRepository.delete(postLike);
                    
                    // 更新动态的点赞数
                    if (post.getLikeCount() > 0) {
                        post.setLikeCount(post.getLikeCount() - 1);
                        postRepository.save(post);
                    }
                });
    }
}