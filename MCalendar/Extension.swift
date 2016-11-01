//
//  Extension.swift
//  MCalendar
//
//  Created by Luvina on 9/28/16.
//  Copyright © 2016 Luvina. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
    // for debug Auto layout
    override open var description: String {
        let id = identifier ?? ""
        return "id: \(id), constant: \(constant)" //you may print whatever you want here
    }
}

extension Date {
    
    // MARK: - date to string
    func toMediumDateTimeString() -> NSString? {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium;
        formatter.timeStyle = .none;
        return formatter.string(from: self) as NSString?
    }
    
    func toLongDateTimeString() -> NSString? {
        return formatDateToString(format: "yyyy/MM/dd  hh:mm a")
    }
    
    func fileNameExtenstionTimeStamp() -> NSString? {
        return formatDateToString(format: "yyyy_MM_dd_hh_mm_ss")
    }
    
    func toMillisecondString() -> NSString? {
        return formatDateToString(format: "yyyy_MM_dd_hh_mm_ss.SSS")
    }
    
    func formatDateToString(format: String) -> NSString? {
        
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self) as NSString?
    }
    
    func compareDateOnly(date: Date) -> Bool {
        let calendar = Calendar.current
        let selfComponents = calendar.dateComponents([.year, .month, .day], from: self)
        let compareComponents = calendar.dateComponents([.year, .month, .day], from: date)
        return selfComponents.year! == compareComponents.year! && selfComponents.month! == compareComponents.month! && selfComponents.day! == compareComponents.day!
    }
}

extension String {
    
    // MARK: - string to date
    func mediumStringtoDate() -> Date? {
        return formatStringToDate(format: "d MMMM, yyyy")
    }
    
    func longStringtoDate() -> Date? {
        return formatStringToDate(format: "yyyy/MM/dd  hh:mm a")
    }
    
    func formatStringToDate(format: String) -> Date? {
        
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: self)
    }
    
    // MARK: - customize
    func indexOf(char c: Character) -> Int {
        if let index = self.characters.index(of: c) {
            let pos = self.characters.distance(from: self.startIndex, to: index)
            return pos
        } else {
            print("\\\\String.indexOf:  error, can't find char in string")
            return -1
        }
    }
    
    func subString(startAt start: Int, endAt end: Int) -> String {
        if (start < 0) || (start >= end) || (end > self.characters.count) {
            print("\\\\String.subString:  error, start = \(start) && end = \(end) is invalid")
            return ""
        }
        
        let start = self.index(self.startIndex, offsetBy: start)
        let end = self.index(self.startIndex, offsetBy: end)
        let range = start..<end

        return self.substring(with: range)
    }
}

extension UIColor {
    // MARK: - UIColor from hex
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

extension UIViewController {
    
    // MARK: - controller utility
    // return true if date 1 < date 2
    func compare2StrDate(str1: String, str2: String) -> Bool {
        
        let date1 = str1.longStringtoDate()
        let date2 = str2.longStringtoDate()
        //print ("compare2StrDate: date1 =", date1!, "; date2 =", date2!, "result = \(date1! >= date2!)")
        return !(date1! >= date2!)
    }
    
    func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - file manager
    func getDocumentURL() -> URL {
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentURL
    }
    
    func getFullDocumentPath(fileName: String) -> String {
        let fileURL = self.getDocumentURL().appendingPathComponent(fileName)
        return fileURL.absoluteString
    }
    
    func listDocumentDirFile() {
        let documentsUrl =  getDocumentURL()
        
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
            
            let pngFiles = directoryContents.filter{ $0.pathExtension == "png" }
            print("png urls:", pngFiles)
            let pngFileNames = pngFiles.map{ $0.deletingPathExtension().lastPathComponent }
            print("png file:", pngFileNames, ".png")
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - convert UIImage to other data type
    func saveImageToFile(image: UIImage, fileName: String) -> Bool {
        print("Saving image...")
        var result: Bool = false
        if let data = UIImagePNGRepresentation(image) {
            let filename = self.getDocumentURL().appendingPathComponent(fileName)
            do {
                try data.write(to: filename)
                result = true
            } catch let error as NSError {
                print("ERROR = \(error.localizedDescription)")
                result = false
            }
        }
        listDocumentDirFile()
        return result
    }
    
    func saveImageToBinaryData(image: UIImage, binData: inout Data?) -> Bool {
        print("Saving image...")
        binData = UIImageJPEGRepresentation(image, 1.0)
        return binData != nil
    }
    
    func saveImageToBase64String(image: UIImage, strEncode: inout String?) -> Bool {
        let imgData = UIImageJPEGRepresentation(image, 1.0)
        strEncode = imgData?.base64EncodedString(options: .init(rawValue: 0))
        return strEncode != nil
    }
    
    // MARK: - load other data type back to UIImage
    func loadImageFromPath(path: String) -> UIImage? {
        let image = UIImage(contentsOfFile: path)
        if image == nil {
            print("Missing image at path: ", path)
        } else {
            print("Loading image from path: ", path)
        }
        return image
    }
    
    func loadImageFromBinData(binData: Data) -> UIImage? {
        let image = UIImage(data: binData)
        if image == nil {
            print("loadImageFromBinData Data error!")
        } else {
            print("Loaded image from binData")
        }
        return image
    }
    
    func loadImageFromBase64String(strEncode: String) -> UIImage? {
        let imageData = Data(base64Encoded: strEncode, options: .init(rawValue: 0))
        let image = UIImage(data: imageData!, scale: 1.0)
        if image == nil {
            print("loadImageFromBase64String Data error!")
        } else {
            print("Loaded image from Base64String, image.size = ", image?.size)
        }
        return image
    }
}

