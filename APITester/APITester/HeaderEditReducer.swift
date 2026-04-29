import Foundation
import ComposableArchitecture

@Reducer
struct HeaderEditReducer {
    @ObservableState
    struct State: Equatable, Identifiable {
        let id: UUID
        var existingKey: String?
        var key: String
        var value: String

        init(existingKey: String?, key: String, value: String) {
            self.id = Current.uuid()
            self.existingKey = existingKey
            self.key = key
            self.value = value
        }
    }

    enum Action: Equatable, BindableAction {
        case binding(BindingAction<State>)
        case quickContentTypeJSONTapped
        case quickAcceptJSONTapped
        case quickAuthBearerTapped
        case saveTapped
        case deleteTapped
        case cancelTapped
        case delegate(Delegate)

        enum Delegate: Equatable {
            case save(originalKey: String?, key: String, value: String)
            case delete(key: String)
            case cancel
        }
    }

    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .quickContentTypeJSONTapped:
                state.key = "Content-Type"
                state.value = "application/json"
                return .none
            case .quickAcceptJSONTapped:
                state.key = "Accept"
                state.value = "application/json"
                return .none
            case .quickAuthBearerTapped:
                state.key = "Authorization"
                state.value = "Bearer "
                return .none
            case .saveTapped:
                return .send(.delegate(.save(originalKey: state.existingKey,
                                             key: state.key,
                                             value: state.value)))
            case .deleteTapped:
                guard let key = state.existingKey else { return .none }
                return .send(.delegate(.delete(key: key)))
            case .cancelTapped:
                return .send(.delegate(.cancel))
            case .delegate:
                return .none
            }
        }
    }
}
