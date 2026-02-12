package g3.t1.resourcemanagement.repository;

import g3.t1.resourcemanagement.entity.Resource;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ResourceRepository extends JpaRepository<Resource, Long> {
}
