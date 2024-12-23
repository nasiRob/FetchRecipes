//
//  RecipeService.swift
//  FetchRecipes
//
//  Created by Nasi Robinson on 12/22/24.
//

import Foundation

class RecipeService {
    static let shared = RecipeService()
    
    var baseURL: URL? = URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-empty.json")
    
    enum Urls {
        static let baseURLEmpty = URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-empty.json")
        static let baseUrl = URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json")
    }
    
    enum Error: Swift.Error {
        case invalidURL
        case invalidData
    }
    
    func fetchRecipes() async throws -> [Recipe] {
        
        guard let baseURL else {
            throw Error.invalidURL
        }
        
        let result = try await URLSession.shared.data(from: baseURL)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let recipeList = try decoder.decode(RecipeList.self, from: result.0)
        guard !recipeList.recipes.isEmpty else {
            throw Error.invalidData
        }
        StorageManager.saveRecipesToUserDefaults(recipeList.recipes)
        return recipeList.recipes
    }
}
class FetchURLSession: SessionProtocol {
    func data(from url: URL) async throws -> (Data, URLResponse) {
        try await URLSession.shared.data(from: url)
    }
}
protocol SessionProtocol {
    func data(from url: URL) async throws -> (Data, URLResponse)
}
