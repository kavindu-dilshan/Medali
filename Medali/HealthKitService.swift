import Foundation
import HealthKit
import Combine

final class HealthKitService: ObservableObject {
    @Published var todayStepCount: Double = 0

    private let healthStore: HKHealthStore? = HKHealthStore.isHealthDataAvailable() ? HKHealthStore() : nil

    func requestAuthorization() {
        guard let healthStore = healthStore,
              let stepsType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            DispatchQueue.main.async {
                self.todayStepCount = 0
            }
            return
        }

        let readTypes: Set<HKObjectType> = [stepsType]
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { [weak self] success, _ in
            guard let self = self else { return }
            if success {
                self.fetchTodaySteps()
            } else {
                DispatchQueue.main.async {
                    self.todayStepCount = 0
                }
            }
        }
    }

    func fetchTodaySteps() {
        guard let healthStore = healthStore,
              let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            DispatchQueue.main.async {
                self.todayStepCount = 0
            }
            return
        }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: stepsType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, _ in
            guard let self = self else { return }
            let unit = HKUnit.count()
            let value = result?.sumQuantity()?.doubleValue(for: unit) ?? 0
            DispatchQueue.main.async {
                self.todayStepCount = value
            }
        }

        healthStore.execute(query)
    }
}
