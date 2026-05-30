import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // General Section
                settingsSection(icon: "slider.horizontal.3", title: "GENERAL") {
                    VStack(spacing: 0) {
                        settingsToggleRow(
                            title: "Default Script Headers",
                            subtitle: "Automatically include common boilerplate at the start of new scripts.",
                            isOn: $settings.defaultScriptHeaders
                        )
                        Divider().background(Color.outlineVariant.opacity(0.3))
                        settingsToggleRow(
                            title: "Auto-Versioning",
                            subtitle: "Create local backups every time you save a script.",
                            isOn: $settings.autoVersioning
                        )
                        Divider().background(Color.outlineVariant.opacity(0.3))
                        settingsInputRow(
                            title: "Default Proxy Port",
                            subtitle: "The local port where the scripting engine listens.",
                            value: $settings.defaultProxyPort
                        )
                    }
                    .background(Color.surfaceContainerLow)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.outlineVariant.opacity(0.5), lineWidth: 1))
                }

                // Appearance Section
                settingsSection(icon: "paintpalette", title: "APPEARANCE") {
                    HStack(spacing: 16) {
                        // Theme
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Interface Theme")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.onSurface)
                            Text("Choose how the application feels.")
                                .font(.system(size: 11))
                                .foregroundColor(.onSurfaceVariant)
                            HStack(spacing: 12) {
                                themeButton("Obsidian", color: Color(hex: "#10131b"), isSelected: settings.selectedTheme == "Obsidian") {
                                    settings.selectedTheme = "Obsidian"
                                }
                                themeButton("Crystal", color: Color(hex: "#f8f9fa"), isSelected: settings.selectedTheme == "Crystal") {
                                    settings.selectedTheme = "Crystal"
                                }
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.surfaceContainerLow)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.outlineVariant.opacity(0.5), lineWidth: 1))

                        // Typography
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Editor Typography")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.onSurface)
                            Text("Configure font face and size for scripting.")
                                .font(.system(size: 11))
                                .foregroundColor(.onSurfaceVariant)

                            HStack {
                                Text("Font Family")
                                    .font(.system(size: 11))
                                    .foregroundColor(.onSurfaceVariant)
                                Spacer()
                                Picker("", selection: $settings.selectedFont) {
                                    Text("JetBrains Mono").tag("JetBrains Mono")
                                    Text("Fira Code").tag("Fira Code")
                                    Text("SF Mono").tag("SF Mono")
                                    Text("Menlo").tag("Menlo")
                                }
                                .labelsHidden()
                                .frame(width: 140)
                            }

                            HStack {
                                Text("Font Size")
                                    .font(.system(size: 11))
                                    .foregroundColor(.onSurfaceVariant)
                                Spacer()
                                Slider(value: $settings.editorFontSize, in: 10...24, step: 1)
                                    .frame(width: 100)
                                    .tint(.primaryBlue)
                                Text("\(Int(settings.editorFontSize))pt")
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(.onSurface)
                                    .frame(width: 30)
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.surfaceContainerLow)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.outlineVariant.opacity(0.5), lineWidth: 1))
                    }
                }

                // About Section
                settingsSection(icon: "info.circle", title: "ABOUT") {
                    HStack(spacing: 20) {
                        // App icon
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.surfaceContainerHighest)
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: "terminal")
                                    .font(.system(size: 32))
                                    .foregroundColor(.primaryBlue)
                            )

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Proxyman Scripting Utility")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.onSurface)
                            Text("Version 2.0.0 (Stable Build 2024.12)")
                                .font(.system(size: 12))
                                .foregroundColor(.onSurfaceVariant)

                            HStack(spacing: 8) {
                                badge(icon: "checkmark.shield", text: "Licensed")
                                badge(icon: "arrow.triangle.2.circlepath", text: "Up to date")
                            }
                        }
                        Spacer()
                    }
                    .padding(20)
                    .background(Color.surfaceContainerLow)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.outlineVariant.opacity(0.5), lineWidth: 1))
                }
            }
            .padding(20)
        }
        .background(Color.surface)
    }

    // MARK: - Components

    private func settingsSection<Content: View>(icon: String, title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .foregroundColor(.primaryBlue)
                Text(title)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.onSurface)
                    .tracking(1)
            }
            content()
        }
    }

    private func settingsToggleRow(title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.onSurface)
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(.onSurfaceVariant)
            }
            Spacer()
            Toggle("", isOn: isOn)
                .toggleStyle(.switch)
                .tint(.primaryContainer)
                .scaleEffect(0.8)
        }
        .padding(16)
    }

    private func settingsInputRow(title: String, subtitle: String, value: Binding<String>) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.onSurface)
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(.onSurfaceVariant)
            }
            Spacer()
            TextField("", text: value)
                .textFieldStyle(.plain)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.primaryBlue)
                .frame(width: 80)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.surfaceContainerLowest)
                .cornerRadius(6)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.outlineVariant, lineWidth: 1))
        }
        .padding(16)
    }

    private func themeButton(_ name: String, color: Color, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(color)
                    .frame(height: 40)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.outlineVariant, lineWidth: 1))
                Text(name)
                    .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? .primaryBlue : .onSurfaceVariant)
            }
            .padding(8)
            .background(Color.surfaceContainerLowest)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.primaryBlue : Color.outlineVariant.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            )
            .opacity(isSelected ? 1 : 0.6)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: 100)
    }

    private func badge(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text(text)
                .font(.system(size: 10, weight: .medium))
        }
        .foregroundColor(.onSurfaceVariant)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.surfaceContainerHigh)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.outlineVariant.opacity(0.3), lineWidth: 1))
    }
}
