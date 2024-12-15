import ComposableArchitecture
import SwiftUI

// MARK: - Feature

@Reducer
struct ___VARIABLE_MODULENAME___Feature {
    
    @ObservableState
    struct State: Equatable {
        
    }
    
    enum Action {
        case viewAppeared
    }
        
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewAppeared:
                return .none
            }
        }
    }
    
}

// MARK: - View

struct ___VARIABLE_MODULENAME___View: View {
    @Bindable var store: StoreOf<___VARIABLE_MODULENAME___Feature>

    var body: some View {
        Text("___VARIABLE_MODULENAME___")
        .onAppear {
            store.send(.viewAppeared)
        }
    }
}

// MARK: - Preview

#Preview("Default") {
    ___VARIABLE_MODULENAME___View(
        store: Store(
            initialState: ___VARIABLE_MODULENAME___Feature.State()
        ) {
            ___VARIABLE_MODULENAME___Feature()
        }
    )
}
