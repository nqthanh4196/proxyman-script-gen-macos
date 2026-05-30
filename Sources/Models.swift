import Foundation

// MARK: - History Model
struct HistoryEntry: Identifiable, Codable {
    let id: UUID
    var title: String
    var inputJSON: String
    var outputScript: String
    var timestamp: Date
    var tag: String

    init(title: String, inputJSON: String, outputScript: String, tag: String = "Local") {
        self.id = UUID()
        self.title = title
        self.inputJSON = inputJSON
        self.outputScript = outputScript
        self.timestamp = Date()
        self.tag = tag
    }
}

// MARK: - Snippet Model
struct Snippet: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let category: SnippetCategory
    let code: String
    let icon: String
    let iconColor: String
    let createdAgo: String
}

enum SnippetCategory: String, CaseIterable {
    case all = "All Templates"
    case headers = "Headers"
    case bodyInjection = "Body Injection"
    case latency = "Latency"
    case authentication = "Authentication"
}

// MARK: - Feedback Model
enum FeedbackType: String, CaseIterable {
    case bug = "Bug Report"
    case suggestion = "Suggestion"
    case performance = "Performance"
    case other = "Other"
}

// MARK: - App Settings
class AppSettings: ObservableObject {
    @Published var defaultScriptHeaders: Bool {
        didSet { UserDefaults.standard.set(defaultScriptHeaders, forKey: "defaultScriptHeaders") }
    }
    @Published var autoVersioning: Bool {
        didSet { UserDefaults.standard.set(autoVersioning, forKey: "autoVersioning") }
    }
    @Published var defaultProxyPort: String {
        didSet { UserDefaults.standard.set(defaultProxyPort, forKey: "defaultProxyPort") }
    }
    @Published var editorFontSize: Double {
        didSet { UserDefaults.standard.set(editorFontSize, forKey: "editorFontSize") }
    }
    @Published var selectedTheme: String {
        didSet { UserDefaults.standard.set(selectedTheme, forKey: "selectedTheme") }
    }
    @Published var selectedFont: String {
        didSet { UserDefaults.standard.set(selectedFont, forKey: "selectedFont") }
    }

    init() {
        self.defaultScriptHeaders = UserDefaults.standard.object(forKey: "defaultScriptHeaders") as? Bool ?? true
        self.autoVersioning = UserDefaults.standard.object(forKey: "autoVersioning") as? Bool ?? false
        self.defaultProxyPort = UserDefaults.standard.string(forKey: "defaultProxyPort") ?? "9090"
        self.editorFontSize = UserDefaults.standard.object(forKey: "editorFontSize") as? Double ?? 13
        self.selectedTheme = UserDefaults.standard.string(forKey: "selectedTheme") ?? "Obsidian"
        self.selectedFont = UserDefaults.standard.string(forKey: "selectedFont") ?? "JetBrains Mono"
    }
}

// MARK: - History Store
class HistoryStore: ObservableObject {
    @Published var entries: [HistoryEntry] = []

    private let key = "historyEntries"

    init() { load() }

    func add(_ entry: HistoryEntry) {
        entries.insert(entry, at: 0)
        save()
    }

    func clearAll() {
        entries.removeAll()
        save()
    }

    func remove(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        save()
    }

    private func save() {
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([HistoryEntry].self, from: data) else { return }
        entries = decoded
    }
}

// MARK: - Snippet Data
struct SnippetData {
    static let all: [Snippet] = [
        Snippet(
            title: "Status Code Modifier",
            description: "Intercept any response and programmatically override the HTTP status code.",
            category: .headers,
            code: """
            async function onResponse(context, url, request, response) {
              response.statusCode = 200;
              return response;
            }
            """,
            icon: "pencil.circle",
            iconColor: "primary",
            createdAgo: "2 days ago"
        ),
        Snippet(
            title: "Field Injection",
            description: "Deep-merge new fields into JSON responses. Perfect for mocking feature flags.",
            category: .bodyInjection,
            code: """
            async function onResponse(context, url, request, response) {
              var body = JSON.parse(response.body);
              body.feature_flags = { new_ui: true, beta: true };
              response.body = JSON.stringify(body);
              return response;
            }
            """,
            icon: "curlybraces",
            iconColor: "tertiary",
            createdAgo: "1 week ago"
        ),
        Snippet(
            title: "Delay Response",
            description: "Simulate high latency for specific endpoints to test app resilience.",
            category: .latency,
            code: """
            async function onResponse(context, url, request, response) {
              await new Promise(resolve => setTimeout(resolve, 2000));
              return response;
            }
            """,
            icon: "timer",
            iconColor: "error",
            createdAgo: "3 weeks ago"
        ),
        Snippet(
            title: "OAuth2 Token Injector",
            description: "Automatically attaches valid bearer tokens to outbound requests.",
            category: .authentication,
            code: """
            async function onRequest(context, url, request) {
              const token = "your_bearer_token_here";
              request.headers["Authorization"] = `Bearer ${token}`;
              return request;
            }
            """,
            icon: "lock.open",
            iconColor: "primary",
            createdAgo: "1 month ago"
        ),
        Snippet(
            title: "Header Sanitizer",
            description: "Remove sensitive diagnostic headers before requests hit production.",
            category: .headers,
            code: """
            async function onRequest(context, url, request) {
              delete request.headers["X-Debug-Token"];
              delete request.headers["X-Internal-Trace"];
              return request;
            }
            """,
            icon: "line.3.horizontal.decrease",
            iconColor: "tertiary",
            createdAgo: "1 month ago"
        ),
    ]
}
