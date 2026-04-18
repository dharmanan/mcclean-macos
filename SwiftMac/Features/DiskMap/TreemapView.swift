import SwiftUI

struct TreemapView: View {
    let items: [DiskMapItem]

    var body: some View {
        GeometryReader { proxy in
            let total = max(items.reduce(0) { $0 + max(0, $1.size) }, 1)

            HStack(spacing: 8) {
                ForEach(items) { item in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(item.name)
                            .font(.headline)
                        Text(item.size.byteString)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding()
                    .frame(
                        width: max(120, proxy.size.width * CGFloat(Double(item.size) / Double(total))),
                        height: proxy.size.height
                    )
                    .background(item.color.opacity(0.18))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
        }
    }
}
