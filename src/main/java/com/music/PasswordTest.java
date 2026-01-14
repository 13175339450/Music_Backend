import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

public class PasswordTest {
    public static void main(String[] args) {
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        
        // 测试admin123的加密密码
        String rawPassword = "admin123";
        String encryptedPassword = encoder.encode(rawPassword);
        
        System.out.println("Raw password: " + rawPassword);
        System.out.println("Encrypted password: " + encryptedPassword);
        
        // 验证密码
        boolean isMatch = encoder.matches(rawPassword, encryptedPassword);
        System.out.println("Password matches: " + isMatch);
        
        // 测试数据库中的密码
        String dbPassword = "$2a$10$SH5D1rVtwdRMOaI6soiQNOZRjcf44TNP6dybGhq5/sRlZ0unGbb8C";
        boolean dbMatch = encoder.matches(rawPassword, dbPassword);
        System.out.println("Database password matches: " + dbMatch);
    }
}