package g3.t1.resourcemanagement.service;

import g3.t1.resourcemanagement.entity.Admin;
import g3.t1.resourcemanagement.entity.Client;
import g3.t1.resourcemanagement.entity.Reservation;
import g3.t1.resourcemanagement.entity.ReservationId;
import g3.t1.resourcemanagement.entity.Resource;
import g3.t1.resourcemanagement.repository.ClientRepository;
import g3.t1.resourcemanagement.repository.ReservationRepository;
import g3.t1.resourcemanagement.repository.ResourceRepository;
import g3.t1.resourcemanagement.web.AdminReservationForm;
import g3.t1.resourcemanagement.web.ReservationForm;
import jakarta.persistence.PersistenceException;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jakarta.validation.Valid;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
@RequiredArgsConstructor
public class ReservationService {

    private final ReservationRepository reservationRepository;
    private final ResourceRepository resourceRepository;
    private final ClientRepository clientRepository;

    public List<Reservation> findAll() {
        return reservationRepository.findAll();
    }

    @Transactional(readOnly = true)
    public Optional<Reservation> findById(ReservationId id) {
        return reservationRepository.findById(id);
    }

    public List<Reservation> findOverlappingActiveReservations(Long id, LocalDateTime now, LocalDateTime futureLimit) {
        return reservationRepository.findOverlappingActiveReservations(id, now, futureLimit);
    }

    /**
     * Find all active reservations for a specific client
     * Active means "ACTIVE" status and end time is in the future
     */
    public List<Reservation> findActiveReservationsByClientId(Long clientId) {
        LocalDateTime now = LocalDateTime.now();

        return reservationRepository.findActiveReservationsByClient(clientId, now).stream()
                .sorted((r1, r2) -> r1.getStartTime().compareTo(r2.getStartTime()))
                .collect(Collectors.toList());
    }

    /**
     * Create a reservation after validating business rules:
     * - end > start (EndAfterStart validator also enforces this)
     * - no overlapping reservations for the same resource
     * - client has not exceeded maxActiveReservations
     */
    @Transactional
    public Reservation createReservation(@Valid Reservation reservation) {

        // ---- Required fields & PK integrity ----
        if (reservation.getId() == null
                || reservation.getId().getEndTime() == null
                || reservation.getResource() == null
                || reservation.getResource().getId() == null) {
            throw new IllegalArgumentException(
                    "Reservation must have resource with id and endTime");
        }

        // ---- Time interval validation ----
        LocalDateTime start = reservation.getStartTime();
        LocalDateTime end = reservation.getId().getEndTime();
        if (start == null || !end.isAfter(start)) {
            throw new IllegalArgumentException("Invalid reservation interval");
        }

        Resource resource = reservation.getResource();

        // Ensure resource exists and ADD RESOURCE to reservation
        Resource managedResource = resourceRepository.findById(resource.getId())
                .orElseThrow(() -> new IllegalArgumentException("Resource not found"));
        reservation.setResource(managedResource);

        // Check overlapping reservations (EXCLUDING current reservation if it exists)
        List<Reservation> overlaps = reservationRepository.findOverlappingActiveReservations(resource.getId(), start, end);

        // Filter out the current reservation being edited (same resourceId and endTime)
        overlaps = overlaps.stream()
                .filter(r -> !(r.getId().getResourceId().equals(reservation.getId().getResourceId())
                        && r.getId().getEndTime().equals(reservation.getId().getEndTime())))
                .collect(Collectors.toList());

        if (!overlaps.isEmpty()) {
            throw new IllegalStateException("Resource is already reserved for the requested time window.");
        }

        // Check client's active reservations limit
        Client client = reservation.getClient();
        if (client == null || client.getId() == null) {
            throw new IllegalArgumentException("Client must be provided");
        }

        // Ensure client exists and ADD CLIENT to reservation
        Client managedClient = clientRepository.findById(client.getId())
                .orElseThrow(() -> new IllegalArgumentException("Client not found"));
        reservation.setClient(managedClient);

        long activeCount = reservationRepository.countActiveReservationsByClient(managedClient.getId());
        if (managedClient.getMaxActiveReservations() != null
                && activeCount >= managedClient.getMaxActiveReservations()) {
            throw new IllegalStateException("Client has reached the maximum number of active reservations");
        }

        if (reservation.getId() == null) {
            reservation.setId(new ReservationId(managedResource.getId(), end));
        } else {
            // make sure resourceId and endTime are set on the id
            reservation.getId().setResourceId(managedResource.getId());
            if (reservation.getId().getEndTime() == null) {
                reservation.getId().setEndTime(end);
            }
        }

        // Persist reservation
        try {
            Optional<Reservation> existingOpt = reservationRepository.findReservationsByResourceIdAndEnd(
                    managedResource.getId(), end);

            if (existingOpt.isPresent()) {
                // There exists already a reservation (possibly CANCELLED/COMPLETED)
                // Update the existing reservation with new values
                Reservation existing = existingOpt.get();
                existing.setClient(managedClient);
                existing.setStartTime(start);
                existing.setStatus("ACTIVE");
                existing.setNotes(reservation.getNotes());
                existing.setAdmin(reservation.getAdmin());

                Reservation saved = reservationRepository.save(existing);
                reservationRepository.flush();
                return saved;
            } else {
                // No existing reservation, create new one
                Reservation saved = reservationRepository.save(reservation);
                reservationRepository.flush();
                return saved;
            }

        } catch (DataIntegrityViolationException | PersistenceException ex) {
            log.error("Failed to save Reservation: cause={}, reservation={}", ex.getMessage(), reservation, ex);
            throw ex;
        }
    }

    @Transactional
    public void cancelReservation(ReservationId id) {
        Reservation r = reservationRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Reservation not found"));
        r.setStatus("CANCELLED");
        reservationRepository.save(r);
    }

    @Transactional
    public Reservation createReservationFromForm(AdminReservationForm form, Admin admin) {
        // Validate form basic fields
        if (form == null)
            throw new IllegalArgumentException("Form is required");
        if (form.getResourceId() == null)
            throw new IllegalArgumentException("Resource id is required");
        if (form.getClientId() == null)
            throw new IllegalArgumentException("Client id is required");

        // Lookup resource and client
        Resource resource = resourceRepository.findById(form.getResourceId())
                .orElseThrow(() -> new IllegalArgumentException("Resource not found"));
        Client client = clientRepository.findById(form.getClientId())
                .orElseThrow(() -> new IllegalArgumentException("Client not found"));

        return getReservation(client, resource, form.getStartTime(), form.getEndTime(), form.getNotes(), admin);
    }

    @Transactional
    public Reservation createReservationFromForm(ReservationForm form, Client client, Resource resource) {
        if (form == null)
            throw new IllegalArgumentException("Form is required");
        if (client == null || client.getId() == null)
            throw new IllegalArgumentException("Client must be provided");
        if (resource == null || resource.getId() == null)
            throw new IllegalArgumentException("Resource must be provided");

        return getReservation(client, resource, form.getStartTime(), form.getEndTime(), form.getNotes(), null);
    }

    @Transactional
    protected Reservation getReservation(Client client, Resource resource, LocalDateTime start, LocalDateTime end,
                                         String notes, Admin admin) {
        if (start == null || end == null || !end.isAfter(start)) {
            throw new IllegalArgumentException("Invalid reservation interval");
        }

        Reservation reservation = Reservation.builder()
                .id(new ReservationId(resource.getId(), end))
                .resource(resource)
                .client(client)
                .startTime(start)
                .status("ACTIVE")
                .notes(notes)
                .admin(admin)
                .build();

        return createReservation(reservation);
    }
}