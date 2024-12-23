//
//  ErrorView.swift
//  FetchRecipes
//
//  Created by Nasi Robinson on 12/23/24.
//

import SwiftUI

struct ErrorView: View {
    var retry: (() -> Void)?
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "exclamationmark.triangle")
                .resizable()
                .frame(width: 100, height: 100)
            Text("Sorry we could not retieve any recipes")
                .font(.subheadline)
            if retry != nil {
                Button("Retry") { retry?() }
                    .buttonStyle(.bordered)
            }
            Spacer()
        }
    }
}

#Preview {
    ErrorView(retry: {})
}
