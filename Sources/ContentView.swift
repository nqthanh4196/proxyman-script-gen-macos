import SwiftUI
import AppKit

struct ContentView: View {
    @State private var inputJSON = ""
    @State private var outputScript = ""
    @State private var errorMessage = ""
    @State private var successMessage = ""
    @State private var isGenerating = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Proxyman Script Generator")
                    .font(.headline)
                    .foregroundColor(Color(red: 0.31, green: 0.76, blue: 0.97))
                Text("v1.2.0")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

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
                if isGenerating {
                    ProgressView()
                        .controlSize(.small)
                        .padding(.horizontal, 8)
                }
                Button("Generate") { generate() }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(red: 0.31, green: 0.76, blue: 0.97))
                    .disabled(isGenerating)
            }

            if !outputScript.isEmpty {
                Text("Script Output:")
                    .font(.caption)
                    .foregroundColor(.gray)

                CodeTextView(text: outputScript)
                    .frame(minHeight: 150)
                    .cornerRadius(8)

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

        isGenerating = true
        let input = trimmed
        Task.detached(priority: .userInitiated) {
            let result = Self.processJSON(input)
            await MainActor.run {
                isGenerating = false
                switch result {
                case .success(let script):
                    outputScript = script
                    successMessage = "Đã tạo script!"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { successMessage = "" }
                case .failure:
                    errorMessage = "JSON không hợp lệ!"
                }
            }
        }
    }

    private nonisolated static func processJSON(_ trimmed: String) -> Result<String, Error> {
        // Validate JSON only, skip re-serialization for speed
        guard let data = trimmed.data(using: .utf8),
              (try? JSONSerialization.jsonObject(with: data)) != nil else {
            return .failure(NSError(domain: "", code: 0))
        }
        // Use raw input directly (already valid JSON) — avoid expensive pretty-print + sort
        return .success(generateScript(rawJSON: trimmed))
    }

    private nonisolated static func generateScript(rawJSON: String) -> String {
        // Indent all lines after the first by 2 spaces for the const assignment
        let indented: String
        if rawJSON.count > 500_000 {
            // For very large JSON, avoid splitting into array — use as-is
            indented = rawJSON
        } else {
            let lines = rawJSON.split(separator: "\n", omittingEmptySubsequences: false)
            indented = lines.enumerated().map { offset, line in
                offset == 0 ? String(line) : "    \(line)"
            }.joined(separator: "\n")
        }

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

// MARK: - NSTextView wrapper for large text (no lag)
struct CodeTextView: NSViewRepresentable {
    let text: String

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        let textView = scrollView.documentView as! NSTextView
        textView.isEditable = false
        textView.isSelectable = true
        textView.font = NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)
        textView.textColor = NSColor(white: 0.71, alpha: 1)
        textView.backgroundColor = NSColor(white: 0.1, alpha: 1)
        textView.textContainerInset = NSSize(width: 12, height: 12)
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        scrollView.hasVerticalScroller = true
        scrollView.borderType = .noBorder
        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        let textView = scrollView.documentView as! NSTextView
        if textView.string != text {
            textView.string = text
        }
    }
}
