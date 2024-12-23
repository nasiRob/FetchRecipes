//
//  RecipeGridView.swift
//  FetchRecipes
//
//  Created by Nasi Robinson on 12/23/24.
//

import SwiftUI

struct RecipeGridView: View {
    @StateObject var viewModel =  RecipeGridViewModel()
    
    let padding: CGFloat = 4
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical) {
                LazyVGrid(columns:[.init(.flexible(minimum: 100, maximum: 200)),
                                   .init(.flexible(minimum: 100, maximum: 200))] , spacing: 5) {            ForEach(viewModel.recipes) { recipe in
                                       NavigationLink(value: recipe) {
                                           recipeGridView(recipe: recipe)
                                       }
                                   }
                                   }
                                   .padding(padding)
            }
        }
        .onAppear {
            viewModel.fetchRecipes()
        }
    }
    
    @ViewBuilder
    func recipeGridView(recipe: Recipe, width: CGFloat = 100) -> some View {
            ZStack {
                if let image = viewModel.recipeImage(for: recipe) {
                    image
                        .resizable()
                        .scaledToFit()
                        .clipped(antialiased: true)
                } else {
                    Image(systemName: "fork.knife")
                        .resizable()
                        .scaledToFit()
                        .clipped()
                }
                VStack {
                    HStack(alignment: .top) {
                        Spacer()
                        Text(recipe.cuisine)
                            .lineLimit(nil)
                            .font(.subheadline)
                            .padding(4)
                            .background(Color.white.opacity(0.70))
                            .cornerRadius(8)
                            .padding()
                    }
                    Spacer()
                    Text(recipe.name)
                        .lineLimit(nil)
                        .font(.subheadline)
                        .padding(4)
                        .background(Color.white.opacity(0.70))
                        .cornerRadius(8)
                        .padding()
                        .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
            }
            .cornerRadius(8)
            .aspectRatio(1, contentMode: .fit)
            .clipped(antialiased: true)
    }
}

#Preview {
    RecipeGridView()
}
