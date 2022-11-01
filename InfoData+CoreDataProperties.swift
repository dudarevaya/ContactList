//
//  InfoData+CoreDataProperties.swift
//  M20
//
//  Created by Яна Дударева on 17.09.2022.
//
//

import Foundation
import CoreData


extension InfoData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<InfoData> {
        return NSFetchRequest<InfoData>(entityName: "InfoData")
    }

    @NSManaged public var birth: String?
    @NSManaged public var country: String?
    @NSManaged public var lastName: String?
    @NSManaged public var name: String?
    @NSManaged public var occupation: String?

}

extension InfoData : Identifiable {

}
