//
//  AuthViewModelTests.swift
//  Pinglish
//
//  Created by ioss on 16/1/26.
//

import XCTest
@testable import Pinglish

final class AuthViewModelTests: XCTestCase {
    
    var authVM: AuthViewModel!

    override func setUp() {func testLoginEdgeCases() {
        // Caso A: Contraseña vacía
        XCTAssertThrowsError(try authVM.signUp(username: "user1", password: ""), "Debería lanzar error por contraseña vacía")
        
        // Caso B: Usuario vacío
        XCTAssertThrowsError(try authVM.signUp(username: "", password: "password123"), "Debería lanzar error por usuario vacío")
        
        // Caso C: Usuario extremadamente largo (ej. 100 caracteres)
        let longUsername = String(repeating: "a", count: 100)
        XCTAssertThrowsError(try authVM.signUp(username: longUsername, password: "123"), "Debería fallar por longitud de usuario")
    }

    func testLoginIncorrectPassword() throws {
        let username = "test_user"
        try authVM.signUp(username: username, password: "correct_password")
        authVM.logout() // Asumiendo que tienes este método
        
        // Intentar login con password mal
        XCTAssertThrowsError(try authVM.login(username: username, password: "wrong_password"), "Debería fallar por contraseña incorrecta")
    }
        super.setUp()
        // Limpiamos solo el estado que usa la app (UserDefaults + Keychain)
        authVM = AuthViewModel()
    }

    override func tearDown() {
        authVM = nil
        super.tearDown()
    }

    func testSignUpCreatesUser() throws {
        // GIVEN: Un nombre de usuario único
        let rawUUID = UUID().uuidString.prefix(4).lowercased()
        let username = "testuser_\(rawUUID)"
        let password = "password123"

        // WHEN: Ejecutamos el registro
        XCTAssertNoThrow(try authVM.signUp(username: username, password: password))

        // THEN: Verificamos los resultados
        XCTAssertNotNil(authVM.currentUser, "El usuario debería existir tras el registro")
        XCTAssertEqual(authVM.currentUser?.username, username)
        XCTAssertEqual(authVM.currentUser?.points, 0)
    }
}
