//
//  Event+CoreDataProperties.swift
//  
//
//  Created by Luvina on 9/29/16.
//
//

import Foundation
import CoreData


extension Event {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Event> {
        return NSFetchRequest<Event>(entityName: "Event");
    }

    @NSManaged public var id: Int16
    @NSManaged public var title: String?
    @NSManaged public var start: String?
    @NSManaged public var end: String?
    @NSManaged public var alert: Bool
    @NSManaged public var note: String?

}
