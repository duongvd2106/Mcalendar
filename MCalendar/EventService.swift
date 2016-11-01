//
//  EventService.swift
//  MCalendar
//
//  Created by Luvina on 9/29/16.
//  Copyright © 2016 Luvina. All rights reserved.
//

import Foundation

class EventService: NSObject {
    // MARK: properties
    private var eventRepository = EventRepository()
    
    // MARK: - read
    func addEvent(event: EventDto, handle: @escaping (Bool, Error?) -> Void) {
        
        eventRepository.addEvent(event: event, handle: handle)
    }
    
    func updateEvent(event: EventDto, handle: @escaping (Bool, Error?) -> Void) {
        
        eventRepository.updateEvent(event: event, handle: handle)
    }
    
    func deleteEvent(eventId: String) {
        
        eventRepository.deleteEvent(eventId: eventId)
    }
    
    // MARK: - write
    func getEventById(eventId: String) -> EventDto? {
        
        if let entity = eventRepository.getEventById(eventId: eventId) {
            
            let event = EventService.parseDto(entity)
            return event
        }
        return nil
    }
    
    func getListEvent() -> [EventDto] {
        var events = [EventDto]()
        if let entities = eventRepository.getListEvent() {
            for entity in entities {
                
                let event = EventService.parseDto(entity)
                events.append(event)
            }
        }
        return events
    }
    
    func getListEventByDate(queryDay: String) -> [EventDto] {
        var events = [EventDto]()
        if let entities = eventRepository.getListEventByDate(date: queryDay) {
            for entity in entities {
                
                let event = EventService.parseDto(entity)
                events.append(event)
            }
        }
        return events
    }
}

extension EventService {
    
    // MARK: - parse entity -> dto
    static func parseDto(_ event: Event) -> EventDto {
        
        let eventDto = EventDto()
        
        eventDto.id = event.id
        eventDto.title = event.title
        eventDto.start = event.start
        eventDto.end = event.end
        eventDto.alert = event.alert
        eventDto.note = event.note
        eventDto.img = event.img
        eventDto.imgBin = event.imgBin
        return eventDto
    }
}
