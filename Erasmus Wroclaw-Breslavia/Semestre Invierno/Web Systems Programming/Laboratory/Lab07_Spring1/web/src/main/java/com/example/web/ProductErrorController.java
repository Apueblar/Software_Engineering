package com.example.web;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.boot.webmvc.error.ErrorController;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class ProductErrorController implements ErrorController {
    @RequestMapping("/error")
    public String handleError(HttpServletRequest request) {
        String contentType = request.getContentType();
        if (contentType != null && !contentType.contains(MediaType.TEXT_HTML_VALUE)) {
            // Let Spring handle non-HTML requests (CSS, JS, images)
            return null;
        }
        // Redirect HTML errors to main page
        return "redirect:/product";
    }
}
