package g3.t1.resourcemanagement.repository;

import g3.t1.resourcemanagement.entity.Room;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface RoomRepository extends JpaRepository<Room, Long> {
    Optional<Room> findByRoomCode(String roomCode);
}
