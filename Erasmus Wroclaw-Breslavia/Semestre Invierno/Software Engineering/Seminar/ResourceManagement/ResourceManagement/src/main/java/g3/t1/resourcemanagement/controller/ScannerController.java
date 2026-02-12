package g3.t1.resourcemanagement.controller;

import g3.t1.resourcemanagement.entity.Resource;
import g3.t1.resourcemanagement.service.QRService;
import g3.t1.resourcemanagement.service.ResourceService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import java.util.regex.Pattern;

@Controller
@RequestMapping("/scan")
@RequiredArgsConstructor
public class ScannerController {
    private final ResourceService resourceService;
    private final QRService qrService; // wrapper around ZXing decode logic

    // Pattern to extract resource ID from full URL
    private static final Pattern RESOURCE_ID_PATTERN = Pattern.compile("/resources/([^/\\?#\\s]+)", Pattern.CASE_INSENSITIVE);

    @GetMapping("")
    public String scanPage(@RequestParam(required = false) String error,
                           @RequestParam(required = false) String qrContent,
                           Model model) {
        if (error != null) {
            model.addAttribute("uploadError", error);
        }
        if (qrContent != null) {
            model.addAttribute("qrContent", qrContent);
        }
        return "scan";
    }

    @PostMapping("/upload")
    public String uploadDecoded(@RequestParam(required = false) MultipartFile file) {
        // Validate file is present
        if (file == null || file.isEmpty()) {
            return "redirect:/scan?error=" + urlEncode("Please select a file to upload.");
        }

        try {
            // Decode QR code from uploaded image
            String qrContent = qrService.decodeImage(file.getInputStream());

            if (qrContent == null || qrContent.trim().isEmpty()) {
                return "redirect:/scan?error=" + urlEncode("No QR code found in the image.");
            }

            // Extract resource ID from QR content
            String resourceId = extractResourceId(qrContent);

            if (resourceId == null) {
                // Show error with QR content, matching JavaScript behavior
                return "redirect:/scan?error=invalidQR" +
                        "&qrContent=" + urlEncode(qrContent);
            }

            // Validate that the resource exists
            Long id = Long.parseLong(resourceId);
            try {
                Resource r = resourceService.findById(id);
                return "redirect:/resources/" + resourceId;
            } catch (IllegalArgumentException ex) {
                return "redirect:/?notfound";
            }

        } catch (NumberFormatException e) {
            return "redirect:/scan?error=" + urlEncode("Invalid resource ID format.");
        } catch (Exception e) {
            return "redirect:/scan?error=" +
                    urlEncode("Failed to decode QR code: " + e.getMessage());
        }
    }

    /**
     * Extract numeric resource ID from QR code content.
     * Matches the JavaScript logic in scan.js (lines 68-108)
     * Supports both full URLs (http://.../resources/123) and plain IDs (123)
     */
    private String extractResourceId(String qrContent) {
        if (qrContent == null || qrContent.trim().isEmpty()) {
            return null;
        }

        String trimmed = qrContent.trim();

        // Try to match URL pattern first: /resources/X
        var matcher = RESOURCE_ID_PATTERN.matcher(trimmed);
        if (matcher.find()) {
            String id = matcher.group(1).trim();
            // Validate it's numeric
            return id.matches("^\\d+$") ? id : null;
        }

        // If not a URL, check if it's just a numeric ID (no slashes or colons)
        if (!trimmed.contains("/") && !trimmed.contains(":")) {
            // Validate it's numeric
            return trimmed.matches("^\\d+$") ? trimmed : null;
        }

        return null;
    }

    /**
     * URL encode a string for use in redirect URLs
     */
    private String urlEncode(String value) {
        try {
            return java.net.URLEncoder.encode(value, "UTF-8");
        } catch (Exception e) {
            return value;
        }
    }
}