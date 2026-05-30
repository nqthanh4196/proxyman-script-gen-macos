import SwiftUI

struct SnippetsView: View {
    @State private var selectedCategory: SnippetCategory = .all
    @State private var searchText = ""
    var onUseSnippet: (Snippet) -> Void

    private var filtered: [Snippet] {
        var results = SnippetData.all
        if selectedCategory != .all {
            results = results.filter { $0.category == selectedCategory }
        }
        if !searchText.isEmpty {
            results = results.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        return results
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Snippet Library")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.onSurface)
                    Text("Accelerate your workflow with curated script templates.")
                        .font(.system(size: 13))
                        .foregroundColor(.onSurfaceVariant)
                }
                Spacer()
            }
            .padding(20)

            // Search
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 13))
                    .foregroundColor(.onSurfaceVariant)
                TextField("Search templates...", text: $searchText)
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
            .padding(.bottom, 12)

            // Category chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(SnippetCategory.allCases, id: \.self) { cat in
                        categoryChip(cat)
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 16)

            // Grid
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 12) {
                    ForEach(filtered) { snippet in
                        snippetCard(snippet)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .background(Color.surface)
    }

    private func categoryChip(_ cat: SnippetCategory) -> some View {
        Button(action: { selectedCategory = cat }) {
            Text(cat.rawValue)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(selectedCategory == cat ? Color.onPrimary : .onSurfaceVariant)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(selectedCategory == cat ? Color.primaryContainer : Color.surfaceContainerHigh)
                .cornerRadius(20)
                .overlay(
                    selectedCategory == cat ? nil :
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.outlineVariant.opacity(0.3), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private func snippetCard(_ snippet: Snippet) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icon + badge
            HStack {
                iconView(snippet)
                Spacer()
                Text("JS")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundColor(.onSurfaceVariant)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.surfaceContainerHighest)
                    .cornerRadius(4)
            }

            // Title
            Text(snippet.title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.onSurface)

            // Description
            Text(snippet.description)
                .font(.system(size: 12))
                .foregroundColor(.onSurfaceVariant)
                .lineLimit(3)

            Spacer(minLength: 0)

            // Footer
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 10))
                    Text(snippet.createdAgo)
                        .font(.system(size: 10))
                }
                .foregroundColor(.onSurfaceVariant.opacity(0.6))

                Spacer()

                Button("Use") {
                    onUseSnippet(snippet)
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.primaryBlue)
                .padding(.horizontal, 14)
                .padding(.vertical, 5)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.primaryBlue.opacity(0.3), lineWidth: 1)
                )
                .buttonStyle(.plain)
            }
            .padding(.top, 8)
            .overlay(Rectangle().frame(height: 1).foregroundColor(Color.outlineVariant.opacity(0.2)), alignment: .top)
        }
        .padding(16)
        .background(Color.surfaceContainer.opacity(0.7))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.outlineVariant.opacity(0.4), lineWidth: 1)
        )
    }

    private func iconView(_ snippet: Snippet) -> some View {
        let color: Color = {
            switch snippet.iconColor {
            case "tertiary": return .tertiary
            case "error": return Color(hex: "#ffb4ab")
            default: return .primaryBlue
            }
        }()
        return Image(systemName: snippet.icon)
            .font(.system(size: 16))
            .foregroundColor(color)
            .frame(width: 32, height: 32)
            .background(color.opacity(0.1))
            .cornerRadius(8)
    }
}
