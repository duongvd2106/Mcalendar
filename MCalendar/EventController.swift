//
//  File.swift
//  MCalendar
//
//  Created by Luvina on 9/28/16.
//  Copyright © 2016 Luvina. All rights reserved.
//

import UIKit
import CoreData
import Darwin
import GoogleMaps
import AVFoundation
import Photos

class EventController: UIViewController, UINavigationControllerDelegate {
    
    // MARK: - properties
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtStartTime: UITextField!
    @IBOutlet weak var txtEndtime: UITextField!
    @IBOutlet weak var switchNotification: UISwitch!
    @IBOutlet weak var txtNote: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var btnCancel: UIBarButtonItem!
    @IBOutlet weak var btnSave: UIBarButtonItem!
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var ivPhoto: UIImageView!
    @IBOutlet weak var mapView: GMSMapView!
    
    var popStartDatePicker : PopDatePicker?
    var popEndDatePicker : PopDatePicker?
    
    var keyboardHeight: CGFloat?
   
    var eventDto: EventDto?
    var isImgPicked : Bool = false
    
    var locationMng = CLLocationManager()
    var didFindCurrentLocation = false

    // MARK: - override controller
    override func viewDidLoad() {
        super.viewDidLoad()
        // Custom Note UI
        txtNote.layer.borderColor = UIColor.init(netHex: 0xd1d1d1).cgColor
        txtNote.layer.borderWidth = 1.0
        txtNote.layer.cornerRadius = 5
        //txtNote.clipsToBounds = true
        
        // custom image view
        ivPhoto.layer.borderColor = UIColor.init(netHex: 0xd1d1d1).cgColor
        ivPhoto.layer.borderWidth = 1.0
        ivPhoto.backgroundColor = UIColor.init(netHex: 0xfafafa)
        ivPhoto.layer.cornerRadius = 5
        //ivPhoto.clipsToBounds = true
        
        // custom map view
        mapView.layer.borderColor = UIColor.init(netHex: 0xd1d1d1).cgColor
        mapView.layer.borderWidth = 1.0
        mapView.backgroundColor = UIColor.init(netHex: 0xfafafa)
        mapView.layer.cornerRadius = 5
        
        // Setting up start/end picker
        popStartDatePicker = PopDatePicker(forTextField: txtStartTime)
        popEndDatePicker = PopDatePicker(forTextField: txtEndtime)
        txtStartTime.delegate = self
        txtEndtime.delegate = self
        
        // Setting keyboard handler txtTitle, txtNote
        txtTitle.delegate = self
        txtNote.delegate = self
       
        if let eventDto = eventDto {
             // load edit value
            
            txtTitle.text = eventDto.title
            txtStartTime.text = eventDto.start
            txtEndtime.text = eventDto.end
            switchNotification.setOn(eventDto.alert, animated: false)
            txtNote.text = eventDto.note
            
            // load image to imageview
            
            // from file path
            /*if let path = eventDto.img, path.characters.count > 0 {
                
                let fullPath = getDocumentURL().appendingPathComponent(path).path
                if let image = loadImageFromPath(path: fullPath) {*/
            
            // from bin data
            if let binData = eventDto.imgBin {
            
                if let image = loadImageFromBinData(binData: binData) {//
                    
                    ivPhoto.contentMode = .scaleAspectFit
                    ivPhoto.image = image
                    isImgPicked = true
                } else {
                    
                    ivPhoto.image = #imageLiteral(resourceName: "defaultPhotoLoadFailed")
                    isImgPicked = false
                    eventDto.img = ""
                    eventDto.imgBin = nil
                }
            } else {
                
                ivPhoto.image = #imageLiteral(resourceName: "defaultNoPhoto")
                isImgPicked = false
            }
            
            // check if display for add or edit or detail
            if eventDto.start.longStringtoDate()! <= Date() {
                
                navBar.title = "Event detail"
                btnCancel.title = "Done"
                navBar.rightBarButtonItems = []
                
                txtTitle.isEnabled = false
                txtStartTime.isEnabled = false
                txtEndtime.isEnabled = false
                switchNotification.isEnabled = false
                
                txtNote.isEditable = false
                txtNote.backgroundColor = UIColor.init(netHex: 0xfafafa)
                
                ivPhoto.isUserInteractionEnabled = false
            } else {
                
                navBar.title = "Edit event"
                btnSave.title = "Edit"
                
                createNotePlaceHolder()
            }
        } else {
            // load default value
            
            let now = Date()
            let defaultStartTime = now.addingTimeInterval(1.0 * 60.0)
            let defaultEndTime = now.addingTimeInterval(3.0 * 60.0)
            
            txtStartTime.text = defaultStartTime.toLongDateTimeString()! as String
            txtEndtime.text = defaultEndTime.toLongDateTimeString()! as String
            
            navBar.title = "New event"
            btnSave.title = "Add"
            
            createNotePlaceHolder()
        }
        

        
        NotificationCenter.default.addObserver(self, selector: #selector(getKeyboardHeight), name: .UIKeyboardWillShow, object: nil)
        
        locationMng.delegate = self
        locationMng.requestWhenInUseAuthorization()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    // scroll text view to top
    override func viewDidLayoutSubviews() {
        self.txtNote.setContentOffset(CGPoint.zero, animated: true)
    }
    
    override func loadView() {
        super.loadView()
        mapLoader()
    }
    
    func mapLoader() {
        /*if let eventDto = eventDto {
            
        } else {
            //self.addMarker(location: (mapView.myLocation?.coordinate)!, title: "Current location", snippet: "You are here")
        }*/
    }
    
    func addMarker(location: CLLocationCoordinate2D, title: String, snippet: String) {
        let marker = GMSMarker()
        marker.position = location
        marker.title = title
        marker.snippet = snippet
        marker.map = mapView
    }
    

    // MARK: - button action
    // implement image view click
    @IBAction func selectImg(_ sender: UITapGestureRecognizer) {
        resignTextView()
        
        let alert = UIAlertController(title: "Choose to take photo", message: "Do you want to take a photo from the photo library or the camera?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {(_) in
            
            alert.dismiss(animated: true, completion: nil)
            
            if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == AVAuthorizationStatus.authorized {
                self.getImg(from: "camera")
                
            } else {
                self.showAlert("Error", "Application can't access Camera\n Please check your configuration.")
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Photo library", style: .default, handler: {(_) in
            
            alert.dismiss(animated: true, completion: nil)
            
            if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
                self.getImg(from: "photo library")
                
            } else {
                self.showAlert("Error", "Application can't access Photo library\n Please check your configuration.")
            }
        }))

        self.present(alert, animated: true, completion: {
            alert.view.superview?.isUserInteractionEnabled = true
            alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissAlert)))
        })
    }
    
    func dismissAlert()
    {
        print("dismissAlert")
        self.dismiss(animated: true, completion: nil)
    }
    
    func getImg(from: String) {
        let imagePickerController = UIImagePickerController()
        
        if (from == "photo library") {
            
            imagePickerController.sourceType = .photoLibrary
        } else {
            
            imagePickerController.sourceType = .camera
            imagePickerController.cameraCaptureMode = .photo
        }
        
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    // MARK: button cancel
    @IBAction func btnCancelClick(_ sender: UIBarButtonItem) {
        
        let isPresentingInAddEventMode = presentingViewController is UINavigationController
        
        if isPresentingInAddEventMode {
            self.dismiss(animated: true, completion: nil)
        } else {
            navigationController!.popViewController(animated: true)
        }

        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: button add/edit
    @IBAction func btnAddClick(_ sender: UIBarButtonItem) {
        
        if btnSave.title == "Done" {
            self.resignTextView()
            return
        }
        
        if !validate() {
            return
        }
        checkDuplicateSchedule()
    }
    
    func validate() -> Bool {
        
        if txtTitle.text! == "" || txtTitle.text!.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            self.showAlert("Error", "Cannot create no title event")
            return false
        }
        
        if txtStartTime.text! == "" {
            self.showAlert("Error", "Cannot create no start time event")
            return false
        }
        
        if txtEndtime.text! == "" {
            self.showAlert("Error", "Cannot create no end time event")
            return false
        }
        
        var now = Date().toLongDateTimeString()! as String
        now = now.subString(startAt: 0, endAt: now.indexOf(char: ":"))
        print("validate time =",now)
        
        if txtStartTime.text! < now {
            self.showAlert("Error", "Start time must after from now")
            return false
        }
        
        if !(self.compare2StrDate(str1: txtStartTime.text!, str2: txtEndtime.text!)) {
            self.showAlert("Error", "End time before start time")
            return false
        }
        
        return true
    }
    
    func checkDuplicateSchedule() {
        
        let service = EventService()
        let queryDay = txtStartTime.text!.subString(startAt: 0, endAt: txtStartTime.text!.indexOf(char: " "))
        print("checkDuplicateSchedule queryDay = '\(queryDay)'")
        
        let lsEventToCheck = service.getListEventByDate(queryDay: queryDay)
        
        let startTime = txtStartTime.text!
        let endTime = txtEndtime.text!
        
        var isDuplicated: Bool = false
        
        if lsEventToCheck.count > 0 {

            for event in lsEventToCheck {
                
                if ((!self.compare2StrDate(str1: event.start, str2: startTime)) && (!self.compare2StrDate(str1: endTime, str2: event.start)))
                    || ((!self.compare2StrDate(str1: startTime, str2: event.start)) && (!self.compare2StrDate(str1: event.end, str2: startTime))){
                    isDuplicated = true
                    break
                }
            }
            print("checkDuplicateSchedule queryDay isDuplicated = '\(isDuplicated)'")
            if isDuplicated {
                
                let confirm = UIAlertController(title: "Duplicate event", message: "You are having duplicate schedule.", preferredStyle: .alert)
                
                confirm.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (action: UIAlertAction!) in self.onConfirmDone()}))
                confirm.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                present(confirm, animated: true, completion: nil)
            } else {
                self.onConfirmDone()
            }
        } else {
            self.onConfirmDone()
        }
    }
    
    func onConfirmDone() {
        print("onConfirmDone")
        self.performSegue(withIdentifier: "unwindToMain", sender: self)
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        print("shouldPerformSegue identifier = ",identifier)
        return true
    }
    
    // prepare for unwind segue, create object for send
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        print("prepare for segue: ",segue.identifier!)
        let eventId = eventDto?.id ?? ""
        let title = txtTitle.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let start = txtStartTime.text!
        let end = txtEndtime.text!
        let alert = switchNotification.isOn
        
        var note = ""
        if txtNote.textColor == UIColor.black {
            note = txtNote.text!
        }
        
        var imgUrl: String = ""
        var imgBin: Data? = nil
        
        if isImgPicked {
            
            print("////////Start save", Date().toMillisecondString()!) // check performance
            imgUrl = title + "_" + (Date().fileNameExtenstionTimeStamp()! as String) + ".png"
            
            /*// save img to file in document directory
             let result = saveImageToFile(image: ivPhoto.image!, fileName: imgUrl)
             if !result {
             print ("prepare dto, compress img failed")
             imgUrl = ""
             }*/
            
            // save img to binary data
            let result = saveImageToBinaryData(image: ivPhoto.image!, binData: &imgBin)
            if !result {
                print ("prepare dto, compress img failed")
                imgBin = nil
            }
        }
        
        eventDto = EventDto(id: eventId, title: title, start: start, end: end, alert: alert, note: note, img: imgUrl, imgBin: imgBin)
    }

}

extension EventController : UITextFieldDelegate, UITextViewDelegate {
    
    func resignTextView() {
        txtTitle.resignFirstResponder()
        txtStartTime.resignFirstResponder()
        txtEndtime.resignFirstResponder()
        txtNote.resignFirstResponder()
    }
    
    // MARK: - text field delegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if (textField === txtStartTime || textField === txtEndtime) {
            resignTextView()
            let initDate : Date? = textField.text!.longStringtoDate()
            
            let dataChangedCallback : PopDatePicker.PopDatePickerCallback = { (newDate : Date, forTextField : UITextField) -> () in
                
                // here we don't use self (no retain cycle)
                forTextField.text = (newDate.toLongDateTimeString() ?? "?") as String
            }
            if (textField === txtStartTime) {
                popStartDatePicker!.pick(self, initDate: initDate, dataChanged: dataChangedCallback)
            } else {
                popEndDatePicker!.pick(self, initDate: initDate, dataChanged: dataChangedCallback)
            }
            return false
        }
        else {
            return true
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == txtTitle && string == "\n" {
            textField.endEditing(true)
            return false
        } else {
            return true
        }
    }
    
    // MARK: - text view delegate 
    
    // for click done close keyboard, dont need anymore
    /*func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == txtNote && text == "\n" {
            textView.endEditing(true)
            return false
        } else {
            return true
        }
    }*/
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        checkPlaceHolder()
        btnSave.title = "Done"
        self.animateTextView(textView, isMoveUp: true)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        checkPlaceHolder()
        btnSave.title = navBar.title == "New event" ? "Add" : "Edit"
        self.animateTextView(textView, isMoveUp: false)
    }
    
    func animateTextView(_ view: UIView, isMoveUp: Bool) {
        
        let moveDistance = calculateDistance(view: view)
        
        let moveDuration: Double = 0.3
        
        let move: CGFloat = isMoveUp ? moveDistance : -moveDistance
        
        UIView.beginAnimations("txtNote", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: move)
        UIView.commitAnimations()
    }
    
    func calculateDistance(view: UIView) -> CGFloat {
        
        if keyboardHeight == nil {
            return 0
        }
        
        var distance: CGFloat
        let spaceBetweenViewAndKeyBoard: CGFloat = 6
        let point: CGPoint = self.view.convert(view.center, to: self.view)
        let viewHeight: CGFloat = view.bounds.height
        let screenHeigth = UIScreen.main.bounds.size.height
        
        let viewEndY = point.y + viewHeight / 2
        let keyboardStartY = screenHeigth - keyboardHeight!
        
        //print("view.frame.origin.y = ", point.y)
        //print("view.frame.origin.y + view.bounds.height = ", viewEndY)
        //print("UIScreen.bounds.size.height - keyboardHeight = ", keyboardStartY)
        
        distance = viewEndY + spaceBetweenViewAndKeyBoard - keyboardStartY
        
        if (distance < spaceBetweenViewAndKeyBoard) {
            
            distance = spaceBetweenViewAndKeyBoard
        }
        //print("distance = ", distance)
        return -distance
    }
    
    func getKeyboardHeight(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.keyboardHeight = keyboardSize.height
        }
    }
    
    // txt Note place holder
    func createNotePlaceHolder() {
        if txtNote.text == "" {
            txtNote.text = "Event note..."
            txtNote.textColor = UIColor(netHex: 0xC7C7CD)
        }
    }
    
    func checkPlaceHolder() {
        if txtNote.text == "Event note..." && txtNote.textColor != UIColor.black {
            txtNote.text = ""
            txtNote.textColor = UIColor.black
        } else {
            createNotePlaceHolder()
        }
    }
}

extension EventController: UIImagePickerControllerDelegate {
    
    // MARK: - UI Image Picker Delegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        ivPhoto.contentMode = .scaleAspectFit
        ivPhoto.image = selectedImage
        isImgPicked = true
        dismiss(animated: true, completion: nil)
    }
}

extension EventController: CLLocationManagerDelegate {
    // MARK: - CL Location Manager Delegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            
            locationMng.startUpdatingLocation()
            
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            self.addMarker(location: location.coordinate, title: "marker title", snippet: "marker snipet")
            locationMng.stopUpdatingLocation()
        }
    }
}
