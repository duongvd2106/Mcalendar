//
//  EventRepository.swift
//  MCalendar
//
//  Created by Luvina on 9/29/16.
//  Copyright © 2016 Luvina. All rights reserved.
//
import MagicalRecord

class EventRepository: NSObject {
    
    // MARK: - write
    func addEvent(event: EventDto, handle: @escaping (Bool, Error?) -> Void) {
        
        let completeHander: MRSaveCompletionHandler = handle
        MagicalRecord.save (
            { (context) in
                
                let entity = Event.mr_createEntity(in: context)!
                
                //entity.id = NSUUID().uuidString
                entity.id = event.id
                entity.title = event.title
                entity.start = event.start
                entity.end = event.end
                entity.alert = event.alert
                entity.note = event.note
                entity.img = event.img
                entity.imgBin = event.imgBin
                
                print("///////////addEvent context = \(context)") // debug
                print("///////////entity = ", entity.toString())
                
            }, completion: completeHander)
    }
    
    func updateEvent(event: EventDto, handle: @escaping (Bool, Error?) -> Void) {
        
        let completeHander: MRSaveCompletionHandler = handle
        MagicalRecord.save(
            { (context) in
                
                let predicate = NSPredicate(format: "id = '\(event.id)'")
                
                if let entity = Event.mr_findFirst(with: predicate, in: context) {
                    
                    entity.title = event.title
                    entity.start = event.start
                    entity.end = event.end
                    entity.alert = event.alert
                    entity.note = event.note
                    entity.img = event.img
                    entity.imgBin = event.imgBin
                    
                    print("///////////updateEvent context = \(context)") // debug
                    print("///////////entity = ", entity.toString())
                }
        }, completion: completeHander)
    }
    
    func deleteEvent(eventId: String) {
        
        MagicalRecord.save ({(context) in
            
            print("///////////deleteEvent context = \(context)") // debug
            print("///////////eventId = ", eventId)
            
            let predicate = NSPredicate(format: "id = '\(eventId)'")
            Event.mr_deleteAll(matching: predicate, in: context)
        })
    }
    
    // MARK: - read
    func getEventById(eventId: String) -> Event? {
        
        let predicate = NSPredicate(format: "id = '\(eventId)'")
        if let event = Event.mr_findFirst(with: predicate) {
            return event
        }
        return nil
    }
    
    func getListEvent() -> [Event]? {
        
        if let events = Event.mr_findAll() as! [Event]? {
            return events
        }
        return nil
    }
    
    func getListEventByDate(date: String) -> [Event]? {
        
        let startAt = NSPredicate(format: "start beginswith '\(date)'")
        let endAt = NSPredicate(format: "end beginswith '\(date)'")
        
        let startBefore = NSPredicate(format: "start < '\(date)'")
        let endAfter = NSPredicate(format: "end > '\(date)'")
        let startBeforeAndEndAfter = NSCompoundPredicate.init(andPredicateWithSubpredicates: [startBefore, endAfter])
        
        let finalPredicate = NSCompoundPredicate.init(orPredicateWithSubpredicates: [startAt, endAt, startBeforeAndEndAfter])
        
        if let events = Event.mr_findAll(with: finalPredicate) as! [Event]? {
            return events
        }
        return nil
    }
}
