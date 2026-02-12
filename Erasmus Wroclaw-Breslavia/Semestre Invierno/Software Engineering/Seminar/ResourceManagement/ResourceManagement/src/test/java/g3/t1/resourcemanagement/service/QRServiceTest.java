package g3.t1.resourcemanagement.service;

import com.google.zxing.NotFoundException;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.core.io.ClassPathResource;

import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

/**
 * Unit tests for QRService - validates QR code decoding functionality.
 *
 * Tests cover:
 * - Image format validation
 * - QR code decoding from valid images
 * - Error handling for invalid inputs
 */
@ExtendWith(MockitoExtension.class)
class QRServiceTest {

    @InjectMocks
    private QRService qrService;

    @Test
    void decodeImage_ShouldThrowException_WhenInputStreamIsNull() {
        assertThatThrownBy(() -> qrService.decodeImage(null))
                .isInstanceOf(IllegalArgumentException.class);
    }

    @Test
    void decodeImage_ShouldThrowException_WhenInputIsNotValidImage() {
        // Create a stream with non-image data
        byte[] invalidData = "not an image".getBytes();
        ByteArrayInputStream stream = new ByteArrayInputStream(invalidData);

        assertThatThrownBy(() -> qrService.decodeImage(stream))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("not a valid image");
    }

    @Test
    void decodeImage_ShouldThrowException_WhenImageHasNoQRCode() {
        // Create a simple 10x10 white image with no QR code
        BufferedImage emptyImage = new BufferedImage(10, 10, BufferedImage.TYPE_INT_RGB);
        for (int x = 0; x < 10; x++) {
            for (int y = 0; y < 10; y++) {
                emptyImage.setRGB(x, y, 0xFFFFFF); // white
            }
        }

        // Convert to input stream
        try {
            java.io.ByteArrayOutputStream baos = new java.io.ByteArrayOutputStream();
            javax.imageio.ImageIO.write(emptyImage, "png", baos);
            ByteArrayInputStream stream = new ByteArrayInputStream(baos.toByteArray());

            assertThatThrownBy(() -> qrService.decodeImage(stream))
                    .isInstanceOf(NotFoundException.class);
        } catch (IOException e) {
            throw new RuntimeException("Failed to create test image", e);
        }
    }

    @Test
    void decodeImage_ShouldSucceed_WhenValidQRCodeProvided() throws Exception {
        // Load the valid QR code image from resources
        ClassPathResource resource = new ClassPathResource("static/img/validqr.png");

        // Verify the resource exists
        assertThat(resource.exists()).isTrue();

        // Decode the QR code
        try (InputStream inputStream = resource.getInputStream()) {
            String decodedContent = qrService.decodeImage(inputStream);

            // Verify the decoded content is not null or empty
            assertThat(decodedContent).isNotNull();
            assertThat(decodedContent).isNotEmpty();

            // Verify it contains the expected pattern (ends with /resources/{id})
            assertThat(decodedContent)
                    .matches(".*\\/resources\\/\\d+$");
        }
    }

    @Test
    void decodeImage_ShouldThrowException_WhenInvalidQRCodeProvided() throws Exception {
        // Load the invalid QR code image from resources
        ClassPathResource resource = new ClassPathResource("static/img/notvalidqr.png");

        // Verify the resource exists
        assertThat(resource.exists()).isTrue();

        // Attempt to decode - should throw NotFoundException if truly invalid
        // OR return content that doesn't match the expected pattern
        try (InputStream inputStream = resource.getInputStream()) {
            try {
                String decodedContent = qrService.decodeImage(inputStream);

                // If it decodes successfully, verify it doesn't match the valid pattern
                assertThat(decodedContent)
                        .doesNotMatch(".*\\/resources\\/\\d+$");
            } catch (NotFoundException e) {
                // This is also acceptable - no QR code found
                assertThat(e).isInstanceOf(NotFoundException.class);
            }
        }
    }

    @Test
    void decodeImage_ShouldHandleLargeImages() throws Exception {
        // Create a larger empty image to test performance/handling
        BufferedImage largeImage = new BufferedImage(1000, 1000, BufferedImage.TYPE_INT_RGB);
        for (int x = 0; x < 1000; x++) {
            for (int y = 0; y < 1000; y++) {
                largeImage.setRGB(x, y, 0xFFFFFF);
            }
        }

        java.io.ByteArrayOutputStream baos = new java.io.ByteArrayOutputStream();
        javax.imageio.ImageIO.write(largeImage, "png", baos);
        ByteArrayInputStream stream = new ByteArrayInputStream(baos.toByteArray());

        // Should handle large images without crashing
        assertThatThrownBy(() -> qrService.decodeImage(stream))
                .isInstanceOf(NotFoundException.class);
    }
}