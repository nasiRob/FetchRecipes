//
//  RecipeListViewModel.swift
//  FetchRecipes
//
//  Created by Nasi Robinson on 12/22/24.
//

import SwiftUI

struct RecipeListView: View {
    @StateObject var viewModel: RecipeListViewModel = .init()
    @State var isFilterPresented: Bool = false
    @State var showSort = false
    
    var body: some View {
        NavigationView {
            if viewModel.error != nil {
                ErrorView(retry: { viewModel.fetchRecipes() })
            } else {
                List(viewModel.recipes) { recipe in
                    NavigationLink(value: recipe,
                                   label: {
                        recipeRow(recipe)
                    })
                }
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button(action: {
                            // Action to present filter options
                            showSort = false
                            isFilterPresented = true
                        }) {
                            Label("Filter", systemImage: "line.horizontal.3.decrease.circle")
                        }
                        
                        Button(action: {
                            // Action to present filter options
                            showSort = true
                            isFilterPresented = true
                        }) {
                            Text("Sort")
                        }
                    }
                }
                .actionSheet(isPresented: $isFilterPresented, content: {
                    ActionSheet(title: Text("Filter"), buttons: filterButtons())
                })
            }
        }
        .onAppear {
            viewModel.fetchRecipes()
        }
    }
    @ViewBuilder
    func recipeRow(_ recipe: Recipe) -> some View {
        Text(recipe.name)
    }
    
    func filterButtons() -> [ActionSheet.Button] {
        var buttons: [ActionSheet.Button] = [.cancel(Text("Clear"), action: {viewModel.sortFilter(filterType: .clear)})]
        
        if showSort {
            buttons.append(.default(Text("Alphabetical: A to Z"), action: {
                viewModel.sortFilter(filterType: .sort(.abc))
            }))
            buttons.append(.default(Text("Alphabetical: Z to A"), action: {
                viewModel.sortFilter(filterType: .sort(.zyx))
            }))
        } else {
            buttons.append(.default(Text("Video"), action: {
                viewModel.sortFilter(filterType: .hasYouTube)
            }))
            buttons += viewModel.categories.compactMap({ cuisin in
                ActionSheet.Button.default(Text(cuisin),
                                           action: {
                    viewModel.sortFilter(filterType: .filterCuisine(cuisin))
                })
            })
        }
        return buttons
    }
}

#Preview {
    RecipeListView()
}
