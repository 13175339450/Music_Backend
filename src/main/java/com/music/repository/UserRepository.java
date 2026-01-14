package com.music.repository;

import com.music.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByUsername(String username);
    Optional<User> findByEmail(String email);
    Optional<User> findByPhone(String phone);
    Boolean existsByUsername(String username);
    Boolean existsByEmail(String email);
    Boolean existsByPhone(String phone);

    @Query("SELECT u FROM User u WHERE u.username LIKE %:keyword% OR u.nickname LIKE %:keyword% OR CAST(u.id AS string) LIKE %:keyword%")
    List<User> searchUsers(@Param("keyword") String keyword);

    @Query("SELECT u FROM User u JOIN u.roles r WHERE r.name = :roleName AND (u.username LIKE %:keyword% OR u.nickname LIKE %:keyword% OR CAST(u.id AS string) LIKE %:keyword%)")
    List<User> searchUsersByRole(@Param("keyword") String keyword, @Param("roleName") String roleName);
    
    @Query(value = "SELECT COUNT(*) FROM user WHERE DATE(register_time) = :date", nativeQuery = true)
    Long countByRegisterTime(@Param("date") String date);
    
    @Query(value = "SELECT COUNT(u.id) FROM user u JOIN user_role ur ON u.id = ur.user_id JOIN role r ON ur.role_id = r.id WHERE r.name = :roleName AND DATE(u.register_time) = :date", nativeQuery = true)
    Long countByRegisterTimeAndRole(@Param("date") String date, @Param("roleName") String roleName);
}