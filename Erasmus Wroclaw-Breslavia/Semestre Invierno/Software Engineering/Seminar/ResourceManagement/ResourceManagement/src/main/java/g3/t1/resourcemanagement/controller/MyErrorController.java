package g3.t1.resourcemanagement.controller;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.boot.web.servlet.error.ErrorController;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class MyErrorController implements ErrorController {

    @RequestMapping("/error")
    public String handleError(HttpServletRequest request, Model model) {
        // Get error status code
        Object status = request.getAttribute(RequestDispatcher.ERROR_STATUS_CODE);

        Integer statusCode = null;
        if (status != null) {
            statusCode = Integer.valueOf(status.toString());
        }

        // Get error details
        String errorMessage = (String) request.getAttribute(RequestDispatcher.ERROR_MESSAGE);
        Exception exception = (Exception) request.getAttribute(RequestDispatcher.ERROR_EXCEPTION);
        String path = (String) request.getAttribute(RequestDispatcher.ERROR_REQUEST_URI);

        // Prepare model
        model.addAttribute("statusCode", statusCode);
        model.addAttribute("path", path);

        // Determine error type and message
        if (statusCode != null) {
            if (statusCode == HttpStatus.NOT_FOUND.value()) {
                model.addAttribute("errorTitle", "Page Not Found");
                model.addAttribute("errorMessage", "The page you're looking for doesn't exist.");
                model.addAttribute("errorIcon", "404");
            } else if (statusCode == HttpStatus.FORBIDDEN.value()) {
                model.addAttribute("errorTitle", "Access Denied");
                model.addAttribute("errorMessage", "You don't have permission to access this resource.");
                model.addAttribute("errorIcon", "403");
            } else if (statusCode == HttpStatus.UNAUTHORIZED.value()) {
                model.addAttribute("errorTitle", "Unauthorized");
                model.addAttribute("errorMessage", "Please log in to access this resource.");
                model.addAttribute("errorIcon", "401");
            } else if (statusCode == HttpStatus.INTERNAL_SERVER_ERROR.value()) {
                model.addAttribute("errorTitle", "Server Error");
                model.addAttribute("errorMessage", "Something went wrong on our end. Please try again later.");
                model.addAttribute("errorIcon", "500");
            } else {
                model.addAttribute("errorTitle", "Error " + statusCode);
                model.addAttribute("errorMessage",
                        errorMessage != null ? errorMessage : "An unexpected error occurred.");
                model.addAttribute("errorIcon", statusCode.toString());
            }
        } else {
            model.addAttribute("errorTitle", "Error");
            model.addAttribute("errorMessage", "An unexpected error occurred.");
            model.addAttribute("errorIcon", "!");
        }

        model.addAttribute("page", "error");

        return "error";
    }
}
