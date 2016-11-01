//
//  Event.swift
//  MCalendar
//
//  Created by Luvina on 9/29/16.
//  Copyright © 2016 Luvina. All rights reserved.
//

import UIKit
import CoreData

class Event : NSManagedObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Event> {
        return NSFetchRequest<Event>(entityName: "Event");
    }
    
    // Attributes
    @NSManaged public var id: String
    
    //@NSManaged var location: CGPoint
    
    @NSManaged public var title: String
    
    @NSManaged public var start: String
    
    @NSManaged public var end: String
    
    @NSManaged public var alert: Bool
    
    @NSManaged public var note: String?
    
    @NSManaged public var img: String?
    
    @NSManaged public var imgBin: Data?
}

extension Event {
    func toString() -> String {
        var str: String = "id: " + id + " "
        str += ("title: " + title + " ")
        str += ("start: " + start + " ")
        str += ("end: " + end + " ")
        str += ("alert: \(alert) ")
        str += ("note: " + note! + " ")
        //str += ("img: " + img! + " ")
        //if let imgBin = imgBin {
        //    str += ("imgBin: " + imgBin.base64EncodedString(options: .endLineWithCarriageReturn)  + " ")
        //}
        return str
    }
}


class EventDto : NSObject {
    
    // Attributes
    public var id: String = ""
    
    //public var location: CGPoint
    
    public var title: String = ""
    
    public var start: String = ""
    
    public var end: String = ""
    
    public var alert: Bool = true
    
    public var note: String?
    
    public var img: String?
    
    public var imgBin: Data?
    
    override init() {
        super.init()
    }
    
    init?(id: String, title: String, start: String, end: String, alert: Bool, note: String?, img: String?, imgBin: Data?) {
        if (title.isEmpty || start.isEmpty || end.isEmpty) {
            return nil
        }
        super.init()
        self.id = id
        self.title = title
        self.start = start
        self.end = end
        self.alert = alert
        self.note = note
        self.img = img
        self.imgBin = imgBin
    }
}
