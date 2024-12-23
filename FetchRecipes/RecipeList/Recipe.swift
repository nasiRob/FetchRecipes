//
//  Recipe.swift
//  FetchRecipes
//
//  Created by Nasi Robinson on 12/22/24.
//

import Foundation


struct RecipeList: Codable {
    let recipes: [Recipe]
}

struct Recipe: Hashable, Codable, Identifiable {
    
    var id: String {
        return uuid
    }
    
    let name: String
    let uuid: String
    let cuisine: String
    // Xcode automatically adjust these
    let photoUrlLarge: String?
    let photoUrlSmall: String?
    let sourceUrl: String?
    let youtubeUrl: String?
}
