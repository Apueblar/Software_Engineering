package g3.t1.resourcemanagement.service;

import g3.t1.resourcemanagement.entity.Book;
import g3.t1.resourcemanagement.entity.Resource;
import g3.t1.resourcemanagement.entity.Room;
import g3.t1.resourcemanagement.repository.BookRepository;
import g3.t1.resourcemanagement.repository.ReservationRepository;
import g3.t1.resourcemanagement.repository.ResourceRepository;
import g3.t1.resourcemanagement.repository.RoomRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ResourceServiceTest {

    @Mock
    private ResourceRepository resourceRepository;

    @Mock
    private ReservationRepository reservationRepository;

    @Mock
    private BookRepository bookRepository;

    @Mock
    private RoomRepository roomRepository;

    @InjectMocks
    private ResourceService resourceService;

    private Book testBook;
    private Room testRoom;

    @BeforeEach
    void setUp() {
        testBook = Book.builder()
                .id(1L)
                .title("Test Book")
                .author("Test Author")
                .isbn("1234567890123")
                .year(2024)
                .copiesAvailable(5)
                .available(true)
                .build();

        testRoom = Room.builder()
                .id(2L)
                .roomCode("ROOM-A")
                .name("Room A")
                .capacity(10)
                .location("Building 1")
                .available(true)
                .build();
    }

    @Test
    void findAll_ShouldReturnAllResources() {
        when(resourceRepository.findAll()).thenReturn(Arrays.asList(testBook, testRoom));

        List<Resource> result = resourceService.findAll();

        assertThat(result).hasSize(2);
        assertThat(result).contains(testBook, testRoom);
        verify(resourceRepository, times(1)).findAll();
    }

    @Test
    void findById_ShouldReturnResource_WhenExists() {
        when(resourceRepository.findById(1L)).thenReturn(Optional.of(testBook));

        Resource result = resourceService.findById(1L);

        assertThat(result).isEqualTo(testBook);
        verify(resourceRepository, times(1)).findById(1L);
    }

    @Test
    void findById_ShouldThrowException_WhenNotExists() {
        when(resourceRepository.findById(999L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> resourceService.findById(999L))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("Resource not found");
    }

    @Test
    void save_ShouldSaveAndReturnResource() {
        when(resourceRepository.save(any(Resource.class))).thenReturn(testBook);

        Resource result = resourceService.save(testBook);

        assertThat(result).isEqualTo(testBook);
        verify(resourceRepository, times(1)).save(testBook);
    }

    @Test
    void deleteById_ShouldDeleteResource() {
        when(resourceRepository.findById(1L)).thenReturn(Optional.of(testBook));
        doNothing().when(resourceRepository).delete(testBook);

        resourceService.deleteById(1L);

        verify(resourceRepository, times(1)).findById(1L);
        verify(resourceRepository, times(1)).delete(testBook);
    }
}