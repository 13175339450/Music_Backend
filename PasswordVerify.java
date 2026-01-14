import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

public class PasswordVerify {
    public static void main(String[] args) {
        BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();
        String rawPassword = "123456";
        // 数据库中存储的密码
        String encodedPassword = "$2a$10$sRIU29.hPGMwBxclyBU3iuaS3ERAqoRNjQ19tohNIwUn11UIFKGW.";
        
        boolean matches = passwordEncoder.matches(rawPassword, encodedPassword);
        System.out.println("Password matches: " + matches);
        
        // 生成新密码用于测试
        String newEncodedPassword = passwordEncoder.encode(rawPassword);
        System.out.println("New encoded password: " + newEncodedPassword);
    }
}