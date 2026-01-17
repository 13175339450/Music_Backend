package com.music;

import jakarta.annotation.Resource;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.crypto.password.PasswordEncoder;

@SpringBootTest
public class PassEncoderTest {

    @Resource
    private PasswordEncoder passwordEncoder;

    @Test
    public void test(){
        String password = passwordEncoder.encode("admin123");
        // $2a$10$BO5eb0y0m2uIniqdG/zd7.mdN6qxwAzKZLTEx58QrnLUFJQDIUu4O
        System.out.println(password);
    }
}
