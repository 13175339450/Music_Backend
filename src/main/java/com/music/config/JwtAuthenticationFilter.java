package com.music.config;

import com.music.entity.User;
import com.music.repository.UserRepository;
import com.music.util.JwtUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Enumeration;

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {
    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private UserDetailsService userDetailsService;

    @Autowired
    private UserRepository userRepository;

    @Value("${jwt.header}")
    private String header;
    
    private static final Logger logger = LoggerFactory.getLogger(JwtAuthenticationFilter.class);
    
    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) throws ServletException {
        String requestURI = request.getRequestURI();
        String method = request.getMethod();
        
        // 更简单直接的路径匹配
        // 由于context-path是/api，实际请求路径是/api/auth/login和/api/auth/register
        boolean isAuthPath = requestURI.equals("/api/auth/login") || requestURI.equals("/api/auth/register");
        boolean isPostMethod = method.equalsIgnoreCase("POST");
        boolean shouldNotFilter = isAuthPath && isPostMethod;
        
        // 添加关键日志
        System.err.println("[JWT FILTER] Checking if shouldNotFilter: URI=" + requestURI + ", Method=" + method + ", ShouldNotFilter=" + shouldNotFilter);
        logger.info("[JWT FILTER] shouldNotFilter check - URI: {}, Method: {}, ShouldNotFilter: {}", requestURI, method, shouldNotFilter);
        
        return shouldNotFilter;
    }
    


    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws ServletException, IOException {
        // 添加更详细的调试信息，确保能看到过滤器被执行
        System.err.println("[CRITICAL DEBUG] JwtAuthenticationFilter.doFilterInternal() STARTED");
        System.err.println("[CRITICAL DEBUG] Full Request URL: " + request.getRequestURL());
        System.err.println("[CRITICAL DEBUG] Request URI: " + request.getRequestURI());
        System.err.println("[CRITICAL DEBUG] Request Context Path: " + request.getContextPath());
        System.err.println("[CRITICAL DEBUG] Request Method: " + request.getMethod());
        
        logger.info("[JWT FILTER] Processing request: {} {}", request.getMethod(), request.getRequestURI());
        logger.info("[JWT FILTER] Full URL: {}", request.getRequestURL());
        logger.info("[JWT FILTER] Context Path: {}", request.getContextPath());
        
        // 特别检查是否是登录或注册请求，如果是直接放行，不进行任何处理
        String requestURI = request.getRequestURI();
        String method = request.getMethod();
        if ((requestURI.equals("/api/auth/login") || requestURI.equals("/api/auth/register")) && method.equalsIgnoreCase("POST")) {
            System.err.println("[CRITICAL DEBUG] This is an auth request (login/register), bypassing JWT validation completely");
            logger.info("[JWT FILTER] Auth request detected, bypassing JWT validation");
            filterChain.doFilter(request, response);
            return;
        }
        
        // 对于其他请求，继续进行JWT验证
        final String authorizationHeader = request.getHeader(header);
        System.out.println("[DEBUG] Authorization Header: " + authorizationHeader);
        logger.info("Authorization Header: {}", authorizationHeader);
        
        // 如果没有Authorization头，直接放行，让SecurityConfig处理权限检查
        if (authorizationHeader == null || !authorizationHeader.startsWith("Bearer ")) {
            System.out.println("[DEBUG] No valid Authorization header found, passing request to next filter");
            logger.info("No valid Authorization header found, passing request to next filter");
            filterChain.doFilter(request, response);
            return;
        }

        String username = null;
        String jwt = null;

        try {
            jwt = authorizationHeader.substring(7);
            username = jwtUtil.extractUsername(jwt);
            System.out.println("[DEBUG] Extracted username: " + username);
            logger.info("Extracted username: {}", username);
        } catch (Exception e) {
            System.out.println("[DEBUG] Error extracting username from token: " + e.getMessage());
            logger.error("Error extracting username from token: {}", e.getMessage());
            // 不要在这里抛出异常，而是继续传递请求，让后续过滤器处理
            filterChain.doFilter(request, response);
            return;
        }

        System.out.println("[DEBUG] Username: " + username);
        System.out.println("[DEBUG] SecurityContext Authentication before: " + SecurityContextHolder.getContext().getAuthentication());
        logger.info("Username: {}", username);
        logger.info("SecurityContextHolder.getContext().getAuthentication(): {}", SecurityContextHolder.getContext().getAuthentication());

        if (username != null && SecurityContextHolder.getContext().getAuthentication() == null) {
            System.out.println("[DEBUG] Username: " + username + " is not authenticated yet");
            logger.info("Username: {} is not authenticated yet", username);
            try {
                UserDetails userDetails = this.userDetailsService.loadUserByUsername(username);
                System.out.println("[DEBUG] Loaded user details: " + userDetails.getUsername() + ", Authorities: " + userDetails.getAuthorities() + ", Enabled: " + userDetails.isEnabled());
                logger.info("Loaded user details: {}, Authorities: {}, Enabled: {}", userDetails.getUsername(), userDetails.getAuthorities(), userDetails.isEnabled());

                System.out.println("[DEBUG] Token: " + jwt + ", Username: " + username);
                logger.info("Token: {}, Username: {}", jwt, username);
                
                // 使用从token中提取的username来验证token
                boolean isValid = jwtUtil.validateToken(jwt, username);
                System.out.println("[DEBUG] Token validation result: " + isValid);
                logger.info("Token validation result: {}", isValid);
                
                if (isValid) {
                    System.out.println("[DEBUG] Token is valid for user: " + username);
                    logger.info("Token is valid for user: {}", username);
                    
                    // 由于我们的User类已经实现了UserDetails接口，我们可以直接使用它
                    User user = userRepository.findByUsername(username).orElseThrow();
                    
                    UsernamePasswordAuthenticationToken usernamePasswordAuthenticationToken = new UsernamePasswordAuthenticationToken(
                            user, null, userDetails.getAuthorities());
                    usernamePasswordAuthenticationToken
                            .setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                    SecurityContextHolder.getContext().setAuthentication(usernamePasswordAuthenticationToken);
                    System.out.println("[DEBUG] Authentication set for user: " + username + ", Authentication: " + SecurityContextHolder.getContext().getAuthentication());
                    logger.info("Authentication set for user: {}, Authentication: {}", username, SecurityContextHolder.getContext().getAuthentication());
                } else {
                    System.out.println("[DEBUG] Token is invalid for user: " + username);
                    logger.info("Token is invalid for user: {}", username);
                }
            } catch (Exception e) {
                System.out.println("[DEBUG] Error during authentication: " + e.getMessage());
                logger.error("Error during authentication: {}, Stacktrace: {}", e.getMessage(), e);
                // 不要在这里抛出异常，而是继续传递请求，让后续过滤器处理
            }
        } else if (SecurityContextHolder.getContext().getAuthentication() != null) {
            System.out.println("[DEBUG] User already authenticated: " + SecurityContextHolder.getContext().getAuthentication().getName());
            logger.info("User already authenticated: {}", SecurityContextHolder.getContext().getAuthentication().getName());
        }

        System.out.println("[DEBUG] SecurityContext Authentication after: " + SecurityContextHolder.getContext().getAuthentication());
        logger.info("SecurityContextHolder.getContext().getAuthentication() after: {}", SecurityContextHolder.getContext().getAuthentication());

        filterChain.doFilter(request, response);
    }
}