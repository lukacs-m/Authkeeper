//
//  AsyncTimers.swift
//  AuthKeeper
//
//  Created by Martin Lukacs on 15/12/2024.
//

import Foundation

enum ClockType: String, CaseIterable, Identifiable {
    case suspending = "Suspending"
    case continuous = "Continuous"

    var id: String { rawValue }
}

@MainActor
final class MainActorIsolatedTimer {
    private var task: Task<Void, Never>?
    private(set) var isValid = true

    nonisolated init(interval: TimeInterval,
                     repeats: Bool,
                     clockType: ClockType = .continuous,
                     block: @escaping @MainActor (MainActorIsolatedTimer) -> Void) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            task = Task { [weak self] in
                guard let self else { return }
                var isRunning = true
                repeat {
                    do {
                        let nanoSeconds = UInt64(interval * 1_000_000_000)
                        if clockType == .continuous {
                            let clock = ContinuousClock()
                            try await clock.sleep(until: .now + .nanoseconds(nanoSeconds), tolerance: .zero)
                        } else {
                            let clock = SuspendingClock()
                            try await clock.sleep(until: .now + .nanoseconds(nanoSeconds), tolerance: .zero)
                        }

                        try Task.checkCancellation()
                        isRunning = repeats
                        if !isRunning {
                            invalidate()
                        }

                        Task { [weak self] in
                            guard let self else { return }
                            block(self)
                        }
                    } catch {
                        if error is CancellationError {
                            print("Timer is cancelled")
                        }
                        isRunning = false
                        invalidate()
                    }
                } while isRunning
            }
        }
    }

    func invalidate() {
        isValid = false
        task?.cancel()
    }
}
