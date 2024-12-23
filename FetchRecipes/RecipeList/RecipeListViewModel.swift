//
//  RecipeListViewModel.swift
//  FetchRecipes
//
//  Created by Nasi Robinson on 12/22/24.
//

import Foundation
import SwiftUICore

class RecipeListViewModel: ObservableObject {
    
    @Published var recipes: [Recipe] = StorageManager.recipesFromStorage
    @Published var categories: [String] = []
    @Published var error: Error?
    
    func fetchRecipes(service: RecipeService = RecipeService.shared) {
        Task {
            do {
                let fetchedRecipes = try await service.fetchRecipes()
                DispatchQueue.main.async { [weak self] in
                    self?.error = nil
                    self?.categories = Set(fetchedRecipes.map(\.self.cuisine)).sorted()
                    self?.recipes = fetchedRecipes
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    print(error)
                    self?.error = error
                    RecipeService.shared.baseURL = RecipeService.Urls.baseUrl
                }
            }
        }
    }
    
    func sortFilter(filterType: SortFilterType) {
        withAnimation {
            switch filterType {
            case .clear:
                recipes = StorageManager.recipesFromStorage
            case let .filterCuisine(cuisine):
                recipes = StorageManager.recipesFromStorage.filter({ $0.cuisine == cuisine})
            case .hasYouTube:
                recipes = StorageManager.recipesFromStorage.filter({ $0.youtubeUrl != nil })
            case .sort(let sortType):
                switch sortType {
                case .abc:
                    recipes = StorageManager.recipesFromStorage.sorted{$0.name < $1.name}
                case .zyx:
                    recipes = StorageManager.recipesFromStorage.sorted{$0.name > $1.name}
                }
            }
        }
    }
    
    enum SortFilterType {
        case clear
        case filterCuisine(String)
        case hasYouTube
        case sort(SortType)
    }
    
    enum SortType {
        case abc
        case zyx
    }
}

