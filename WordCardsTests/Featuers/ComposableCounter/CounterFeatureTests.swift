// Copyright © 2024 Andrei (Andy) Iakovlev. See LICENSE file for details.

import ComposableArchitecture
import Testing

@testable import WordCards

@MainActor
struct CounterFeatureTests {
    @Test
    func testIncrementDecrement() async {
        let store = TestStore(initialState: CounterFeature.State()) {
            CounterFeature()
        }

        await store.send(.incrementButtonTapped) {
            $0.count = 1
        }

        await store.send(.decrementButtonTapped) {
            $0.count = 0
        }
    }

    @Test
    func testTimer() async {
        let clock = TestClock()

        let store = TestStore(initialState: CounterFeature.State()) {
            CounterFeature()
        } withDependencies: {
            $0.continuousClock = clock
        }

        await store.send(.toggleTimerButtonTapped) {
            $0.isTimerRunning = true
        }

        await clock.advance(by: .seconds(1))
        await store.receive(\.timerTick, timeout: .seconds(1)) {
            $0.count = 1
        }

        await store.send(.toggleTimerButtonTapped) {
            $0.isTimerRunning = false
        }
    }

    @Test
    func testNumberFact() async {
        let store = TestStore(initialState: CounterFeature.State()) {
            CounterFeature()
        } withDependencies: {
            $0.numberFact.fetch = { "\($0) is a good number." }
        }

        await store.send(.factButtonTapped) {
            $0.isLoading = true
        }

        await store.receive(\.factResponse, timeout: .seconds(1)) {
            $0.isLoading = false
            $0.fact = "0 is a good number."
        }
    }
}
