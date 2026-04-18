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
            }

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
        .padding()
        .task {
            await viewModel.loadApps()
        }
    }
}
