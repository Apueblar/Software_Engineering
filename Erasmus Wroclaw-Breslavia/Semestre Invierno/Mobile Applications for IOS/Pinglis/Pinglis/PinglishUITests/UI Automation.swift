import XCTest

final class PinglishAutomationTests: XCTestCase {
    
    let app = XCUIApplication()

    override func setUpWithError() throws {
        // Si un paso falla, el test se detiene para que veas el error
        continueAfterFailure = false
        app.launch()
    }

    func testCompleteUserFlow() throws {
        // Aquí va el código que me pasaste
        let usernameField = app.textFields["user_input"]
        
        let exists = usernameField.waitForExistence(timeout: 10)
        
        if !exists {
            print(app.debugDescription)
            XCTFail("El robot no encuentra 'user_input'. Revisa el ID en LoginView.")
        }

        usernameField.tap()
        usernameField.typeText("tester_pro")

        let passwordField = app.secureTextFields["password_input"]
        XCTAssertTrue(passwordField.exists)
        passwordField.tap()
        passwordField.typeText("Pass1234")

        let loginButton = app.buttons["login_button"]
        XCTAssertTrue(loginButton.exists)
        loginButton.tap()
    }
}
