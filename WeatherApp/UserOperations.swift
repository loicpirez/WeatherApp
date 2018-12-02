import Foundation
import CoreData
import UIKit

@available(iOS 10.0, *)
class UserOperations {

    var context : NSManagedObjectContext?
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Users")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                fatalError("Unresolved error, \((error as NSError).userInfo)")
            }
        })
        return container
    }()

    init() {
        self.context = persistentContainer.viewContext
    }
    
    
    func deleteAllContextObject() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
        request.returnsObjectsAsFaults = false
        do {
            let result = try self.context!.fetch(request)
            for data in result as! [NSManagedObject] {
                self.deleteUser(access_token: (data as! Users).access_token!)
            }
        } catch {
            print("Failed")
        }
    }
    
    
    func insertUser(access_token:String,temperature_format:Int16,location:String,username:String){
        let entity = NSEntityDescription.entity(forEntityName: "Users", in: self.context!)
        let newUser = NSManagedObject(entity: entity!, insertInto: self.context)
        
        newUser.setValue(access_token, forKey: "access_token")
        newUser.setValue(temperature_format, forKey: "temperature_format")
        newUser.setValue(location, forKey: "location")
        newUser.setValue(username, forKey: "username")
        do {
            try self.context!.save()
        } catch {
            print("Failed to insert user")
        }
        
    }
    
    func deleteUser(access_token:String){
        let entity = NSEntityDescription.entity(forEntityName: "Users", in: self.context!)
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
        request.returnsObjectsAsFaults = false
        request.fetchOffset = 0
        request.fetchLimit = 1000
        request.entity = entity
        request.predicate = NSPredicate(format: "access_token = %@", access_token)
        do{
            let results:[AnyObject]? = try self.context!.fetch(request)
            for user:Users in results as! [Users]{
                self.context!.delete(user)
                try self.context!.save()
            }
        } catch{
            print("Failed to delete user.")
        }
    }
    
    func getUser(access_token:String) -> Users? {
        let entity = NSEntityDescription.entity(forEntityName: "Users", in: self.context!)
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
        request.returnsObjectsAsFaults = false
        request.fetchOffset = 0
        request.fetchLimit = 1000
        request.entity = entity
        request.predicate = NSPredicate(format: "access_token = %@", access_token)
        do{
            let results:[AnyObject]? = try self.context!.fetch(request)
            for user:Users in results as! [Users]{
                return user
            }
        } catch{
            print("Failed to get user.")
        }
        return nil
    }
    
    func editUser(access_token:String,temperature_format:Int16,location:String,username:String) {
        let entity = NSEntityDescription.entity(forEntityName: "Users", in: self.context!)
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
        request.returnsObjectsAsFaults = false
        request.fetchOffset = 0
        request.fetchLimit = 1000
        request.entity = entity
        request.predicate = NSPredicate(format: "access_token = %@", access_token)
        do{
            let results:[AnyObject]? = try self.context!.fetch(request)
            for user:Users in results as! [Users]{
                user.location = location
                user.temperature_format = temperature_format
                user.username = username
                try self.context!.save()
            }
        } catch{
            print("Failed to edit user.")
        }
    }

}
