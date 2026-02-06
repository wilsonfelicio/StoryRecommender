import SwiftUI

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()

    var body: some View {
        Form {
            // MARK: - Provider Selection
            Section {
                Picker("AI Provider", selection: $viewModel.selectedProvider) {
                    ForEach(LLMProvider.allCases) { provider in
                        HStack {
                            Image(systemName: provider.iconName)
                            Text(provider.displayName)
                        }
                        .tag(provider)
                    }
                }
                .pickerStyle(.inline)
                .onChange(of: viewModel.selectedProvider) {
                    viewModel.loadCurrentKey()
                }
            } header: {
                Text("AI Provider")
            } footer: {
                Text("Choose which AI service generates your stories.")
            }

            // MARK: - API Key
            Section {
                if viewModel.isUsingBuiltInKey && viewModel.selectedProvider == .anthropic {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.shield.fill")
                            .foregroundStyle(.green)
                        Text("Using built-in key")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("API Key")
                        .font(.subheadline.weight(.medium))
                    SecureField(viewModel.selectedProvider.apiKeyPlaceholder, text: $viewModel.apiKeyInput)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .font(.system(.body, design: .monospaced))
                }

                HStack(spacing: 12) {
                    Button {
                        viewModel.saveKey()
                    } label: {
                        HStack {
                            Image(systemName: "lock.shield")
                            Text("Save Key")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.indigo)
                    .disabled(viewModel.isSaving)

                    if viewModel.hasUserKey {
                        Button(role: .destructive) {
                            viewModel.deleteKey()
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                Text("Remove")
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                }

                if let message = viewModel.saveMessage {
                    Label(message, systemImage: viewModel.saveSuccess ? "checkmark.circle" : "xmark.circle")
                        .font(.caption)
                        .foregroundStyle(viewModel.saveSuccess ? .green : .red)
                }
            } header: {
                Text("API Key")
            } footer: {
                if viewModel.selectedProvider == .anthropic {
                    Text("Optional. A built-in key is available as fallback. Add your own key for personal usage limits.")
                } else {
                    Text("Required. Paste your \(viewModel.selectedProvider.displayName) API key. Stored securely in iOS Keychain.")
                }
            }

            // MARK: - Test Connection
            Section {
                Button {
                    viewModel.testKey()
                } label: {
                    HStack {
                        if viewModel.isTestingKey {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Image(systemName: "antenna.radiowaves.left.and.right")
                        }
                        Text("Test Connection")
                    }
                }
                .disabled(viewModel.isTestingKey || !LLMSettings.shared.hasAPIKey)

                if let result = viewModel.testResult {
                    Label(result, systemImage: viewModel.testSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(viewModel.testSuccess ? .green : .red)
                }
            } header: {
                Text("Connection Test")
            } footer: {
                Text("Send a quick test message to verify your API key works.")
            }

            // MARK: - Info
            Section {
                LabeledContent("Current Provider", value: viewModel.selectedProvider.displayName)
                LabeledContent("Model", value: viewModel.selectedProvider.defaultModel)
                LabeledContent("Key Source", value: viewModel.isUsingBuiltInKey ? "Built-in" : (viewModel.hasUserKey ? "Your key" : "None"))
            } header: {
                Text("Current Configuration")
            }
        }
        .navigationTitle("Settings")
        .onAppear {
            viewModel.loadCurrentKey()
        }
    }
}
