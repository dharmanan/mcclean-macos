import SwiftUI

struct AppUninstallerView: View {
    @StateObject private var viewModel = AppUninstallerViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("App Uninstaller")
                    .font(.title2.bold())
                Spacer()
                Button("Refresh") {
                    Task { await viewModel.loadApps() }
                }
                .disabled(viewModel.isLoading)
            }

            if viewModel.isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Loading apps...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(viewModel.apps) { app in
                    HStack(spacing: 12) {
                        if let icon = app.icon {
                            Image(nsImage: icon)
                                .resizable()
                                .frame(width: 32, height: 32)
                        } else {
                            Image(systemName: "app")
                                .frame(width: 32, height: 32)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(app.name)
                            Text(app.bundleIdentifier)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text(app.displaySize)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Button("Uninstall") {
                            Task { await viewModel.uninstall(app) }
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
        }
        .padding()
        .task {
            await viewModel.loadApps()
        }
        .alert(
            "Uninstall Failed",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "Unknown error")
        }
    }
}
