//
//  ImageFeedAppUITests.swift
//  ImageFeedAppUITests
//
//  Created by Анжелика Забазнова on 15.05.2025.
//

import XCTest

class Image_FeedUITests: XCTestCase {
    private let app = XCUIApplication() // переменная приложения

    override func setUpWithError() throws {
        continueAfterFailure = false // настройка выполнения тестов, которая прекратит выполнения тестов, если в тесте что-то пошло не так

        app.launch() // запускаем приложение перед каждым тестом
    }

    func testAuth() throws {
        sleep(1)
        let authenticateButton = app.buttons["Войти"]
        XCTAssertTrue(authenticateButton.waitForExistence(timeout: 5))
        authenticateButton.tap()

        let authWebView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(authWebView.waitForExistence(timeout: 5))

        let dismissKeyboardArea = authWebView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1))

        let emailField = authWebView.textFields.element
        XCTAssertTrue(emailField.waitForExistence(timeout: 5))

        emailField.tap()
        emailField.typeText("user@mail.com")
        // hide keyboard
        dismissKeyboardArea.tap()

        let passField = authWebView.secureTextFields.element
        XCTAssertTrue(passField.waitForExistence(timeout: 5))

        passField.tap()
        passField.typeText("password")
        // hide keyboard
        dismissKeyboardArea.tap()

        let loginButton = authWebView.buttons["Login"]
        loginButton.tap()

        let tablesQuery = app.tables
        let firstCell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5))
    }

    func testFeed() throws {
        sleep(1)
        let tablesQuery = app.tables
        let cell1 = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell1.waitForExistence(timeout: 5))

        cell1.swipeUp()

        let cell2 = tablesQuery.children(matching: .cell).element(boundBy: 1)
        XCTAssertTrue(cell2.waitForExistence(timeout: 1))

        let likeButton = cell2.buttons["Like"]
        XCTAssertTrue(likeButton.waitForExistence(timeout: 1))
        likeButton.tap()
        sleep(1)

        let likeButton2 = cell2.buttons["Like"]
        XCTAssertTrue(likeButton2.waitForExistence(timeout: 1))
        likeButton2.tap()
        sleep(1)

        cell2.tap()
        sleep(2)

        let image = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 1))

        image.pinch(withScale: 3, velocity: 1)
        sleep(1)
        image.pinch(withScale: 0.5, velocity: -1)
        sleep(1)

        let backButton = app.buttons["Backward"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 1))
        backButton.tap()
        sleep(1)
    }

    func testProfile() throws {
        sleep(1)
        app.tabBars.buttons.element(boundBy: 1).tap()

        XCTAssertTrue(app.staticTexts["Anzhelika Zabaznova"].exists)
        XCTAssertTrue(app.staticTexts["@baaazik"].exists)

        sleep(1)

        let logoutButton = app.buttons["Logout"]
        XCTAssertTrue(logoutButton.waitForExistence(timeout: 1))

        logoutButton.tap()
        sleep(1)

        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()

        let authenticateButton = app.buttons["Войти"]
        XCTAssertTrue(authenticateButton.waitForExistence(timeout: 5))
    }
}
