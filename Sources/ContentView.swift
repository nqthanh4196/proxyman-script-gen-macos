import SwiftUI
import AppKit

// MARK: - Colors (Obsidian Utility)
extension Color {
    static let surface = Color(hex: "#10131b")
    static let surfaceContainerLowest = Color(hex: "#0b0e16")
    static let surfaceContainerLow = Color(hex: "#181c23")
    static let surfaceContainer = Color(hex: "#1c2028")
    static let surfaceContainerHigh = Color(hex: "#272a32")
    static let surfaceContainerHighest = Color(hex: "#31353d")
    static let onSurface = Color(hex: "#e0e2ed")
    static let onSurfaceVariant = Color(hex: "#c1c6d7")
    static let outlineVariant = Color(hex: "#414755")
    static let primaryBlue = Color(hex: "#adc6ff")
    static let primaryContainer = Color(hex: "#4b8eff")
    static let onPrimary = Color(hex: "#002e69")
    static let tertiary = Color(hex: "#ffb595")
    static let codeEditorBg = Color(hex: "#161616")

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .init(charactersIn: "#"))
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255
        )
    }
}

// MARK: - Tab Enum
enum AppTab: String, CaseIterable {
    case editor = "Editor"
    case history = "History"
    case snippets = "Snippets"
    case settings = "Settings"
    case feedback = "Feedback"

    var icon: String {
        switch self {
        case .editor: return "chevron.left.forwardslash.chevron.right"
        case .history: return "clock"
        case .snippets: return "terminal"
        case .settings: return "gearshape"
        case .feedback: return "bubble.left"
        }
    }
}

// MARK: - Main ContentView
struct ContentView: View {
    @StateObject private var historyStore = HistoryStore()
    @StateObject private var settings = AppSettings()
    @State private var selectedTab: AppTab = .editor
    @State private var inputJSON = ""
    @State private var outputScript = ""
    @State private var errorMessage = ""
    @State private var successMessage = ""
    @State private var isGenerating = false

    var body: some View {
        VStack(spacing: 0) {
            topBar
            HStack(spacing: 0) {
                sidebar
                mainContent
            }
            statusBar
        }
        .background(Color.surface)
        .frame(minWidth: 960, minHeight: 680)
        .preferredColorScheme(.dark)
        .environmentObject(historyStore)
        .environmentObject(settings)
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            HStack(spacing: 10) {
                Text("Proxyman Script Generator")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.onSurface)
                Text("V2.0.0")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.onSurfaceVariant)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.surfaceContainerHighest)
                    .cornerRadius(4)
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .frame(height: 44)
        .background(Color.surface.opacity(0.8))
        .overlay(Rectangle().frame(height: 1).foregroundColor(Color.outlineVariant.opacity(0.3)), alignment: .bottom)
    }

    // MARK: - Sidebar
    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.primaryContainer)
                    .frame(width: 32, height: 32)
                    .overlay(Text("⌘").font(.system(size: 16, weight: .bold)).foregroundColor(.white))
                VStack(alignment: .leading, spacing: 1) {
                    Text("Proxyman")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.onSurface)
                    Text("Script Engine v2.0")
                        .font(.system(size: 10))
                        .foregroundColor(.onSurfaceVariant.opacity(0.7))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)

            ForEach(AppTab.allCases.filter { $0 != .feedback }, id: \.self) { tab in
                sidebarItem(tab: tab)
            }

            Spacer()

            // Feedback at bottom
            sidebarItem(tab: .feedback)
                .padding(.bottom, 8)
        }
        .frame(width: 200)
        .background(Color.surfaceContainerLow.opacity(0.9))
        .overlay(Rectangle().frame(width: 1).foregroundColor(Color.outlineVariant.opacity(0.2)), alignment: .trailing)
    }

    private func sidebarItem(tab: AppTab) -> some View {
        let isActive = selectedTab == tab
        return Button(action: { selectedTab = tab }) {
            HStack(spacing: 10) {
                Image(systemName: tab.icon)
                    .font(.system(size: 12))
                Text(tab.rawValue)
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundColor(isActive ? .primaryBlue : .onSurfaceVariant.opacity(0.7))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isActive ? Color.primaryBlue.opacity(0.1) : Color.clear)
            .overlay(
                isActive ? Rectangle().frame(width: 2).foregroundColor(.primaryBlue) : nil,
                alignment: .trailing
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Main Content
    @ViewBuilder
    private var mainContent: some View {
        switch selectedTab {
        case .editor:
            editorView
        case .history:
            HistoryView(onRestore: restoreFromHistory)
        case .snippets:
            SnippetsView(onUseSnippet: useSnippet)
        case .settings:
            SettingsView()
        case .feedback:
            FeedbackView()
        }
    }

    // MARK: - Editor View
    private var editorView: some View {
        VStack(spacing: 0) {
            inputSection
            outputSection
        }
        .background(Color.surfaceContainerLowest)
    }

    private var inputSection: some View {
        VStack(spacing: 0) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.down.doc")
                        .font(.system(size: 11))
                        .foregroundColor(.primaryBlue)
                    Text("INPUT: PASTE JSON RESPONSE HERE")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.onSurfaceVariant)
                        .tracking(0.5)
                }
                Spacer()
                HStack(spacing: 12) {
                    Button("BEAUTIFY") { beautify() }
                        .buttonStyle(HeaderButtonStyle())
                    Button("CLEAR") { clearAll() }
                        .buttonStyle(HeaderButtonStyle(isDestructive: true))
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 30)
            .background(Color.surfaceContainer.opacity(0.5))
            .overlay(Rectangle().frame(height: 1).foregroundColor(Color.outlineVariant.opacity(0.1)), alignment: .bottom)

            ZStack(alignment: .bottomTrailing) {
                CodeEditorView(text: $inputJSON, isEditable: true)
                Button(action: generate) {
                    HStack(spacing: 6) {
                        if isGenerating {
                            ProgressView().controlSize(.small).tint(.white)
                        } else {
                            Image(systemName: "bolt.fill").font(.system(size: 13))
                        }
                        Text("Generate Script").font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.primaryBlue)
                    .cornerRadius(20)
                    .shadow(color: Color.primaryBlue.opacity(0.3), radius: 10, y: 4)
                }
                .buttonStyle(.plain)
                .disabled(isGenerating)
                .padding(16)
            }
        }
        .overlay(Rectangle().frame(height: 1).foregroundColor(Color.outlineVariant.opacity(0.2)), alignment: .bottom)
    }

    private var outputSection: some View {
        VStack(spacing: 0) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 11))
                        .foregroundColor(.tertiary)
                    Text("OUTPUT: PROXYMAN JAVASCRIPT")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.onSurfaceVariant)
                        .tracking(0.5)
                }
                Spacer()
                if !outputScript.isEmpty {
                    HStack(spacing: 4) {
                        Circle().fill(Color.tertiary).frame(width: 6, height: 6)
                        Text("Ready to copy")
                            .font(.system(size: 10))
                            .foregroundColor(.onSurfaceVariant.opacity(0.6))
                    }
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 30)
            .background(Color.surfaceContainer.opacity(0.5))
            .overlay(Rectangle().frame(height: 1).foregroundColor(Color.outlineVariant.opacity(0.1)), alignment: .bottom)

            ZStack(alignment: .bottomTrailing) {
                if outputScript.isEmpty {
                    VStack {
                        if !errorMessage.isEmpty {
                            Text(errorMessage).font(.system(size: 12)).foregroundColor(.red)
                        } else if !successMessage.isEmpty {
                            Text(successMessage).font(.system(size: 12)).foregroundColor(.green)
                        } else {
                            Text("Generated script will appear here...")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(.onSurfaceVariant.opacity(0.3))
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.codeEditorBg)
                } else {
                    CodeOutputView(text: outputScript)
                }

                if !outputScript.isEmpty {
                    Button(action: copyOutput) {
                        HStack(spacing: 6) {
                            Image(systemName: "doc.on.doc").font(.system(size: 12))
                            Text("Copy Script").font(.system(size: 11, weight: .medium))
                        }
                        .foregroundColor(.onSurface)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Color.surfaceContainerHigh.opacity(0.8))
                        .cornerRadius(6)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.outlineVariant.opacity(0.4), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .padding(16)
                }
            }
        }
    }

    // MARK: - Status Bar
    private var statusBar: some View {
        HStack {
            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle").font(.system(size: 10))
                    Text("v2.0.0 - Ready for processing").font(.system(size: 10))
                }
                .foregroundColor(.onSurfaceVariant.opacity(0.6))
            }
            Spacer()
            HStack(spacing: 12) {
                Text("UTF-8")
                Text("JavaScript")
                Text("Ln 1, Col 1").foregroundColor(.primaryBlue)
            }
            .font(.system(size: 10))
            .foregroundColor(.onSurfaceVariant.opacity(0.6))
        }
        .padding(.horizontal, 16)
        .frame(height: 22)
        .background(Color.surfaceContainerLowest)
        .overlay(Rectangle().frame(height: 1).foregroundColor(Color.outlineVariant.opacity(0.3)), alignment: .top)
    }

    // MARK: - Actions
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
                    // Save to history
                    let title = extractTitle(from: input)
                    historyStore.add(HistoryEntry(title: title, inputJSON: input, outputScript: script))
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { successMessage = "" }
                case .failure:
                    errorMessage = "JSON không hợp lệ!"
                }
            }
        }
    }

    private func extractTitle(from json: String) -> String {
        ScriptEngine.extractTitle(from: json)
    }

    private nonisolated static func processJSON(_ trimmed: String) -> Result<String, Error> {
        switch ScriptEngine.processJSON(trimmed) {
        case .success(let s): return .success(s)
        case .failure(let e): return .failure(e)
        }
    }

    private func beautify() {
        if let pretty = ScriptEngine.beautify(inputJSON) {
            inputJSON = pretty
        }
    }

    private func copyOutput() {
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

    private func restoreFromHistory(_ entry: HistoryEntry) {
        inputJSON = entry.inputJSON
        outputScript = entry.outputScript
        selectedTab = .editor
    }

    private func useSnippet(_ snippet: Snippet) {
        outputScript = snippet.code
        selectedTab = .editor
    }
}

// MARK: - Header Button Style
struct HeaderButtonStyle: ButtonStyle {
    var isDestructive = false
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(isDestructive ? Color(hex: "#ffb4ab") : .onSurfaceVariant)
            .opacity(configuration.isPressed ? 0.6 : 1)
    }
}

// MARK: - Code Editor (Editable)
struct CodeEditorView: NSViewRepresentable {
    @Binding var text: String
    var isEditable: Bool

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true
        scrollView.borderType = .noBorder
        scrollView.drawsBackground = true
        scrollView.backgroundColor = NSColor(Color.codeEditorBg)

        let textView = scrollView.documentView as! NSTextView
        textView.isEditable = isEditable
        textView.isSelectable = true
        textView.font = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        textView.textColor = NSColor(Color.primaryBlue.opacity(0.8))
        textView.backgroundColor = NSColor(Color.codeEditorBg)
        textView.insertionPointColor = NSColor.white
        textView.textContainerInset = NSSize(width: 8, height: 8)
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.isAutomaticLinkDetectionEnabled = false
        textView.isAutomaticDataDetectionEnabled = false
        textView.isRichText = false
        textView.allowsUndo = true
        textView.delegate = context.coordinator
        textView.isHorizontallyResizable = true
        textView.textContainer?.widthTracksTextView = false
        textView.textContainer?.size = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.layoutManager?.allowsNonContiguousLayout = true

        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }
        if textView.string != text { textView.string = text }
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: CodeEditorView
        init(_ parent: CodeEditorView) { self.parent = parent }
        func textDidChange(_ notification: Notification) {
            guard let tv = notification.object as? NSTextView else { return }
            parent.text = tv.string
        }
    }
}

// MARK: - Code Output View (Read-only)
struct CodeOutputView: NSViewRepresentable {
    let text: String

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true
        scrollView.borderType = .noBorder
        scrollView.drawsBackground = true
        scrollView.backgroundColor = NSColor(Color.codeEditorBg)

        let textView = scrollView.documentView as! NSTextView
        textView.isEditable = false
        textView.isSelectable = true
        textView.font = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        textView.textColor = NSColor(Color.onSurfaceVariant.opacity(0.9))
        textView.backgroundColor = NSColor(Color.codeEditorBg)
        textView.textContainerInset = NSSize(width: 8, height: 8)
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isHorizontallyResizable = true
        textView.textContainer?.widthTracksTextView = false
        textView.textContainer?.size = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.layoutManager?.allowsNonContiguousLayout = true

        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }
        if textView.string != text { textView.string = text }
    }
}
