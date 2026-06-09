import Dependencies
import UIKit

struct OpenURLClient {
    var open: @Sendable (URL) async -> Void
}

extension OpenURLClient: DependencyKey {
    static let liveValue = OpenURLClient(
        open: { url in
            await MainActor.run {
                UIApplication.shared.open(url)
            }
        }
    )

    static let previewValue = OpenURLClient(open: { _ in })
    static let testValue = OpenURLClient(open: { _ in })
}

extension DependencyValues {
    var openURLClient: OpenURLClient {
        get { self[OpenURLClient.self] }
        set { self[OpenURLClient.self] = newValue }
    }
}
