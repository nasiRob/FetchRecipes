//
//  FetchRecipesApp.swift
//  FetchRecipes
//
//  Created by Nasi Robinson on 12/22/24.
//

import SwiftUI

@main
struct FetchRecipesApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
