package g3.t1.resourcemanagement.repository;

import g3.t1.resourcemanagement.entity.Client;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ClientRepository extends JpaRepository<Client, Long> {
}
