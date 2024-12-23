//
//  RecipeDetail.swift
//  FetchRecipes
//
//  Created by Nasi Robinson on 12/22/24.
//

import SwiftUI
import Translation

struct RecipeDetail: View {
    @ObservedObject var viewModel: RecipeDetailViewModel
    
    @State private var showTranslation = false
    
    var recipe: Recipe {
        viewModel.recipe
    }
    
    var body: some View {
        ScrollView {
            VStack {
                cuisineLabel()
                recipeImage()
                recipeYouTube()
            }
        }
        .navigationTitle(recipe.name)
        .onAppear {
            withAnimation {
                viewModel.fetchMetadata()
            }
        }
    }
    
    @ViewBuilder
    func recipeImage() -> some View {
        if let photoUrl = recipe.photoUrlLarge {
            AsyncImage(url: URL(string: photoUrl), scale: 100, content: { image in
                image.resizable()
                    .aspectRatio(contentMode: .fit)
            }, placeholder: {
                
            })
            .onTapGesture {
                if let sourceUrl = recipe.sourceUrl {
                    UIApplication.shared.open(URL(string: sourceUrl)!)
                }

            }
        }
    }
    
    @ViewBuilder
    func cuisineLabel() -> some View {
        HStack {
            Text(recipe.cuisine)
                .lineLimit(nil)
                .font(.largeTitle)
                .padding(4)
                .background(Color.blue)
                .cornerRadius(8)
                .padding(.leading)
            Spacer()
        }
    }
    
    @ViewBuilder
    func recipeYouTube() -> some View {
        if let youtubeLink = viewModel.youtubeUrl {
            HStack {
                Text("Youtube:")
                    .font(.title)
                    .padding(.horizontal)
                if let summary = viewModel.summary {
                    Text(summary)
                        .lineLimit(nil)
                        .onLongPressGesture {
                            showTranslation.toggle()
                        }
                        .translationPresentation(isPresented: $showTranslation,
                                                 text: summary ){ translatedText in
                            viewModel.summary = translatedText
                        }
                }
                Spacer()
            }
            RemoteVideoUrlView(videoUrl: youtubeLink)
                .frame(height: 300)
        }
    }
}

#Preview {
    NavigationView {
        RecipeDetail(viewModel: .init(recipe: .init(name: "Apam Balik", uuid: "0c6ca6e7-e32a-4053-b824-1dbf749910d8", cuisine: "Malaysian", photoUrlLarge: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/large.jpg", photoUrlSmall: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/small.jpg", sourceUrl: "https://www.nyonyacooking.com/recipes/apam-balik~SJ5WuvsDf9WQ", youtubeUrl: "https://www.youtube.com/watch?v=6R8ffRRJcrg")))
    }
}
