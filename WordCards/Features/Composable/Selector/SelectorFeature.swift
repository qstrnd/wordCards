// Copyright © 2024 Andrei (Andy) Iakovlev. See LICENSE file for details.

import ComposableArchitecture
import Foundation

@Reducer
struct SelectorFeature {
    @ObservableState
    struct State: Equatable {
        @CasePathable
        enum SelectedSegment: String, Equatable, CaseIterable {
            case firstCounter = "First Counter"
            case secondCounter = "Second Counter"
        }

        var selectedSegment = SelectedSegment.firstCounter
        var firstCounter = CounterFeature.State()
        var secondCounter = CounterFeature.State()
    }

    enum Action {
        case firstCounter(CounterFeature.Action)
        case secondCounter(CounterFeature.Action)
        case selectedSegmentChanged(State.SelectedSegment)
    }

    var body: some ReducerOf<Self> {
        Scope(
            state: \.firstCounter,
            action: \.firstCounter
        ) {
            CounterFeature()
        }
        Scope(
            state: \.secondCounter,
            action: \.secondCounter
        ) {
            CounterFeature()
        }
        Reduce { state, action in
            switch action {
            case .firstCounter:
                return .none
            case .secondCounter:
                return .none
            case let .selectedSegmentChanged(selectedSegment):
                state.selectedSegment = selectedSegment
                return .none
            }
        }
    }
}
