import SwiftUI

struct CategoryRow: View {
    let category: ScanCategory
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: category.type.icon)
                .font(.title3).frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(category.type.rawValue).font(.subheadline)
                Text(category.displaySize).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Text("\(category.items.count)").font(.caption2).foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}
