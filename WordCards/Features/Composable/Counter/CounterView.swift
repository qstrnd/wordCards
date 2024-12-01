// Copyright © 2024 Andrei (Andy) Iakovlev. See LICENSE file for details.

import ComposableArchitecture
import SwiftUI

struct CounterView: View {
    let store: StoreOf<CounterFeature>

    var body: some View {
        VStack {
            Text("\(store.count)")
                .monospacedTitleStyle()
            HStack {
                button("-") {
                    store.send(.decrementButtonTapped)
                }
                button("+") {
                    store.send(.incrementButtonTapped)
                }
            }
            button("Fact") {
                store.send(.factButtonTapped)
            }
            button(store.isTimerRunning ? "Stop Timer" : "Start timer") {
                store.send(.toggleTimerButtonTapped)
            }
            Spacer()
            if store.isLoading {
                ProgressView()
            } else if let fact = store.fact {
                Text("\(fact)")
                    .multilineTextAlignment(.center)
                    .monospacedTitleStyle()
            }
            Spacer()
        }
    }

    @ViewBuilder
    func button(_ text: String, action: @escaping () -> Void) -> some View {
        Button(text) {
            action()
        }
        .monospacedTitleStyle()
    }
}

private struct MonospacedTitleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.largeTitle)
            .fontDesign(.monospaced)
            .padding()
            .background(Color.black.opacity(0.1))
            .cornerRadius(10)
    }
}

private extension View {
    func monospacedTitleStyle() -> some View {
        modifier(MonospacedTitleModifier())
    }
}

#Preview {
    CounterView(
        store: Store(initialState: CounterFeature.State(), reducer: {
            CounterFeature()
        })
    )
}
