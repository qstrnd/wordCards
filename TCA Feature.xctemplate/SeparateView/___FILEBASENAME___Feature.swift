import ComposableArchitecture
import Foundation

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