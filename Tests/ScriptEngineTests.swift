import XCTest
@testable import ProxymanScriptGen

final class ScriptEngineTests: XCTestCase {

    // MARK: - processJSON

    func testProcessJSON_validSimpleJSON() {
        let result = ScriptEngine.processJSON(#"{"key": "value"}"#)
        switch result {
        case .success(let script):
            XCTAssertTrue(script.contains("MOCK_RESPONSE"))
            XCTAssertTrue(script.contains("onResponse"))
            XCTAssertTrue(script.contains("onRequest"))
        case .failure:
            XCTFail("Should succeed with valid JSON")
        }
    }

    func testProcessJSON_emptyInput() {
        let result = ScriptEngine.processJSON("")
        XCTAssertEqual(result, .failure(.emptyInput))
    }

    func testProcessJSON_whitespaceOnly() {
        let result = ScriptEngine.processJSON("   \n\t  ")
        XCTAssertEqual(result, .failure(.emptyInput))
    }

    func testProcessJSON_invalidJSON() {
        let result = ScriptEngine.processJSON("{invalid json}")
        XCTAssertEqual(result, .failure(.invalidJSON))
    }

    func testProcessJSON_arrayJSON() {
        let result = ScriptEngine.processJSON("[1, 2, 3]")
        switch result {
        case .success(let script):
            XCTAssertTrue(script.contains("[1, 2, 3]"))
        case .failure:
            XCTFail("Array JSON should be valid")
        }
    }

    func testProcessJSON_nestedJSON() {
        let json = #"{"data": {"nested": {"deep": true}}}"#
        let result = ScriptEngine.processJSON(json)
        switch result {
        case .success(let script):
            XCTAssertTrue(script.contains("nested"))
        case .failure:
            XCTFail("Nested JSON should be valid")
        }
    }

    func testProcessJSON_withLeadingTrailingWhitespace() {
        let result = ScriptEngine.processJSON("  \n{\"a\": 1}\n  ")
        switch result {
        case .success: break
        case .failure: XCTFail("Should trim and succeed")
        }
    }

    // MARK: - generateScript

    func testGenerateScript_containsRequiredFunctions() {
        let script = ScriptEngine.generateScript(rawJSON: #"{"test": true}"#)
        XCTAssertTrue(script.contains("async function onRequest"))
        XCTAssertTrue(script.contains("async function onResponse"))
        XCTAssertTrue(script.contains("MOCK_RESPONSE"))
        XCTAssertTrue(script.contains("SCRIPT LOADED"))
        XCTAssertTrue(script.contains("RESPONSE OVERRIDDEN"))
    }

    func testGenerateScript_indentsMultilineJSON() {
        let json = "{\n  \"key\": \"value\"\n}"
        let script = ScriptEngine.generateScript(rawJSON: json)
        // Second line should be indented with 4 extra spaces
        XCTAssertTrue(script.contains("      \"key\": \"value\""))
    }

    func testGenerateScript_singleLineJSON() {
        let json = #"{"a":1}"#
        let script = ScriptEngine.generateScript(rawJSON: json)
        XCTAssertTrue(script.contains(#"const MOCK_RESPONSE = {"a":1}"#))
    }

    // MARK: - beautify

    func testBeautify_validJSON() {
        let result = ScriptEngine.beautify(#"{"b":2,"a":1}"#)
        XCTAssertNotNil(result)
        // sortedKeys means "a" comes before "b"
        let aIndex = result!.range(of: "\"a\"")!.lowerBound
        let bIndex = result!.range(of: "\"b\"")!.lowerBound
        XCTAssertTrue(aIndex < bIndex)
    }

    func testBeautify_invalidJSON() {
        let result = ScriptEngine.beautify("not json")
        XCTAssertNil(result)
    }

    func testBeautify_emptyString() {
        let result = ScriptEngine.beautify("")
        XCTAssertNil(result)
    }

    func testBeautify_prettyPrintsWithNewlines() {
        let result = ScriptEngine.beautify(#"{"key":"value"}"#)
        XCTAssertNotNil(result)
        XCTAssertTrue(result!.contains("\n"))
    }

    // MARK: - extractTitle

    func testExtractTitle_withEndpoint() {
        let json = #"{"data":{"attributes":{"endpoint":"/v1/users"}}}"#
        XCTAssertEqual(ScriptEngine.extractTitle(from: json), "/v1/users")
    }

    func testExtractTitle_withType() {
        let json = #"{"type":"api_response"}"#
        XCTAssertEqual(ScriptEngine.extractTitle(from: json), "api_response")
    }

    func testExtractTitle_fallback() {
        let json = #"{"key":"value"}"#
        XCTAssertEqual(ScriptEngine.extractTitle(from: json), "Generated Script")
    }

    func testExtractTitle_invalidJSON() {
        XCTAssertEqual(ScriptEngine.extractTitle(from: "not json"), "Generated Script")
    }
}
