import XCTest
@testable import ProxymanScriptGen

final class ModelsTests: XCTestCase {

    // MARK: - HistoryEntry

    func testHistoryEntry_creation() {
        let entry = HistoryEntry(title: "Test", inputJSON: "{}", outputScript: "script", tag: "Prod")
        XCTAssertEqual(entry.title, "Test")
        XCTAssertEqual(entry.inputJSON, "{}")
        XCTAssertEqual(entry.outputScript, "script")
        XCTAssertEqual(entry.tag, "Prod")
        XCTAssertNotNil(entry.id)
    }

    func testHistoryEntry_defaultTag() {
        let entry = HistoryEntry(title: "T", inputJSON: "{}", outputScript: "s")
        XCTAssertEqual(entry.tag, "Local")
    }

    func testHistoryEntry_codable() throws {
        let entry = HistoryEntry(title: "Encode", inputJSON: #"{"a":1}"#, outputScript: "code")
        let data = try JSONEncoder().encode(entry)
        let decoded = try JSONDecoder().decode(HistoryEntry.self, from: data)
        XCTAssertEqual(decoded.id, entry.id)
        XCTAssertEqual(decoded.title, entry.title)
        XCTAssertEqual(decoded.inputJSON, entry.inputJSON)
        XCTAssertEqual(decoded.outputScript, entry.outputScript)
    }

    // MARK: - HistoryStore

    func testHistoryStore_addAndClear() {
        let store = HistoryStore()
        store.clearAll()
        XCTAssertTrue(store.entries.isEmpty)

        store.add(HistoryEntry(title: "A", inputJSON: "{}", outputScript: "s1"))
        store.add(HistoryEntry(title: "B", inputJSON: "{}", outputScript: "s2"))
        XCTAssertEqual(store.entries.count, 2)
        // Most recent first
        XCTAssertEqual(store.entries[0].title, "B")

        store.clearAll()
        XCTAssertTrue(store.entries.isEmpty)
    }

    func testHistoryStore_remove() {
        let store = HistoryStore()
        store.clearAll()
        store.add(HistoryEntry(title: "X", inputJSON: "{}", outputScript: "s"))
        store.add(HistoryEntry(title: "Y", inputJSON: "{}", outputScript: "s"))
        store.remove(at: IndexSet(integer: 0))
        XCTAssertEqual(store.entries.count, 1)
        XCTAssertEqual(store.entries[0].title, "X")
        store.clearAll()
    }

    // MARK: - SnippetData

    func testSnippetData_hasEntries() {
        XCTAssertGreaterThanOrEqual(SnippetData.all.count, 5)
    }

    func testSnippetData_allHaveCode() {
        for snippet in SnippetData.all {
            XCTAssertFalse(snippet.code.isEmpty, "\(snippet.title) has empty code")
            XCTAssertFalse(snippet.title.isEmpty)
            XCTAssertFalse(snippet.description.isEmpty)
        }
    }

    func testSnippetData_categoriesRepresented() {
        let categories = Set(SnippetData.all.map { $0.category })
        XCTAssertTrue(categories.contains(.headers))
        XCTAssertTrue(categories.contains(.bodyInjection))
        XCTAssertTrue(categories.contains(.latency))
        XCTAssertTrue(categories.contains(.authentication))
    }

    // MARK: - AppSettings

    func testAppSettings_defaults() {
        // Clear to test defaults
        UserDefaults.standard.removeObject(forKey: "defaultScriptHeaders")
        UserDefaults.standard.removeObject(forKey: "autoVersioning")
        UserDefaults.standard.removeObject(forKey: "defaultProxyPort")
        UserDefaults.standard.removeObject(forKey: "editorFontSize")
        UserDefaults.standard.removeObject(forKey: "selectedTheme")
        UserDefaults.standard.removeObject(forKey: "selectedFont")

        let settings = AppSettings()
        XCTAssertEqual(settings.defaultScriptHeaders, true)
        XCTAssertEqual(settings.autoVersioning, false)
        XCTAssertEqual(settings.defaultProxyPort, "9090")
        XCTAssertEqual(settings.editorFontSize, 13)
        XCTAssertEqual(settings.selectedTheme, "Obsidian")
        XCTAssertEqual(settings.selectedFont, "JetBrains Mono")
    }

    func testAppSettings_persistence() {
        let settings = AppSettings()
        settings.defaultProxyPort = "8080"
        settings.editorFontSize = 16

        let settings2 = AppSettings()
        XCTAssertEqual(settings2.defaultProxyPort, "8080")
        XCTAssertEqual(settings2.editorFontSize, 16)

        // Cleanup
        settings.defaultProxyPort = "9090"
        settings.editorFontSize = 13
    }
}
