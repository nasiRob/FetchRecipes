//
//  RecipeDetailViewModel.swift
//  FetchRecipes
//
//  Created by Nasi Robinson on 12/22/24.
//

import Foundation
import LinkPresentation
import CoreData
import SwiftUI

class RecipeDetailViewModel: ObservableObject {
    let recipe: Recipe
    var data: Data?
    var fetchImageData: Bool = false
    @Published var youtubeUrl: URL?
    @Published var summary: String?
    
    init(recipe: Recipe) {
        self.recipe = recipe
        let imageData = try? StorageManager.fetchImageData(byUUID: recipe.uuid)
        data = imageData?.data
        if let timestamp = imageData?.timestamp {
            // Update cache if its been 24 hrs. This number can be altered based on image updating information.. If images are never updated theres no need to update the cache if an image is present
            fetchImageData = timestamp < Date().addingTimeInterval(-60 * 60 * 24)
        }
    }
    
    func fetchImage(service: SessionProtocol = FetchURLSession()) {
        guard let imageUrlString = recipe.photoUrlLarge, !fetchImageData,
        let imageUrl = URL(string: imageUrlString) else {
            return
        }
        Task {
            do {
                let response = try await service.data(from: imageUrl)
                try StorageManager.saveImageData(uuid: recipe.uuid, data: response.0)
                DispatchQueue.main.async { [weak self] in
                    withAnimation {
                        self?.data = response.0
                    }
                }
                fetchImageData = false
            } catch {
                // Log error with cache
            }
        }
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
                    withAnimation {
                        self?.youtubeUrl = metadata.remoteVideoURL
                        self?.summary = metadata.value(forKey: "summary") as? String
                    }
                }
            } catch {
                // TODO: Log error
            }
        }
    }
}
