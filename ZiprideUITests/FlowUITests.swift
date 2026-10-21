import XCTest

/// Walks every flow of the app and attaches a screenshot of each screen.
final class FlowUITests: XCTestCase {
    private var app: XCUIApplication!
    private var shot = 0

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testFullRideFlow() throws {
        XCTAssertTrue(app.buttons["whereTo"].waitForExistence(timeout: 15))
        sleep(3)
        capture("Inicio")

        browseTabs()

        // Search with accent-insensitive filtering.
        app.buttons["whereTo"].tap()
        let field = app.textFields["searchField"]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        capture("Busca")
        field.tap()
        field.typeText("rodoviaria")
        XCTAssertTrue(app.buttons["place_rodoviaria"].waitForExistence(timeout: 5))
        capture("Busca filtrada")
        app.buttons["place_rodoviaria"].tap()

        // Ride options, payment and confirm.
        XCTAssertTrue(app.buttons["rideOption_x"].waitForExistence(timeout: 8))
        let confirm = app.buttons["confirmRide"]
        XCTAssertTrue(waitUntil(confirm, \.isEnabled, timeout: 10))
        sleep(2)
        capture("Opcoes de viagem")
        app.buttons["rideOption_comfort"].tap()
        app.buttons["paymentRow"].tap()
        XCTAssertTrue(app.buttons["payment_pix"].waitForExistence(timeout: 5))
        capture("Pagamento")
        app.buttons["payment_visa"].tap()
        app.buttons["payment_pix"].tap()
        app.buttons["paymentDone"].tap()
        XCTAssertTrue(confirm.waitForExistence(timeout: 5))
        confirm.tap()

        // Matching and driver on the way.
        sleep(1)
        capture("Procurando motorista")
        XCTAssertTrue(app.buttons["messageButton"].waitForExistence(timeout: 12))
        sleep(1)
        capture("Motorista a caminho")

        // Chat.
        app.buttons["messageButton"].tap()
        XCTAssertTrue(app.buttons["quickReply_0"].waitForExistence(timeout: 5))
        app.buttons["quickReply_0"].tap()
        sleep(2)
        capture("Chat")
        app.buttons["chatClose"].tap()

        // Driver arrives, start the trip.
        let status = app.staticTexts["driverStatus"]
        let arrived = NSPredicate(format: "label == %@", "Seu motorista chegou")
        expectation(for: arrived, evaluatedWith: status)
        waitForExpectations(timeout: 15)
        capture("Motorista chegou")
        if app.buttons["startTrip"].exists { app.buttons["startTrip"].tap() }

        let onTrip = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH %@", "Indo para")).firstMatch
        XCTAssertTrue(onTrip.waitForExistence(timeout: 8))
        sleep(3)
        capture("Em viagem")

        // Rating and tip.
        XCTAssertTrue(app.buttons["ratingStar_5"].waitForExistence(timeout: 15))
        app.buttons["ratingStar_5"].tap()
        app.buttons["tip_5"].tap()
        sleep(1)
        capture("Avaliacao")
        app.buttons["ratingDone"].tap()

        // The trip lands in Atividade.
        XCTAssertTrue(app.buttons["whereTo"].waitForExistence(timeout: 8))
        tab("Atividade")
        XCTAssertTrue(app.buttons["trip_new-5"].waitForExistence(timeout: 5))
        sleep(2)
        capture("Atividade com nova viagem")
    }

    // MARK: - Tabs

    private func browseTabs() {
        tab("Serviços")
        XCTAssertTrue(app.buttons["service_viagem"].waitForExistence(timeout: 5))
        sleep(2)
        capture("Servicos")

        tab("Atividade")
        XCTAssertTrue(app.buttons["trip_t1"].waitForExistence(timeout: 5))
        sleep(2)
        capture("Atividade")
        app.buttons["trip_t1"].tap()
        XCTAssertTrue(app.buttons["rideAgain"].waitForExistence(timeout: 5))
        sleep(1)
        capture("Recibo")
        app.navigationBars.buttons.element(boundBy: 0).tap()

        tab("Conta")
        XCTAssertTrue(app.buttons["walletLink"].waitForExistence(timeout: 5))
        sleep(1)
        capture("Conta")
        app.buttons["walletLink"].tap()
        sleep(1)
        capture("Carteira")
        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(app.buttons["settingsLink"].waitForExistence(timeout: 5))
        app.buttons["settingsLink"].tap()
        sleep(1)
        capture("Configuracoes")
        app.navigationBars.buttons.element(boundBy: 0).tap()

        tab("Início")
        XCTAssertTrue(app.buttons["whereTo"].waitForExistence(timeout: 5))
        app.buttons["scheduleChip"].tap()
        XCTAssertTrue(app.buttons["scheduleDone"].waitForExistence(timeout: 5))
        sleep(1)
        capture("Agendar")
        app.buttons["scheduleDone"].tap()
        sleep(1)
    }

    // MARK: - Helpers

    private func tab(_ name: String) {
        let button = app.tabBars.buttons[name]
        if button.waitForExistence(timeout: 3) {
            button.tap()
        } else {
            app.buttons[name].firstMatch.tap()
        }
    }

    private func capture(_ name: String) {
        shot += 1
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = String(format: "%02d %@", shot, name)
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func waitUntil(_ element: XCUIElement, _ key: KeyPath<XCUIElement, Bool>, timeout: TimeInterval) -> Bool {
        let end = Date().addingTimeInterval(timeout)
        while Date() < end {
            if element.exists && element[keyPath: key] { return true }
            RunLoop.current.run(until: Date().addingTimeInterval(0.3))
        }
        return false
    }
}
