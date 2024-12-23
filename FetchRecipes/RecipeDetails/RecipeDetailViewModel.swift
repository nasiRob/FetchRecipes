//
//  RecipeDetailViewModel.swift
//  FetchRecipes
//
//  Created by Nasi Robinson on 12/22/24.
//

import Foundation
import LinkPresentation

class RecipeDetailViewModel: ObservableObject {
    let recipe: Recipe
    @Published var youtubeUrl: URL?
    @Published var summary: String?
    
    init(recipe: Recipe) {
        self.recipe = recipe
        
    }
    
    func fetchMetadata() {
        guard let youtubeLink = recipe.youtubeUrl, let metaUrl = URL(string: youtubeLink) else {
            return
        }
        let provider = LPMetadataProvider()

        Task {
            do {
                let metadata = try await provider.startFetchingMetadata(for: metaUrl)
                print(metadata)
                DispatchQueue.main.async { [weak self] in
                    self?.youtubeUrl = metadata.remoteVideoURL
                    self?.summary = metadata.value(forKey: "summary") as? String
                }
            } catch {
                // Log error
            }
        }
    }
    
}
