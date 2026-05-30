# Context: Full UI & Feature Implementation

## Tổng quan

Xây dựng toàn bộ UI và chức năng cho app Proxyman Script Generator dựa trên design mockup HTML trong thư mục `stitch_proxyman_json_converter/`.

## Tài liệu thiết kế (Reference)

| File | Mô tả |
|------|--------|
| `stitch_proxyman_json_converter/project_brief_proxyman_script_generator.md` | Brief ban đầu - mô tả tổng quan project |
| `stitch_proxyman_json_converter/project_brief_proxyman_script_generator_updated.md` | Brief cập nhật - thêm chi tiết các feature |
| `stitch_proxyman_json_converter/DESIGN.md` | Design system "Obsidian Utility" - colors, typography, spacing, components |
| `stitch_proxyman_json_converter/code.html` | HTML mockup - màn Editor (main screen) |
| `stitch_proxyman_json_converter/proxyman_script_generator_history/code.html` | HTML mockup - màn History |
| `stitch_proxyman_json_converter/proxyman_script_generator_snippets/code.html` | HTML mockup - màn Snippets |
| `stitch_proxyman_json_converter/proxyman_script_generator_settings/code.html` | HTML mockup - màn Settings |
| `stitch_proxyman_json_converter/proxyman_script_generator_feedback/code.html` | HTML mockup - màn Feedback |
| `stitch_proxyman_json_converter/screen.png` | Screenshot reference cho từng màn |

## Những gì đã làm

### 1. Tạo Models & Services (`Sources/Models.swift`)
- `HistoryEntry` — model lưu lịch sử generate, persist qua UserDefaults
- `HistoryStore` — ObservableObject quản lý CRUD history
- `Snippet` + `SnippetData` — thư viện 5 snippet templates có sẵn
- `SnippetCategory` — enum filter (All, Headers, Body Injection, Latency, Authentication)
- `FeedbackType` — enum loại feedback
- `AppSettings` — ObservableObject lưu settings persist (theme, font, port, toggles)

### 2. Tạo HistoryView (`Sources/HistoryView.swift`)
- Danh sách history entries với glassmorphic card style
- Search/filter history
- Nút "Restore" → khôi phục JSON + script về Editor
- Nút "Clear All" → xóa toàn bộ history
- Hiển thị relative time (2 minutes ago, yesterday...)

### 3. Tạo SnippetsView (`Sources/SnippetsView.swift`)
- Grid layout 2 cột hiển thị snippet cards
- 5 built-in templates: Status Code Modifier, Field Injection, Delay Response, OAuth2 Token Injector, Header Sanitizer
- Category chips filter
- Search templates
- Nút "Use" → apply snippet code vào output editor

### 4. Tạo SettingsView (`Sources/SettingsView.swift`)
- **General**: Default Script Headers toggle, Auto-Versioning toggle, Proxy Port input
- **Appearance**: Theme selector (Obsidian/Crystal), Font family picker, Font size slider
- **About**: App info, version, badges
- Tất cả settings persist qua UserDefaults

### 5. Tạo FeedbackView (`Sources/FeedbackView.swift`)
- Form: Subject, Feedback Type (picker), Description (TextEditor)
- Character counter (0/2000)
- Submit animation với loading state
- Success toast notification

### 6. Cập nhật ContentView (`Sources/ContentView.swift`)
- Refactor sidebar navigation dùng `Button` (fix click issue trên macOS)
- Enum `AppTab` quản lý 5 tabs
- `@ViewBuilder mainContent` switch giữa các view
- Auto-save history khi generate script
- `restoreFromHistory()` — restore entry và chuyển về Editor
- `useSnippet()` — apply snippet và chuyển về Editor
- Inject `HistoryStore` + `AppSettings` qua `.environmentObject()`

## Cấu trúc Source Code

```
Sources/
├── ProxymanScriptGenApp.swift   # App entry point
├── ContentView.swift            # Main layout + Editor tab + shared components
├── Models.swift                 # Data models, stores, settings
├── HistoryView.swift            # History tab
├── SnippetsView.swift           # Snippets tab
├── SettingsView.swift           # Settings tab
└── FeedbackView.swift           # Feedback tab
```

## Build & Run

```bash
./build.sh                        # Build release .app
open build/ProxymanScriptGen.app  # Mở app
```

## Tech Stack
- Swift 5.9 / SwiftUI
- macOS 13+ (Ventura)
- NSTextView (AppKit) cho code editor performance
- UserDefaults cho persistence
- No external dependencies
