import SwiftUI
import AppKit

struct ContentView: View {
    @State private var inputJSON = ""
    @State private var outputScript = ""
    @State private var errorMessage = ""
    @State private var successMessage = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Proxyman Script Generator")
                .font(.headline)
                .foregroundColor(Color(red: 0.31, green: 0.76, blue: 0.97))

            Text("Paste JSON response đầy đủ:")
                .font(.caption)
                .foregroundColor(.gray)

            TextEditor(text: $inputJSON)
                .font(.system(.body, design: .monospaced))
                .frame(minHeight: 150)
                .scrollContentBackground(.hidden)
                .background(Color(white: 0.18))
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(white: 0.27)))

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(8)
                    .background(Color(red: 0.18, green: 0.12, blue: 0.12))
                    .cornerRadius(6)
            }

            if !successMessage.isEmpty {
                Text(successMessage)
                    .font(.caption)
                    .foregroundColor(.green)
                    .padding(8)
                    .background(Color(red: 0.12, green: 0.18, blue: 0.12))
                    .cornerRadius(6)
            }

            HStack {
                Spacer()
                Button("Clear") { clearAll() }
                    .buttonStyle(.bordered)
                Button("Generate") { generate() }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(red: 0.31, green: 0.76, blue: 0.97))
            }

            if !outputScript.isEmpty {
                Text("Script Output:")
                    .font(.caption)
                    .foregroundColor(.gray)

                ScrollView {
                    Text(outputScript)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(Color(white: 0.71))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                }
                .frame(minHeight: 150)
                .padding(12)
                .background(Color(white: 0.1))
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(white: 0.2)))

                HStack {
                    Spacer()
                    Button("Copy Script") { copyOutput() }
                        .buttonStyle(.borderedProminent)
                        .tint(Color(red: 0.31, green: 0.76, blue: 0.97))
                }
            }
        }
        .padding(20)
        .frame(minWidth: 700, minHeight: 600)
        .preferredColorScheme(.dark)
    }

    private func generate() {
        errorMessage = ""
        successMessage = ""

        let trimmed = inputJSON.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = "Vui lòng paste JSON vào!"
            return
        }

        guard let data = trimmed.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data),
              let prettyData = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted, .sortedKeys]),
              let prettyJSON = String(data: prettyData, encoding: .utf8) else {
            errorMessage = "JSON không hợp lệ!"
            return
        }

        outputScript = generateScript(prettyJSON: prettyJSON)
        successMessage = "Đã tạo script!"
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { successMessage = "" }
    }

    private func generateScript(prettyJSON: String) -> String {
        let indented = prettyJSON.components(separatedBy: "\n")
            .enumerated()
            .map { $0.offset == 0 ? $0.element : "    \($0.element)" }
            .joined(separator: "\n")

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

    private func copyOutput() {
        guard !outputScript.isEmpty else {
            errorMessage = "Chưa có script để copy"
            return
        }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(outputScript, forType: .string)
        successMessage = "Đã copy!"
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { successMessage = "" }
    }

    private func clearAll() {
        inputJSON = ""
        outputScript = ""
        errorMessage = ""
        successMessage = ""
    }
}
