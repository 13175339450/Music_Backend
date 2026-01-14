import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import java.sql.*;

public class AdminPasswordCheck {
    public static void main(String[] args) {
        String url = "jdbc:mysql://localhost:3306/music_platform?useUnicode=true&characterEncoding=utf-8&useSSL=false&serverTimezone=GMT%2B8";
        String username = "root";
        String password = "123456"; // MySQL密码

        try (Connection conn = DriverManager.getConnection(url, username, password)) {
            System.out.println("成功连接到数据库");

            // 查询管理员账户信息
            String query = "SELECT id, username, password, status FROM user WHERE username = 'admin'";
            try (PreparedStatement stmt = conn.prepareStatement(query);
                 ResultSet rs = stmt.executeQuery()) {

                if (rs.next()) {
                    long id = rs.getLong("id");
                    String dbUsername = rs.getString("username");
                    String dbPassword = rs.getString("password");
                    int status = rs.getInt("status");

                    System.out.println("管理员账户信息：");
                    System.out.println("ID: " + id);
                    System.out.println("Username: " + dbUsername);
                    System.out.println("Password: " + dbPassword);
                    System.out.println("Status: " + status);

                    // 验证密码格式是否为BCrypt加密格式
                    if (dbPassword.startsWith("$2a$10$")) {
                        System.out.println("\n密码格式：BCrypt加密格式（有效）");
                    } else {
                        System.out.println("\n密码格式：无效（不是BCrypt加密格式）");
                    }

                    // 测试常用密码
                    BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
                    String[] testPasswords = {"admin23", "admin123", "123456", "admin"};
                    
                    System.out.println("\n测试常用密码：");
                    for (String testPass : testPasswords) {
                        boolean matches = encoder.matches(testPass, dbPassword);
                        System.out.println(testPass + ": " + matches);
                    }
                } else {
                    System.out.println("管理员账户不存在");
                }
            }
        } catch (SQLException e) {
            System.err.println("数据库连接失败：" + e.getMessage());
            e.printStackTrace();
        }
    }
}