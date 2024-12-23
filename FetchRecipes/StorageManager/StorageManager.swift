import Foundation
import CoreData

struct StorageManager {
    
    static var recipesFromStorage: [Recipe] = {
        loadRecipesFromUserDefaults() ?? []
    }()
    
    static func saveRecipesToUserDefaults(_ recipes: [Recipe]) {
            guard !recipes.isEmpty else { return }

            let encoder = JSONEncoder()
            do {
                let data = try encoder.encode(recipes)
                UserDefaults.standard.set(data, forKey: "Recipes")
                recipesFromStorage = recipes
            } catch {
                print("Error encoding recipes: \(error)")
            }
    }
    static func loadRecipesFromUserDefaults() -> [Recipe]? {
        if let data = UserDefaults.standard.data(forKey: "Recipes") {
            let decoder = JSONDecoder()
            do {
                let recipes = try decoder.decode([Recipe].self, from: data)
                return recipes
            } catch {
                print("Error decoding recipes: \(error)")
            }
        }
        return nil
    }
    
    static func fetchSmallImageData(forUUIDs uuids: [String], context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) throws -> [String: Data] {
        let fetchRequest = NSFetchRequest<SmallImageData>(entityName: "SmallImageData")
        fetchRequest.predicate = NSPredicate(format: "uuid IN %@", uuids)
        
        let results = try context.fetch(fetchRequest)
        
        return Dictionary(uniqueKeysWithValues: results.compactMap { imageData in
            guard let data = imageData.data, let uuid = imageData.uuid else { return nil }
            return (uuid, data)
        })
    }
    
    static func fetchImageData(byUUID uuid: String,
                               context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) throws -> ImageData? {
        
        let fetchRequest: NSFetchRequest<ImageData> = ImageData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", uuid) // Updated to handle UUID
        fetchRequest.fetchLimit = 1 // Limit to a single result, since UUID is unique
        
        let results = try context.fetch(fetchRequest)
        return results.first
    }
    
    static func saveImageData(uuid: String, data: Data) throws {
        let context = PersistenceController.shared.container.viewContext

        try context.performAndWait {
            let imageData = ImageData(context: context)
            imageData.uuid = uuid
            imageData.data = data
            imageData.timestamp = Date()

            try context.save()
        }
    }
    
    static func saveSmallImageData(uuid: String, data: Data) throws {
           let context = PersistenceController.shared.container.viewContext

           try context.performAndWait {
               // Fetch request to find existing image data with the specified UUID
               let fetchRequest: NSFetchRequest<SmallImageData> = SmallImageData.fetchRequest()
               fetchRequest.predicate = NSPredicate(format: "uuid == %@", uuid)
               let results = try fetchRequest.execute()

               if let existingImageData = results.first {
                   // Update existing image data
                   existingImageData.data = data
                   existingImageData.timestamp = Date()
                   let imageData = existingImageData
               } else {
                   // Create new image data
                   let newImageData = SmallImageData(context: context)
                   newImageData.uuid = uuid
                   newImageData.data = data
                   newImageData.timestamp = Date()
                   let imageData = newImageData
               }

               // Save changes to the context
               if context.hasChanges {
                   try context.save()
               }
           }
       }
    
    static func clearAllData() {
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
            UserDefaults.standard.synchronize()
        }
        let context = PersistenceController.shared.container.viewContext
          let entities = PersistenceController.shared.container.managedObjectModel.entities
          
          entities.compactMap({ $0.name }).forEach { entityName in
              let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
              let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

              do {
                  try context.execute(deleteRequest)
              } catch let error as NSError {
                  print("Error clearing entity \(entityName): \(error), \(error.userInfo)")
              }
          }

          do {
              try context.save()
          } catch let error as NSError {
              print("Error saving context after clearing data: \(error), \(error.userInfo)")
          }
      }
}
