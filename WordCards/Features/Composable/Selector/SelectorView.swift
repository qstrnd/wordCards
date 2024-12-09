// Copyright © 2024 Andrei (Andy) Iakovlev. See LICENSE file for details.

import ComposableArchitecture
import SwiftUI

struct SelectorView: View {
    let store: StoreOf<SelectorFeature>

    var body: some View {
        VStack {
            Picker(
                "Select a counter",
                selection: pickerBinding
            ) {
                ForEach(SelectorFeature.State.SelectedSegment.allCases, id: \.self) { segment in
                    Text(segment.rawValue)
                }
            }
            .pickerStyle(.segmented)

            Spacer()

            switch store.selectedSegment {
            case .firstCounter:
                CounterView(
                    store: store.scope(state: \.firstCounter, action: SelectorFeature.Action.firstCounter)
                )
            case .secondCounter:
                CounterView(
                    store: store.scope(state: \.secondCounter, action: SelectorFeature.Action.secondCounter)
                )
            }
        }
        .padding()
    }

    private var pickerBinding: Binding<SelectorFeature.State.SelectedSegment> {
        Binding<SelectorFeature.State.SelectedSegment>(
            get: { store.selectedSegment },
            set: { selectedSegment in
                store.send(.selectedSegmentChanged(selectedSegment))
            }
        )
    }
}

#Preview {
    SelectorView(store: Store(initialState: SelectorFeature.State(), reducer: {
        SelectorFeature()
    }))
}
