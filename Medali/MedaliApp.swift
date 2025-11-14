//
//  MedaliApp.swift
//  Medali
//
//  Created by Kavindu Dilshan on 2025-11-13.
//

import SwiftUI

@main
struct MedaliApp: App {
    let persistenceController = PersistenceController.shared

    @StateObject private var notificationService = NotificationService()
    @StateObject private var healthKitService = HealthKitService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(notificationService)
                .environmentObject(healthKitService)
                .onAppear {
                    notificationService.requestAuthorization()
                    healthKitService.requestAuthorization()
                }
        }
    }
}
