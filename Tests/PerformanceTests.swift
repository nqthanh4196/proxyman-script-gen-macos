import XCTest
@testable import ProxymanScriptGen

final class PerformanceTests: XCTestCase {

    // MARK: - Large JSON Processing

    func testPerformance_processLargeJSON() {
        // Generate a large JSON
        let largeJSON = generateLargeJSON(entries: 5000)
        XCTAssertGreaterThan(largeJSON.count, 200_000)

        measure {
            let result = ScriptEngine.processJSON(largeJSON)
            switch result {
            case .success: break
            case .failure: XCTFail("Should handle large JSON")
            }
        }
    }

    func testPerformance_processVeryLargeJSON() {
        // ~2MB JSON
        let hugeJSON = generateLargeJSON(entries: 20000)

        measure {
            let result = ScriptEngine.processJSON(hugeJSON)
            switch result {
            case .success: break
            case .failure: XCTFail("Should handle very large JSON")
            }
        }
    }

    func testPerformance_beautifyLargeJSON() {
        let largeJSON = generateLargeJSON(entries: 5000)

        measure {
            _ = ScriptEngine.beautify(largeJSON)
        }
    }

    func testPerformance_generateScriptLargeJSON() {
        let largeJSON = generateLargeJSON(entries: 10000)

        measure {
            _ = ScriptEngine.generateScript(rawJSON: largeJSON)
        }
    }

    // MARK: - History Store Stress

    func testPerformance_historyStoreAdd1000Entries() {
        let store = HistoryStore()
        store.clearAll()

        measure {
            for i in 0..<1000 {
                store.add(HistoryEntry(
                    title: "Entry \(i)",
                    inputJSON: #"{"index": \#(i)}"#,
                    outputScript: "script_\(i)"
                ))
            }
            store.saveNow()
        }

        store.clearAll()
    }

    func testPerformance_historyStorePersistence() {
        let store = HistoryStore()
        store.clearAll()

        // Add 500 entries
        for i in 0..<500 {
            store.add(HistoryEntry(
                title: "Entry \(i)",
                inputJSON: #"{"data": "value_\#(i)", "nested": {"key": "val"}}"#,
                outputScript: "async function onResponse() { return \(i); }"
            ))
        }

        // Measure reload time
        measure {
            let _ = HistoryStore()
        }

        store.clearAll()
    }

    // MARK: - Concurrent Processing

    func testStress_concurrentProcessJSON() {
        let json = #"{"status": "ok", "data": [1,2,3,4,5]}"#
        let expectation = XCTestExpectation(description: "All concurrent tasks complete")
        expectation.expectedFulfillmentCount = 100

        let queue = DispatchQueue(label: "stress", attributes: .concurrent)
        for _ in 0..<100 {
            queue.async {
                let result = ScriptEngine.processJSON(json)
                switch result {
                case .success: expectation.fulfill()
                case .failure: XCTFail("Should not fail")
                }
            }
        }

        wait(for: [expectation], timeout: 10)
    }

    func testStress_rapidBeautify() {
        let jsons = (0..<50).map { #"{"key_\#($0)": \#($0), "nested": {"a": true}}"# }

        measure {
            for json in jsons {
                _ = ScriptEngine.beautify(json)
            }
        }
    }

    // MARK: - Edge Cases Under Load

    func testStress_manyInvalidJSONs() {
        measure {
            for i in 0..<1000 {
                let result = ScriptEngine.processJSON("invalid_\(i){{{")
                XCTAssertEqual(result, .failure(.invalidJSON))
            }
        }
    }

    func testPerformance_extractTitleFromLargeJSON() {
        let largeJSON = generateLargeJSON(entries: 10000)

        measure {
            _ = ScriptEngine.extractTitle(from: largeJSON)
        }
    }

    // MARK: - Helpers

    private func generateLargeJSON(entries: Int) -> String {
        var items: [String] = []
        for i in 0..<entries {
            items.append(#"{"id": \#(i), "name": "item_\#(i)", "value": \#(Double(i) * 1.5)}"#)
        }
        return #"{"data": [\#(items.joined(separator: ","))], "total": \#(entries)}"#
    }
}
