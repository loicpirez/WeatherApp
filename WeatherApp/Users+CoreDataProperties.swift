//
//  Users+CoreDataProperties.swift
//  
//
//  Created by Loic Pirez on 01/12/2018.
//
//

import Foundation
import CoreData


extension Users {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Users> {
        return NSFetchRequest<Users>(entityName: "Users")
    }

    @NSManaged public var access_token: String?
    @NSManaged public var location: String?
    @NSManaged public var temperature_format: Int16
    @NSManaged public var username: String?

}
