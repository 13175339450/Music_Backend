import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;

public class SetTestPassword {
    public static void main(String[] args) {
        try {
            // 生成BCrypt密码
            BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
            String password = encoder.encode("test123");
            System.out.println("Generated password: " + password);
            
            // 连接数据库并更新密码
            Class.forName("com.mysql.cj.jdbc.Driver");
            String url = "jdbc:mysql://localhost:3306/music_platform?useUnicode=true&characterEncoding=utf-8&useSSL=false&serverTimezone=GMT%2B8";
            String username = "root";
            String dbPassword = "123456";
            
            Connection conn = DriverManager.getConnection(url, username, dbPassword);
            String sql = "UPDATE user SET password = ? WHERE username = 'test'";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, password);
            
            int rows = pstmt.executeUpdate();
            System.out.println("Updated " + rows + " rows");
            
            pstmt.close();
            conn.close();
            System.out.println("Password updated successfully!");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}