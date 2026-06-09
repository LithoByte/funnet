import Dependencies
import Foundation

struct CoffeeTipClient {
    var hasTipped: @Sendable () -> Bool
    var markTipped: @Sendable () -> Void
    var incrementSuccessCount: @Sendable () -> Int
    var successCount: @Sendable () -> Int
}

extension CoffeeTipClient: DependencyKey {
    static let tippedKey = "hasTippedCoffee"
    static let countKey = "coffeePromptCount"

    // Compile-time gate. In DEBUG builds the tip UI is suppressed by default;
    // flip `isEnabled` to `true` to test the tip jar locally.
    #if DEBUG
    static let isEnabled = false
    #else
    static let isEnabled = true
    #endif

    static let liveValue = CoffeeTipClient(
        hasTipped: { !isEnabled || UserDefaults.standard.bool(forKey: tippedKey) },
        markTipped: {
            guard isEnabled else { return }
            UserDefaults.standard.set(true, forKey: tippedKey)
        },
        incrementSuccessCount: {
            guard isEnabled else { return 0 }
            let next = UserDefaults.standard.integer(forKey: countKey) + 1
            UserDefaults.standard.set(next, forKey: countKey)
            return next
        },
        successCount: { isEnabled ? UserDefaults.standard.integer(forKey: countKey) : 0 }
    )

    static let previewValue = CoffeeTipClient(
        hasTipped: { false },
        markTipped: {},
        incrementSuccessCount: { 0 },
        successCount: { 0 }
    )

    static let testValue = CoffeeTipClient(
        hasTipped: { false },
        markTipped: {},
        incrementSuccessCount: { 0 },
        successCount: { 0 }
    )
}

extension DependencyValues {
    var coffeeTipClient: CoffeeTipClient {
        get { self[CoffeeTipClient.self] }
        set { self[CoffeeTipClient.self] = newValue }
    }
}
