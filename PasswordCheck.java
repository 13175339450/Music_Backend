import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

public class PasswordCheck {
    public static void main(String[] args) {
        BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();
        String rawPassword = "123456";
        String encodedPassword = passwordEncoder.encode(rawPassword);
        
        System.out.println("Raw password: " + rawPassword);
        System.out.println("Encoded password: " + encodedPassword);
        
        // 测试与数据库中可能存在的密码匹配
        // 替换为数据库中实际的加密密码
        String dbPassword = "$2a$10$...";
        boolean matches = passwordEncoder.matches(rawPassword, dbPassword);
        System.out.println("Password matches: " + matches);
    }
}