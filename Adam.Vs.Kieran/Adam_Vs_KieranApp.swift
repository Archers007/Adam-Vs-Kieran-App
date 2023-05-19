//
//  Adam_Vs_KieranApp.swift
//  Adam.Vs.Kieran
//
//  Created by Kieran Bendell on 2023-05-19.
//

import SwiftUI

@main
struct Adam_Vs_KieranApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
