//
//  RecipeListViewModel.swift
//  FetchRecipes
//
//  Created by Nasi Robinson on 12/22/24.
//

import Foundation
import SwiftUICore
import UIKit

class RecipeGridViewModel: ObservableObject {
    
    @Published var recipes: [Recipe]
    @Published var images: [String: Data]
    @Published var error: Error?
    
    init(recipesFromStorage: [Recipe] = StorageManager.recipesFromStorage) {
        let recipesFromStorage = recipesFromStorage
        recipes = recipesFromStorage
        images = (try? StorageManager.fetchSmallImageData(forUUIDs: recipesFromStorage.compactMap({$0.id}))) ?? [:]
    }
    
    func fetchRecipes(service: RecipeService = RecipeService.shared) {
        // We can adjust this based on if we want to refresh every time or if we want to to wait until a set time
        if recipes.count == 0 {
            Task {
                do {
                    let fetchedRecipes = try await service.fetchRecipes()
                    DispatchQueue.main.async { [weak self] in
                        self?.error = nil
                        self?.recipes = fetchedRecipes
                        if fetchedRecipes.count < 10 {
                            self?.fetchImages(for: fetchedRecipes)
                        } else {
                            let first = fetchedRecipes[0..<10]
                            self?.fetchImages(for: Array(first))
                        }
                    }
                } catch {
                    DispatchQueue.main.async { [weak self] in
                        self?.error = error
                    }
                }
            }
        }
    }
    
    func recipeImage(for recipe: Recipe, urlSession: SessionProtocol = FetchURLSession()) -> Image? {
        if let data = images[recipe.id],
           let uiImage = UIImage(data: data) {
            return .init(uiImage: uiImage)
        } else {
            guard let imageUrlString = recipe.photoUrlSmall,
            let imageUrl = URL(string: imageUrlString) else {
                return nil
            }
            Task {
                do {
                    let response = try await urlSession.data(from: imageUrl)
                    DispatchQueue.main.async { [weak self] in
                        self?.images[recipe.id] = response.0
                    }
                    try StorageManager.saveSmallImageData(uuid: recipe.uuid, data: response.0)
                } catch {
                    // Log error with cache
                }
            }
        }
        return nil
    }
    
    func fetchImages(for recipes: [Recipe]) {
        Task {
            do {
                let images = try StorageManager.fetchSmallImageData(forUUIDs: recipes.compactMap({$0.id}))
                DispatchQueue.main.async { [weak self] in
                    withAnimation {
                        self?.images = images
                    }
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    // Log error.
                    self?.error = error
                }
            }
        }
    }
}


