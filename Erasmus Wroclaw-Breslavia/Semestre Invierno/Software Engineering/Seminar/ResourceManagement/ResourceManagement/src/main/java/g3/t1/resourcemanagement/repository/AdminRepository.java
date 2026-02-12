package g3.t1.resourcemanagement.repository;

import g3.t1.resourcemanagement.entity.Admin;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AdminRepository extends JpaRepository<Admin, Long> {
}
