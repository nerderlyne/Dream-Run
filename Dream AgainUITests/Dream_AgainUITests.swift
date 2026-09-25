import XCTest
import UIKit
final class Dream_AgainUITests:XCTestCase {
    @MainActor func testRunStartFillsViewport() throws {
        let app=XCUIApplication();app.launchArguments=["--ui-test"];app.launch()
        XCTAssertTrue(app.buttons["dream"].waitForExistence(timeout:10))
        app.buttons["dream"].tap()
        XCTAssertTrue(app.buttons["ready"].waitForExistence(timeout:10))
        let startFrame=app.screenshot()
        XCTAssertTrue(hasLowerSceneDetail(startFrame.image),"The opening scene must not end in a flat blank band")
        let startup=XCTAttachment(screenshot:startFrame)
        startup.name="Run start viewport"
        startup.lifetime = .keepAlways
        add(startup)
        app.buttons["ready"].tap()
        XCTAssertTrue(app.buttons["pause"].waitForExistence(timeout:5))
        let running=XCTAttachment(screenshot:app.screenshot())
        running.name="Running viewport"
        running.lifetime = .keepAlways
        add(running)
    }
    private func hasLowerSceneDetail(_ image:UIImage)->Bool {
        guard let source=image.cgImage else {return false}
        let width=64,height=128
        var pixels=[UInt8](repeating:0,count:width*height*4)
        guard let context=CGContext(data:&pixels,width:width,height:height,bitsPerComponent:8,bytesPerRow:width*4,space:CGColorSpaceCreateDeviceRGB(),bitmapInfo:CGImageAlphaInfo.premultipliedLast.rawValue) else {return false}
        context.draw(source,in:CGRect(x:0,y:0,width:width,height:height))
        // Core Graphics stores the drawn image bottom-up. Sample below the
        // avatar where the original screenshot showed a uniform empty strip.
        let row=10
        let brightness=(8..<56).map { x -> Int in
            let offset=(row*width+x)*4
            return (Int(pixels[offset])+Int(pixels[offset+1])+Int(pixels[offset+2]))/3
        }
        return (brightness.max() ?? 0)-(brightness.min() ?? 0)>45
    }
    @MainActor func testDreamWhisperPresentation() throws {
        let app=XCUIApplication();app.launchArguments=["--ui-test"];app.launch()
        XCTAssertTrue(app.buttons["dream"].waitForExistence(timeout:10))
        app.buttons["dream"].tap()
        XCTAssertTrue(app.buttons["ready"].waitForExistence(timeout:10))
        app.buttons["ready"].tap()
        let whisper=app.staticTexts["dream whisper"]
        XCTAssertTrue(whisper.waitForExistence(timeout:8))
        XCTAssertTrue((whisper.label).contains("tilt for balloons"))
        let attachment=XCTAttachment(screenshot:app.screenshot());attachment.name="Dream whisper";attachment.lifetime = .keepAlways;add(attachment)
    }
    @MainActor func testWardrobeTryOnWithoutPurchase() throws {
        let app=XCUIApplication();app.launchArguments=["--ui-test"];app.launch()
        XCTAssertTrue(app.buttons["wardrobe"].waitForExistence(timeout:10))
        app.buttons["wardrobe"].tap()
        XCTAssertTrue(app.staticTexts["Your straw looper"].waitForExistence(timeout:5))
        XCTAssertTrue(app.buttons["Turn left"].exists)
        app.buttons["Turn right"].tap()
        app.buttons["Reset view"].tap()
        let dragStart=app.coordinate(withNormalizedOffset:CGVector(dx:0.7,dy:0.28))
        let dragEnd=app.coordinate(withNormalizedOffset:CGVector(dx:0.3,dy:0.28))
        dragStart.press(forDuration:0.1,thenDragTo:dragEnd)
        let hat=app.buttons["preview paper_hat"]
        XCTAssertTrue(hat.waitForExistence(timeout:5))
        hat.tap()
        XCTAssertTrue(app.buttons["buy"].exists,"Preview must leave the item unowned")
        XCTAssertTrue(app.staticTexts["Smiley paper bag"].exists)
        let attachment=XCTAttachment(screenshot:app.screenshot());attachment.name="Wardrobe try-on";attachment.lifetime = .keepAlways;add(attachment)
    }
    @MainActor func testHawaiianTutuPreviewWithoutPurchase() throws {
        let app=XCUIApplication();app.launchArguments=["--ui-test"];app.launch()
        XCTAssertTrue(app.buttons["wardrobe"].waitForExistence(timeout:10))
        app.buttons["wardrobe"].tap()
        app.buttons["Bottom"].tap()
        let tutu=app.buttons["preview hawaiian_tutu"]
        XCTAssertTrue(tutu.waitForExistence(timeout:5))
        tutu.tap()
        XCTAssertTrue(app.staticTexts["Hawaiian tutu"].exists)
        XCTAssertTrue(app.buttons["buy"].exists,"Try-on must leave the tutu unowned")
        let attachment=XCTAttachment(screenshot:app.screenshot())
        attachment.name="Hawaiian tutu wardrobe preview"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    @MainActor func testWardrobeCombinesUnpurchasedOutfitPiecesAcrossCategories() throws {
        let app=XCUIApplication();app.launchArguments=["--ui-test"];app.launch()
        XCTAssertTrue(app.buttons["wardrobe"].waitForExistence(timeout:10))
        app.buttons["wardrobe"].tap()
        app.buttons["Top"].tap()
        app.buttons["preview bare_top"].tap()
        app.buttons["Bottom"].tap()
        app.buttons["preview hawaiian_tutu"].tap()
        var preview=app.staticTexts["Your straw looper"].value as? String ?? ""
        XCTAssertTrue(preview.contains("No ribbon") && preview.contains("Hawaiian tutu"),preview)
        app.buttons["Top"].tap()
        app.buttons["preview coconut_top"].tap()
        preview=app.staticTexts["Your straw looper"].value as? String ?? ""
        XCTAssertTrue(preview.contains("Coconut bra") && preview.contains("Hawaiian tutu"),preview)
        let island=XCTAttachment(screenshot:app.screenshot())
        island.name="Coconut top and Hawaiian tutu";island.lifetime = .keepAlways;add(island)
        app.buttons["Head"].tap()
        app.buttons["preview flower_crown"].tap()
        preview=app.staticTexts["Your straw looper"].value as? String ?? ""
        XCTAssertTrue(preview.contains("Flower crown") && preview.contains("Coconut bra") && preview.contains("Hawaiian tutu"),preview)
        let islandCrown=XCTAttachment(screenshot:app.screenshot())
        islandCrown.name="Flower crown with coconut top and tutu";islandCrown.lifetime = .keepAlways;add(islandCrown)
        app.buttons["Top"].tap()
        app.buttons["preview office_jacket"].tap()
        app.buttons["Bottom"].tap()
        app.buttons["preview tuxedo_pants"].tap()
        preview=app.staticTexts["Your straw looper"].value as? String ?? ""
        XCTAssertTrue(preview.contains("Office tuxedo jacket") && preview.contains("Tuxedo pants"),preview)
        XCTAssertTrue(app.buttons["buy"].exists,"Preview must not buy either piece")
        let office=XCTAttachment(screenshot:app.screenshot())
        office.name="Office tuxedo outfit";office.lifetime = .keepAlways;add(office)
    }
    @MainActor func testFlowerCrownPreview() throws {
        let app=XCUIApplication();app.launchArguments=["--ui-test"];app.launch()
        XCTAssertTrue(app.buttons["wardrobe"].waitForExistence(timeout:10))
        app.buttons["wardrobe"].tap()
        let crown=app.buttons["preview flower_crown"]
        XCTAssertTrue(crown.waitForExistence(timeout:5))
        crown.tap()
        XCTAssertTrue((app.staticTexts["Your straw looper"].value as? String ?? "").contains("Flower crown"))
        app.buttons["Turn right"].tap()
        let shot=XCTAttachment(screenshot:app.screenshot())
        shot.name="Flower crown side preview";shot.lifetime = .keepAlways;add(shot)
    }
    @MainActor func testOfflineStartPauseAndMenus() throws {
        let app=XCUIApplication();app.launchArguments=["--ui-test"];app.launch()
        XCTAssertTrue(app.buttons["dream"].waitForExistence(timeout:10))
        app.buttons["dream"].tap();XCTAssertTrue(app.buttons["ready"].waitForExistence(timeout:10));app.buttons["ready"].tap()
        XCTAssertTrue(app.buttons["ready"].waitForNonExistence(timeout:3),"The full ready button must accept a tap")
        let unexpectedPause=XCTNSPredicateExpectation(predicate:NSPredicate(format:"exists == true"),object:app.buttons["ready"])
        unexpectedPause.isInverted=true;wait(for:[unexpectedPause],timeout:8)
        XCTAssertEqual(app.sliders.count,0)
        XCTAssertFalse(app.switches["Drag steering instead of tilt"].exists)
        XCTAssertTrue(app.buttons["pause"].waitForExistence(timeout:5));app.buttons["pause"].tap()
        XCTAssertTrue(app.buttons["save & leave"].waitForExistence(timeout:5));app.buttons["save & leave"].tap()
        app.buttons["wardrobe"].tap()
        XCTAssertTrue(app.staticTexts["Your straw looper"].waitForExistence(timeout:5))
        XCTAssertTrue(app.buttons["preview paper_hat"].waitForExistence(timeout:5))
        app.buttons["preview paper_hat"].tap()
        XCTAssertTrue(app.buttons["buy"].exists)
        let attachment=XCTAttachment(screenshot:app.screenshot());attachment.name="Wardrobe";attachment.lifetime = .keepAlways;add(attachment)
    }
}

extension Dream_AgainUITests {
    @MainActor func testTranslucentTrackDeviceReview() throws {
        let app=XCUIApplication()
        app.launchArguments=["--ui-test","--art-review","--design-review","--pattern","checker","--art-theme","1","--sky","plate_f46f34cb8f3c1332"]
        app.launch()
        XCTAssertTrue(app.staticTexts["PREVIEW · NO REWARDS"].waitForExistence(timeout:30))
        // Allow asynchronous photo upload and a sustained render interval on the destination device.
        let alive=XCTNSPredicateExpectation(predicate:NSPredicate(format:"exists == false"),object:app.staticTexts["PREVIEW · NO REWARDS"])
        alive.isInverted=true;wait(for:[alive],timeout:12)
        let screenshot=XCTAttachment(screenshot:app.screenshot());screenshot.name="Translucent checker over underwater photograph";screenshot.lifetime = .keepAlways;add(screenshot)
        XCTAssertEqual(app.state,.runningForeground)
    }
}

extension Dream_AgainUITests {
    @MainActor func testFloatingStairProgressionPreviews() throws {
        for variant in ["floating","late"] {
            let app=XCUIApplication()
            app.launchArguments=["--ui-test","--art-review","--design-review","--jump-sequence",variant,"--pattern","checker"]
            app.launch()
            XCTAssertTrue(app.staticTexts["PREVIEW · NO REWARDS"].waitForExistence(timeout:30))
            let stillRunning=XCTNSPredicateExpectation(predicate:NSPredicate(format:"exists == false"),object:app.staticTexts["PREVIEW · NO REWARDS"])
            stillRunning.isInverted=true;wait(for:[stillRunning],timeout:4)
            let shot=XCTAttachment(screenshot:app.screenshot());shot.name="Jump sequence - \(variant)";shot.lifetime = .keepAlways;add(shot)
            XCTAssertEqual(app.state,.runningForeground)
            app.terminate()
        }
    }
}
