package com.music.config;

import com.music.entity.Role;
import com.music.entity.User;
import com.music.repository.RoleRepository;
import com.music.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.util.Collections;
import java.util.Date;

@Component
public class DataInitializer implements CommandLineRunner {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private RoleRepository roleRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) throws Exception {
        // 创建ADMIN角色
        Role adminRole = roleRepository.findByName("ROLE_ADMIN")
                .orElseGet(() -> {
                    Role role = new Role();
                    role.setName("ROLE_ADMIN");
                    role.setDescription("管理员角色");
                    return roleRepository.save(role);
                });

        // 创建USER角色
        Role userRole = roleRepository.findByName("ROLE_USER")
                .orElseGet(() -> {
                    Role role = new Role();
                    role.setName("ROLE_USER");
                    role.setDescription("普通用户角色");
                    return roleRepository.save(role);
                });

        // 创建MUSICIAN角色
        Role musicianRole = roleRepository.findByName("ROLE_MUSICIAN")
                .orElseGet(() -> {
                    Role role = new Role();
                    role.setName("ROLE_MUSICIAN");
                    role.setDescription("音乐人角色");
                    return roleRepository.save(role);
                });

        // 创建管理员用户
        User admin = userRepository.findByUsername("admin")
                .orElseGet(() -> {
                    User user = new User();
                    user.setUsername("admin");
                    user.setPassword(passwordEncoder.encode("admin23"));
                    user.setNickname("管理员");
                    user.setEmail("admin@example.com");
                    user.setStatus(1);
                    user.setIsMusician(0);
                    user.setRegisterTime(new Date());
                    user.setRoles(Collections.singletonList(adminRole));
                    return userRepository.save(user);
                });
        admin.setStatus(1);
        admin.setRegisterTime(new Date());
        admin.setRoles(Collections.singletonList(adminRole));
        userRepository.save(admin);

        // 创建普通用户
        User user1 = userRepository.findByUsername("user1")
                .orElseGet(() -> {
                    User user = new User();
                    user.setUsername("user1");
                    user.setPassword(passwordEncoder.encode("password123"));
                    user.setNickname("普通用户");
                    user.setEmail("user1@example.com");
                    user.setStatus(1);
                    user.setIsMusician(0);
                    user.setRegisterTime(new Date());
                    user.setRoles(Collections.singletonList(userRole));
                    return userRepository.save(user);
                });
        user1.setStatus(1);
        user1.setRegisterTime(new Date());
        user1.setRoles(Collections.singletonList(userRole));
        userRepository.save(user1);

        // 创建音乐人用户
        User musician1 = userRepository.findByUsername("musician1")
                .orElseGet(() -> {
                    User user = new User();
                    user.setUsername("musician1");
                    user.setPassword(passwordEncoder.encode("password123"));
                    user.setNickname("音乐人");
                    user.setEmail("musician1@example.com");
                    user.setStatus(1);
                    user.setIsMusician(1);
                    user.setRegisterTime(new Date());
                    user.setRoles(Collections.singletonList(musicianRole));
                    return userRepository.save(user);
                });
        musician1.setStatus(1);
        musician1.setRegisterTime(new Date());
        musician1.setRoles(Collections.singletonList(musicianRole));
        userRepository.save(musician1);
    }
}