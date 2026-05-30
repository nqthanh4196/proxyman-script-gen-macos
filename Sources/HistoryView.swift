import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var historyStore: HistoryStore
    @State private var searchText = ""
    var onRestore: (HistoryEntry) -> Void

    private var filtered: [HistoryEntry] {
        if searchText.isEmpty { return historyStore.entries }
        return historyStore.entries.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.inputJSON.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Execution History")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.onSurface)
                    Text("Manage and restore previously generated Proxyman scripts.")
                        .font(.system(size: 13))
                        .foregroundColor(.onSurfaceVariant)
                }
                Spacer()
                Button(action: { historyStore.clearAll() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "trash")
                            .font(.system(size: 12))
                        Text("Clear All")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(Color(hex: "#ffb4ab"))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Color(hex: "#93000a").opacity(0.2))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(hex: "#ffb4ab").opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .disabled(historyStore.entries.isEmpty)
            }
            .padding(20)

            // Search
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 13))
                    .foregroundColor(.onSurfaceVariant)
                TextField("Search history...", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13))
                    .foregroundColor(.onSurface)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.surfaceContainerLow)
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.outlineVariant, lineWidth: 1))
            .padding(.horizontal, 20)
            .padding(.bottom, 16)

            // List
            if filtered.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "clock")
                        .font(.system(size: 40))
                        .foregroundColor(.onSurfaceVariant.opacity(0.3))
                    Text(historyStore.entries.isEmpty ? "No history yet" : "No results found")
                        .font(.system(size: 14))
                        .foregroundColor(.onSurfaceVariant.opacity(0.5))
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(filtered) { entry in
                            historyRow(entry)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .background(Color.surface)
    }

    private func historyRow(_ entry: HistoryEntry) -> some View {
        HStack(spacing: 12) {
            // Icon
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.surfaceContainerHighest)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "doc.text")
                        .font(.system(size: 16))
                        .foregroundColor(.primaryBlue)
                )

            // Info
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 8) {
                    Text(entry.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.onSurface)
                        .lineLimit(1)
                    if !entry.tag.isEmpty {
                        Text(entry.tag.uppercased())
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.onSurfaceVariant)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.surfaceContainerHighest)
                            .cornerRadius(4)
                    }
                }
                Text(entry.inputJSON.prefix(80).replacingOccurrences(of: "\n", with: " "))
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.onSurfaceVariant)
                    .lineLimit(1)
            }

            Spacer()

            // Time
            VStack(alignment: .trailing, spacing: 2) {
                Text(entry.timestamp.relativeString)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.onSurface)
                Text("Local Machine")
                    .font(.system(size: 9))
                    .foregroundColor(.onSurfaceVariant)
            }

            // Actions
            Button("Restore") {
                onRestore(entry)
            }
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.primaryBlue)
            .cornerRadius(4)
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(Color.surfaceContainer.opacity(0.7))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.outlineVariant.opacity(0.4), lineWidth: 1)
        )
    }
}

// MARK: - Date Extension
extension Date {
    var relativeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
