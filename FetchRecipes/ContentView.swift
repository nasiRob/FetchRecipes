//
//  ContentView.swift
//  FetchRecipes
//
//  Created by Nasi Robinson on 12/22/24.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        NavigationStack {
            TabView {
                RecipeListView()
                    .tabItem({
                        Image(systemName: "list.bullet")
                    })
                RecipeGridView()
                    .tabItem({
                        Image(systemName: "square.grid.2x2")
                    })
            }
            .navigationDestination(for: Recipe.self,
                                   destination: { recipe in
                RecipeDetail(viewModel: .init(recipe: recipe))
            })
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
