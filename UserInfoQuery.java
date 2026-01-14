import com.music.entity.User;
import com.music.repository.UserRepository;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.ApplicationContext;

@SpringBootApplication
public class UserInfoQuery {
    public static void main(String[] args) {
        ApplicationContext context = SpringApplication.run(UserInfoQuery.class, args);
        UserRepository userRepository = context.getBean(UserRepository.class);
        
        User user = userRepository.findByUsername("testadmin").orElse(null);
        if (user != null) {
            System.out.println("Username: " + user.getUsername());
            System.out.println("Password: " + user.getPassword());
            System.out.println("Roles: " + user.getRoles());
            System.out.println("Status: " + user.getStatus());
        } else {
            System.out.println("User not found");
        }
        
        System.exit(0);
    }
}