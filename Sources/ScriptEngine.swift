import Foundation

/// Testable script generation engine
enum ScriptEngine {

    /// Validate and generate Proxyman script from raw JSON string
    static func processJSON(_ input: String) -> Result<String, ScriptError> {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .failure(.emptyInput) }
        guard let data = trimmed.data(using: .utf8),
              (try? JSONSerialization.jsonObject(with: data)) != nil else {
            return .failure(.invalidJSON)
        }
        return .success(generateScript(rawJSON: trimmed))
    }

    /// Generate Proxyman onRequest/onResponse script wrapping the JSON
    static func generateScript(rawJSON: String) -> String {
        let lines = rawJSON.split(separator: "\n", omittingEmptySubsequences: false)
        let indented = lines.enumerated().map { offset, line in
            offset == 0 ? String(line) : "    \(line)"
        }.joined(separator: "\n")

        return """
        console.log("🔥 SCRIPT LOADED");

        sharedState.savedResponse = null;

        async function onRequest(context, url, request) {
          console.log("➡️ onRequest:", url);

          if (sharedState.savedResponse?.data) {
            request.headers["X-Debug"] = "From-Proxyman";
          }

          return request;
        }

        async function onResponse(context, url, request, response) {
          console.log("⬅️ onResponse:", url);
          console.log("Status:", response.statusCode);

          const MOCK_RESPONSE = \(indented);

          // ✅ FORCE override response
          response.headers["Content-Type"] = "application/json";
          response.body = MOCK_RESPONSE;

          sharedState.savedResponse = MOCK_RESPONSE;

          console.log("✅ RESPONSE OVERRIDDEN");

          return response;
        }
        """
    }

    /// Beautify JSON string (pretty print with sorted keys)
    static func beautify(_ input: String) -> String? {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              let data = trimmed.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data),
              let prettyData = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted, .sortedKeys]),
              let pretty = String(data: prettyData, encoding: .utf8) else { return nil }
        return pretty
    }

    /// Extract a meaningful title from JSON for history
    static func extractTitle(from json: String) -> String {
        guard let data = json.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return "Generated Script"
        }
        if let attrs = (obj["data"] as? [String: Any])?["attributes"] as? [String: Any],
           let ep = attrs["endpoint"] as? String {
            return ep
        }
        if let type = obj["type"] as? String { return type }
        return "Generated Script"
    }
}

enum ScriptError: Error, Equatable {
    case emptyInput
    case invalidJSON
}
