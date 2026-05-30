import SwiftUI

struct FeedbackView: View {
    @State private var subject = ""
    @State private var feedbackType: FeedbackType = .suggestion
    @State private var description = ""
    @State private var showSuccess = false
    @State private var isSubmitting = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Text("Help us improve Proxyman")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.onSurface)
                    Text("Your feedback directly shapes our product roadmap. Share your thoughts, report bugs, or suggest new features.")
                        .font(.system(size: 13))
                        .foregroundColor(.onSurfaceVariant)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 400)
                }
                .padding(.top, 40)
                .padding(.bottom, 32)

                // Form
                VStack(spacing: 20) {
                    HStack(spacing: 16) {
                        // Subject
                        VStack(alignment: .leading, spacing: 6) {
                            Text("SUBJECT")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.onSurfaceVariant)
                                .tracking(0.5)
                            TextField("What's this about?", text: $subject)
                                .textFieldStyle(.plain)
                                .font(.system(size: 13))
                                .foregroundColor(.onSurface)
                                .padding(12)
                                .background(Color.surfaceContainerLowest)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.outlineVariant, lineWidth: 1))
                        }

                        // Type
                        VStack(alignment: .leading, spacing: 6) {
                            Text("FEEDBACK TYPE")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.onSurfaceVariant)
                                .tracking(0.5)
                            Picker("", selection: $feedbackType) {
                                ForEach(FeedbackType.allCases, id: \.self) { type in
                                    Text(type.rawValue).tag(type)
                                }
                            }
                            .labelsHidden()
                            .frame(maxWidth: .infinity, minHeight: 38)
                            .background(Color.surfaceContainerLowest)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.outlineVariant, lineWidth: 1))
                        }
                    }

                    // Description
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("DESCRIPTION")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.onSurfaceVariant)
                                .tracking(0.5)
                            Spacer()
                            Text("\(description.count) / 2000")
                                .font(.system(size: 9))
                                .foregroundColor(description.count > 1800 ? .primaryBlue : .onSurfaceVariant.opacity(0.5))
                        }
                        TextEditor(text: $description)
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.onSurface)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 160)
                            .padding(10)
                            .background(Color.surfaceContainerLowest)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.outlineVariant, lineWidth: 1))
                    }

                    // Actions
                    HStack {
                        HStack(spacing: 6) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 12))
                            Text("Responses usually take 24-48 hours.")
                                .font(.system(size: 10))
                        }
                        .foregroundColor(.onSurfaceVariant.opacity(0.6))

                        Spacer()

                        Button(action: submitFeedback) {
                            HStack(spacing: 6) {
                                if isSubmitting {
                                    ProgressView()
                                        .controlSize(.small)
                                        .tint(.white)
                                } else {
                                    Text("Submit Feedback")
                                        .font(.system(size: 14, weight: .semibold))
                                    Image(systemName: "paperplane.fill")
                                        .font(.system(size: 12))
                                }
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.primaryBlue)
                            .cornerRadius(8)
                            .shadow(color: Color.primaryBlue.opacity(0.3), radius: 8, y: 4)
                        }
                        .buttonStyle(.plain)
                        .disabled(isSubmitting || subject.isEmpty || description.isEmpty)
                        .opacity(subject.isEmpty || description.isEmpty ? 0.5 : 1)
                    }
                    .padding(.top, 8)
                }
                .padding(28)
                .background(Color.surfaceContainer.opacity(0.7))
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.outlineVariant.opacity(0.4), lineWidth: 1))
                .frame(maxWidth: 600)
            }
            .frame(maxWidth: .infinity)
            .padding(20)
        }
        .background(Color.surface)
        .overlay(alignment: .bottom) {
            if showSuccess {
                successToast
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 20)
            }
        }
        .animation(.spring(response: 0.4), value: showSuccess)
    }

    private var successToast: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.primaryBlue)
            Text("Feedback submitted successfully! Thank you.")
                .font(.system(size: 13))
                .foregroundColor(.onSurface)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.surfaceContainer.opacity(0.9))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.primaryBlue.opacity(0.3), lineWidth: 1))
        .shadow(color: .black.opacity(0.3), radius: 10, y: 4)
    }

    private func submitFeedback() {
        isSubmitting = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            isSubmitting = false
            subject = ""
            description = ""
            feedbackType = .suggestion
            showSuccess = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                showSuccess = false
            }
        }
    }
}
