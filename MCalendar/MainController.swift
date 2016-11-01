//
//  ViewController.swift
//  MCalendar
//
//  Created by Luvina on 9/28/16.
//  Copyright © 2016 Luvina. All rights reserved.
//

import UIKit
import CVCalendar
import UserNotifications

class MainController: UIViewController {

    //MARK: - properties
    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var calendarView: CVCalendarView!
    @IBOutlet weak var lbMonth: UILabel!
    @IBOutlet weak var tblEventList: UITableView!
    
    var animationFinished = true
    var selectedDay:DayView!
    
    var eventService = EventService()
    var lsEvent: [EventDto]!
    
    //MARK: - override controller behavior
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //calendarView.delegate = self
        //calendarView.calendarAppearanceDelegate = self
        menuView.delegate = self
        
        lbMonth.text = CVDate(date: Date()).globalDescription
        
        loadTableView(day: self.selectedDay)
        
        //listDocumentDirFile()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if let selectedPath = self.tblEventList.indexPathForSelectedRow {
            self.tblEventList.deselectRow(at: selectedPath, animated: true)
        }
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        menuView.commitMenuViewUpdate()
        calendarView.commitCalendarViewUpdate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    // MARK: - Action
    @IBAction func todayMonthView() {
        
        if !animationFinished {
            
            print("animation not Finished")
            return
        }
        
        if selectedDay == nil {
            self.calendarView.coordinator.selectedDayView = calendarView.contentController.presentedMonthView.weekViews.first?.dayViews.first
        } else if selectedDay.date.convertedDate()?.compareDateOnly(date: Date()) == true {
            
            let strMonthYear = lbMonth.text!
            
            print("month ='\(strMonthYear.subString(startAt: 6, endAt: strMonthYear.indexOf(char: ",")))'")
            print("year ='\(strMonthYear.subString(startAt: strMonthYear.indexOf(char: ",") + 2, endAt: strMonthYear.characters.count))'")
            
            self.calendarView.coordinator.selectedDayView = selectedDay.monthView?.weekViews?.first?.dayViews?.first
            
            if self.calendarView.coordinator.selectedDayView == nil {
                
                self.calendarView.coordinator.selectedDayView = calendarView.contentController.presentedMonthView.weekViews.first?.dayViews.first
            }
        }
        
        self.calendarView.toggleViewWithDate(Date())
    }
    
    @IBAction func loadPrevMonth(_ sender: UIButton) {
        self.calendarView.loadPreviousView()
    }
    @IBAction func loadNextMonth(_ sender: UIButton) {
        self.calendarView.loadNextView()
    }
    
    func loadTableView(day: DayView?) {
        
        if day == nil {
            
            lsEvent = [EventDto]()
        } else {
            
            var queryDay: String = Date().toLongDateTimeString() as! String
            
            if day != nil {
                queryDay = day!.date.commonDescription.mediumStringtoDate()?.toLongDateTimeString() as! String
            }
            
            queryDay = queryDay.substring(to: queryDay.index(queryDay.startIndex, offsetBy: 10))
            print("queryDay = '\(queryDay)'")
            lsEvent = eventService.getListEventByDate(queryDay: queryDay)
            //lsEvent = eventService.getListEvent()
            if lsEvent.count > 0 {
                lsEvent.sort(by: { (e1, e2) in self.compare2StrDate(str1: e1.start, str2: e2.start) })
//                for event in lsEvent {
//                    print("event = \(event.title): Start: \(event.start) - End: \(event.end)")
//                }
            } else {
                print("-------empty-------")
            }
        }
        //DispatchQueue.main.async {
            self.tblEventList.reloadData()
        //}
    }
    
    // MARK: - navigation
    @IBAction func unwindToMe(sender: UIStoryboardSegue) {
        if let srcController = sender.source as? EventController {
            print("srcController.eventDto = \(srcController.eventDto!)")
            let completeHandle: (Bool, Error?) -> Void = {(true, nil) in
                
                print("////////Save data complete ", Date().toMillisecondString()!) // check performance
                self.loadTableView(day: self.selectedDay)
                
                if srcController.eventDto!.alert {
                    self.createNotification(event: srcController.eventDto!)
                } else {
                    self.removeOldNotification(notificationId: srcController.eventDto!.id)
                }
            }
            if srcController.eventDto!.id != "" {
                eventService.updateEvent(event: srcController.eventDto!, handle: completeHandle)
            } else {
                srcController.eventDto!.id = NSUUID().uuidString
                eventService.addEvent(event: srcController.eventDto!, handle: completeHandle)
            }
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "ShowEventDetail":
            
            let eventDetailScene = segue.destination as! EventController
            if let selectedEvent = sender as? EventTableViewCell {
                let indexPath = tblEventList.indexPath(for: selectedEvent)!
                let selectedEvent = lsEvent[indexPath.row]
                eventDetailScene.eventDto = selectedEvent
            }
            break;
        default:
            break;
        }
    }
    
    // MARK: - notification handler
    func removeOldNotification(notificationId: String) {
        
        let center = UNUserNotificationCenter.current()
        center.removeDeliveredNotifications(withIdentifiers: [notificationId]);
    }
    
    func createNotification(event: EventDto) {
        
        print("createNotification event.id =", event.id, "\n\tevent.title =", event.title, "\n\tevent.start =", event.start)
        
        removeOldNotification(notificationId: event.id)
        
        let content = UNMutableNotificationContent()
        
        content.categoryIdentifier = "MCalendarNotification"
        content.title = event.title
        content.body = event.note!
        content.sound = UNNotificationSound.default()
        content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
        
        var timeToAct = DateComponents()
        timeToAct.year = Int(event.start.subString(startAt: 0, endAt: 4))
        timeToAct.month = Int(event.start.subString(startAt: 5, endAt: 7))
        timeToAct.day = Int(event.start.subString(startAt: 8, endAt: 10))
        timeToAct.hour = Int(event.start.subString(startAt: 12, endAt: 14))
        timeToAct.minute = Int(event.start.subString(startAt: 15, endAt: 17))
        if (event.start.subString(startAt: 18, endAt: 20) == "CH") {
            timeToAct.hour = timeToAct.hour! + 12
        }
        
        print("timeToAct = ", timeToAct)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: timeToAct, repeats: false)
        
        let request = UNNotificationRequest(identifier: event.id, content: content, trigger: trigger)
        
        let center = UNUserNotificationCenter.current()
        center.add(request)
    }
}

// MARK: - CVCalendar delegate
extension MainController: CVCalendarViewDelegate, CVCalendarMenuViewDelegate, CVCalendarViewAppearanceDelegate {

    
    /// Required method to implement!
    func presentationMode() -> CalendarMode {
        return .monthView
    }
    
    func shouldAutoSelectDayOnMonthChange() -> Bool {
        //print("shouldAutoSelectDayOnMonthChange = false")
        if selectedDay != nil {
            self.calendarView?.animator?.animateDeselectionOnDayView(selectedDay)
        }
        return false
    }
    
    func didShowNextMonthView(_ date: Date) {
        //animationFinished = false
        print("didShowNextMonthView date = ", date.toMediumDateTimeString()!)
    }
    
    func didShowPreviousMonthView(_ date: Date) {
        //animationFinished = false
        print("didShowPreviousMonthView date = ", date.toMediumDateTimeString()!)

    }
    
    /// Required method to implement!
    func firstWeekday() -> Weekday {
        return .monday
    }
    
    // optional: coloring day text (menu view)
    func dayOfWeekTextColor(by weekday: Weekday) -> UIColor {
        return (weekday == .sunday || weekday == .saturday) ? UIColor.gray : UIColor.black
    }
    
    func didSelectDayView(_ dayView: CVCalendarDayView, animationDidFinish: Bool) {
        print("didSelectDayView", dayView.date.convertedDate()!.toMediumDateTimeString()!)
        selectedDay = dayView
        loadTableView(day: selectedDay)
    }
    
    func dayLabelColor(by weekDay: Weekday, status: CVStatus, present: CVPresent) -> UIColor? {
        
        if status == .selected {
            return UIColor.white
        }
        if present == .present {
            return UIColor.red
        }
        if (weekDay == .sunday || weekDay == .saturday) {
            return UIColor.gray
        }
        return UIColor.black
    }
    
    func dayLabelBackgroundColor(by weekDay: Weekday, status: CVStatus, present: CVPresent) -> UIColor? {
        
        if present == .present {
            return UIColor.red
        }
        
        if status == .selected {
            if (weekDay == .sunday || weekDay == .saturday) {
                return UIColor.gray
            }
            return UIColor.black
        }
        
        return UIColor.white
    }
    
    func shouldSelectDayView(_ dayView: DayView) -> Bool {
        
        //print("shouldSelectDayView", self.calendarView?.coordinator?.selectedDayView?.date?.convertedDate()?.toMediumDateTimeString()!)
        self.calendarView?.coordinator?.selectedDayView = dayView
        return true
    }
    
    // optional: present when update date
    func presentedDateUpdated(_ date: CVDate) {
        
        print("presentedDateUpdated date = ", date.day, "/", date.month, "/", date.year)
        self.loadTableView(day: nil)
        
        if lbMonth.text != date.globalDescription && self.animationFinished {
            let updatedMonthLabel = UILabel()
            updatedMonthLabel.textColor = lbMonth.textColor
            updatedMonthLabel.font = lbMonth.font
            updatedMonthLabel.textAlignment = .center
            updatedMonthLabel.text = date.globalDescription
            updatedMonthLabel.sizeToFit()
            updatedMonthLabel.alpha = 0
            updatedMonthLabel.center = self.lbMonth.center
            
            let offset = CGFloat(48)
            updatedMonthLabel.transform = CGAffineTransform(translationX: 0, y: offset)
            updatedMonthLabel.transform = CGAffineTransform(scaleX: 1, y: 0.1)
            
            UIView.animate(withDuration: 0.35, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.animationFinished = false
                self.lbMonth.transform = CGAffineTransform(translationX: 0, y: -offset)
                self.lbMonth.transform = CGAffineTransform(scaleX: 1, y: 0.1)
                self.lbMonth.alpha = 0
                
                updatedMonthLabel.alpha = 1
                updatedMonthLabel.transform = CGAffineTransform.identity
                
            }) { _ in
                
                self.animationFinished = true
                self.lbMonth.frame = updatedMonthLabel.frame
                self.lbMonth.text = updatedMonthLabel.text
                self.lbMonth.transform = CGAffineTransform.identity
                self.lbMonth.alpha = 1
                updatedMonthLabel.removeFromSuperview()
            }
            
            self.view.insertSubview(updatedMonthLabel, aboveSubview: self.lbMonth)
        }
    }
}

// MARK: - table view delegate, table view data source
extension MainController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lsEvent.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventTableViewCell", for: indexPath) as! EventTableViewCell

        let event = lsEvent[indexPath.row]
        cell.txtTitle.text = event.title
        cell.txtTime.text = event.start + " - " + event.end
        
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
}

