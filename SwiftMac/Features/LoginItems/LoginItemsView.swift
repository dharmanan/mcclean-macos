import SwiftUI

struct LoginItemsView: View {
    @StateObject private var viewModel = LoginItemsViewModel()

    var body: some View {
        List(viewModel.items) { item in
            HStack(spacing: 12) {
                if let icon = item.icon {
                    Image(nsImage: icon)
                        .resizable()
                        .frame(width: 28, height: 28)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name)
                    Text(item.path)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                Toggle(
                    "",
                    isOn: Binding(
                        get: { item.isEnabled },
                        set: { viewModel.setEnabled($0, for: item) }
                    )
                )
                .labelsHidden()
            }
        }
        .navigationTitle("Login Items")
        .task {
            await viewModel.load()
        }
    }
}
