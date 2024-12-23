//
//  FetchRecipesTests.swift
//  FetchRecipesTests
//
//  Created by Nasi Robinson on 12/22/24.
//

import XCTest
import Combine
@testable import FetchRecipes

class RecipeGridViewModelTests: XCTestCase {
    
    var viewModel: RecipeGridViewModel!
    var mockRecipeService: MockRecipeService!
    var mockStorageManager: MockStorageManager!
    

    override func setUp() {
        super.setUp()
        StorageManager.clearAllData()
        mockRecipeService = MockRecipeService()
        mockStorageManager = MockStorageManager()
        viewModel = RecipeGridViewModel()
    }

    override func tearDown() {
        viewModel = nil
        mockRecipeService = nil
        mockStorageManager = nil
        StorageManager.clearAllData()
        super.tearDown()
    }

    func testFetchRecipesNoInitialRecipes() {
        let expectation = XCTestExpectation(description: "Fetch recipes")
        mockStorageManager.saveImage(with: "1")
        mockRecipeService.recipesToReturn = [Recipe(name: "Test Recipe", uuid: "1", cuisine: "American", photoUrlLarge: nil, photoUrlSmall: nil, sourceUrl: nil, youtubeUrl: nil)]
        viewModel.fetchRecipes(service: mockRecipeService)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(self.viewModel.recipes.count, 1)
            XCTAssertEqual(self.viewModel.recipes.first?.name, "Test Recipe")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testFetchRecipesNoInitialRecipesTen() {
        let expectation = XCTestExpectation(description: "Fetch recipes")
        mockStorageManager.saveImage(with: "1")
        mockRecipeService.recipesToReturn = [
            Recipe(name: "Test Recipe", uuid: "1", cuisine: "American", photoUrlLarge: nil, photoUrlSmall: nil, sourceUrl: nil, youtubeUrl: nil),
            Recipe(name: "Test Recipe", uuid: "2", cuisine: "American", photoUrlLarge: nil, photoUrlSmall: nil, sourceUrl: nil, youtubeUrl: nil),
            Recipe(name: "Test Recipe", uuid: "3", cuisine: "American", photoUrlLarge: nil, photoUrlSmall: nil, sourceUrl: nil, youtubeUrl: nil),
            Recipe(name: "Test Recipe", uuid: "4", cuisine: "American", photoUrlLarge: nil, photoUrlSmall: nil, sourceUrl: nil, youtubeUrl: nil),
            Recipe(name: "Test Recipe", uuid: "5", cuisine: "American", photoUrlLarge: nil, photoUrlSmall: nil, sourceUrl: nil, youtubeUrl: nil),
            Recipe(name: "Test Recipe", uuid: "6", cuisine: "American", photoUrlLarge: nil, photoUrlSmall: nil, sourceUrl: nil, youtubeUrl: nil),
            Recipe(name: "Test Recipe", uuid: "7", cuisine: "American", photoUrlLarge: nil, photoUrlSmall: nil, sourceUrl: nil, youtubeUrl: nil),
            Recipe(name: "Test Recipe", uuid: "8", cuisine: "American", photoUrlLarge: nil, photoUrlSmall: nil, sourceUrl: nil, youtubeUrl: nil),
            Recipe(name: "Test Recipe", uuid: "9", cuisine: "American", photoUrlLarge: nil, photoUrlSmall: nil, sourceUrl: nil, youtubeUrl: nil),
            Recipe(name: "Test Recipe", uuid: "10", cuisine: "American", photoUrlLarge: nil, photoUrlSmall: nil, sourceUrl: nil, youtubeUrl: nil)
        ]
        viewModel.fetchRecipes(service: mockRecipeService)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(self.viewModel.recipes.count, 10)
            XCTAssertEqual(self.viewModel.recipes.first?.name, "Test Recipe")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testImageAvailableInCache() {
         // Setup
         let recipe = Recipe(name: "Test Recipe", uuid: "1", cuisine: "American", photoUrlLarge: nil, photoUrlSmall: nil, sourceUrl: nil, youtubeUrl: nil)
        let imageData = UIImage.checkmark.pngData()!
         viewModel.images[recipe.id] = imageData

         // Execute
         let image = viewModel.recipeImage(for: recipe)

         // Verify
         XCTAssertNotNil(image, "Image should be available from cache without fetching from network")
     }

     func testFetchImageSuccessful() {
         // Setup
         let expectation = XCTestExpectation(description: "Fetch image from network")
         let recipe = Recipe(name: "Test Recipe", uuid: "1", cuisine: "American", photoUrlLarge: nil, photoUrlSmall: "https://example.com/something.png", sourceUrl: nil, youtubeUrl: nil)
         let imageData = UIImage.checkmark.pngData()!
         // Execute
         let mockSession = MockSession()
         mockSession.data = imageData
         let _ = viewModel.recipeImage(for: recipe, urlSession: mockSession)

         DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // Adjust time based on async behavior
             // Verify
             XCTAssertTrue(self.viewModel.images.contains(where: { $0.key == recipe.id }), "Image should be fetched and cached")
             expectation.fulfill()
         }

         wait(for: [expectation], timeout: 2.0)
     }

    func testImageFetchFails() {
        let expectation = XCTestExpectation(description: "Handle fetch image failure")
        let recipe = Recipe(name: "Test Recipe", uuid: "1", cuisine: "American", photoUrlLarge: nil, photoUrlSmall: "http://example.com/broken.png", sourceUrl: nil, youtubeUrl: nil)

        let image = viewModel.recipeImage(for: recipe)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertNil(image, "Should handle failed fetch without crashing")
            XCTAssertNil(self.viewModel.images[recipe.id], "No image should be cached on failure")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }
}
/// RecipeListViewModelTests
class RecipeListViewModelTests: XCTestCase {
    
    var mockRecipeService: MockRecipeService!
    var mockStorageManager: MockStorageManager!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        StorageManager.clearAllData()
        mockRecipeService = MockRecipeService()
        mockStorageManager = MockStorageManager()
        cancellables = []
    }
    
    override func tearDown() {
        mockRecipeService = nil
        mockStorageManager = nil
        StorageManager.clearAllData()
        super.tearDown()
    }
    
    func testFetchRecipesSuccess() {
        let expectation = XCTestExpectation(description: "Fetch recipes successfully")
        let viewModel = RecipeListViewModel()
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let recipes = try? decoder.decode(RecipeList.self, from: MockResponse.mockListResponse.data(using: .utf8)!)
        mockRecipeService.recipesToReturn = recipes?.recipes ?? []
        viewModel.fetchRecipes(service: mockRecipeService)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(viewModel.recipes.count, 63)
            XCTAssertEqual(viewModel.categories.count, 12)
            XCTAssertNil(viewModel.error)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }
    
    func testFetchRecipesFailure() {
        let expectation = XCTestExpectation(description: "Handle error on fetching recipes")
        let viewModel = RecipeListViewModel()
        let error = NSError(domain: "TestError", code: 1, userInfo: nil)
        mockRecipeService.error = .invalidURL
        viewModel.fetchRecipes(service: mockRecipeService)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertNotNil(viewModel.error)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.5)
    }
    func testSortFilter() {
        let recipes = [
            Recipe(name: "Apple Pie", uuid: "1", cuisine: "American", photoUrlLarge: nil, photoUrlSmall: "http://example.com/something.png", sourceUrl: nil, youtubeUrl: nil),
            Recipe(name: "Zuchini", uuid: "2", cuisine: "American", photoUrlLarge: nil, photoUrlSmall: "http://example.com/something.png", sourceUrl: nil, youtubeUrl: nil)]
        mockRecipeService.recipesToReturn = recipes
        MockStorageManager().saveRecipe(recipes)
        let viewModel = RecipeListViewModel()
        viewModel.sortFilter(filterType: .sort(.zyx))
        let expectation = XCTestExpectation(description: "Sort recipes")
        viewModel.$recipes.sink(receiveValue: { recipes in
            guard recipes.count > 0 else {
                return
            }
            let first = recipes.first?.name
            XCTAssertEqual(first, "Zuchini")
            expectation.fulfill() // Ful
        })
        .store(in: &cancellables)
    }
}

class RecipeDetailViewModelTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        StorageManager.clearAllData()
    }
    
    override func tearDown() {
        StorageManager.clearAllData()
        super.tearDown()
    }
    
    
    func testInitializationWithData() {
        
        let recipe =  Recipe(name: "Apple Pie Something log", uuid: "1", cuisine: "American", photoUrlLarge: "http://example.com/something.png", photoUrlSmall: "http://example.com/something.png", sourceUrl: nil, youtubeUrl: nil)
        
        MockStorageManager().saveImage(with: "1")
        let viewModel = RecipeDetailViewModel(recipe: recipe)
        let mockSession = MockSession()
        viewModel.fetchImage(service: mockSession)

        XCTAssertFalse(mockSession.sessionCalled)
    }

    func testInitializationWithoutData() {
        let recipe = Recipe(name: "Apple Pie Something log", uuid: "1", cuisine: "American", photoUrlLarge: "http://example.com/something.png", photoUrlSmall: "http://example.com/something.png", sourceUrl: nil, youtubeUrl: nil)
        let viewModel = RecipeDetailViewModel(recipe: recipe)
        XCTAssertNil(viewModel.data, "No initial data should be available")
        let mockSession = MockSession()
        mockSession.data = UIImage.checkmark.pngData()
        viewModel.fetchImage(service: mockSession)
        let expectation = XCTestExpectation(description: "Handle fetching image data")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertNotNil(viewModel.data)
            expectation.fulfill()
        }
    }
}

/// Mock Dependancies
class MockRecipeService: RecipeService {
    var recipesToReturn: [Recipe] = []
    
    var error: Error?

    override func fetchRecipes() async throws -> [Recipe] {
        if let error = error {
            throw error
        }
        return recipesToReturn
    }
}

class MockStorageManager {
    func saveImage(with id: String) {
        try? StorageManager.saveSmallImageData(uuid: id, data: UIImage.actions.pngData() ?? Data())
    }
    
    func saveRecipe(_ recipes: [Recipe]) {
        StorageManager.saveRecipesToUserDefaults(recipes)
    }
}

class MockSession: SessionProtocol {
    var data: Data?
    var error: Error?
    var sessionCalled = false
    func data(from url: URL) async throws -> (Data, URLResponse) {
            sessionCalled = true
            if let data {
                return (data, URLResponse())
            }
        throw error ?? URLError(.badURL)
    }
    
    
}

