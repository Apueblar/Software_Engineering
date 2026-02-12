package g3.t1.resourcemanagement.repository;

import g3.t1.resourcemanagement.entity.Reservation;
import g3.t1.resourcemanagement.entity.ReservationId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface ReservationRepository extends JpaRepository<Reservation, ReservationId> {

    /**
     * Find all reservations for a specific client
     */
    @Query("SELECT r FROM Reservation r WHERE r.client.id = :clientId")
    List<Reservation> findByClientId(@Param("clientId") Long clientId);

    /**
     * Find all reservations for a specific resource
     */
    @Query("SELECT r FROM Reservation r WHERE r.resource.id = :resourceId")
    List<Reservation> findByResourceId(@Param("resourceId") Long resourceId);

    /**
     * Find all reservations for a specific resource and end time
     */
    @Query("SELECT r FROM Reservation r WHERE r.resource.id = :resourceId AND r.id.endTime = :end")
    Optional<Reservation> findReservationsByResourceIdAndEnd(@Param("resourceId") Long resourceId,
            @Param("end") LocalDateTime end);

    /**
     * Find reservations for a resource that overlap with a given interval.
     * Overlap condition: existing.start < newEnd AND existing.end > newStart
     */
    @Query("select r from Reservation r where r.resource.id = :resourceId and r.id.endTime > :start and r.startTime < :end")
    List<Reservation> findOverlappingReservations(@Param("resourceId") Long resourceId,
            @Param("start") LocalDateTime start, @Param("end") LocalDateTime end);

    /**
     * Find reservations for a resource that overlap with a given interval.
     * Overlap condition: r.status not in ('CANCELLED','COMPLETED') AND
     * existing.start < newEnd AND existing.end > newStart
     */
    @Query("select r from Reservation r where r.resource.id = :resourceId and r.status not in ('CANCELLED','COMPLETED') and r.id.endTime > :start and r.startTime < :end")
    List<Reservation> findOverlappingActiveReservations(@Param("resourceId") Long resourceId,
            @Param("start") LocalDateTime start, @Param("end") LocalDateTime end);

    /**
     * Count active reservations for a client (status not CANCELLED/COMPLETED).
     */
    @Query("select count(r) from Reservation r where r.client.id = :clientId and r.status not in ('CANCELLED','COMPLETED')")
    long countActiveReservationsByClient(@Param("clientId") Long clientId);

    /**
     * Find all active reservations for a client
     */
    @Query("SELECT r FROM Reservation r WHERE r.client.id = :clientId " + "AND r.status = 'ACTIVE' "
            + "AND r.id.endTime > :now " + "ORDER BY r.startTime ASC")
    List<Reservation> findActiveReservationsByClient(@Param("clientId") Long clientId, @Param("now") LocalDateTime now);

    @Query("select r.resource.id from Reservation r where :time >= r.startTime and :time < r.id.endTime")
    List<Long> findResourceIdsReservedAt(@Param("time") LocalDateTime time);

    @Query("select distinct r.resource.id from Reservation r where r.startTime < :endTime and r.id.endTime > :startTime")
    List<Long> findResourceIdsReservedBetween(@Param("startTime") LocalDateTime startTime,
            @Param("endTime") LocalDateTime endTime);
}
