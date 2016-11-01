//
//  AboutController.swift
//  MCalendar
//
//  Created by Luvina on 9/30/16.
//  Copyright © 2016 Luvina. All rights reserved.
//

import UIKit
import MessageUI

class AboutController : UIViewController, MFMailComposeViewControllerDelegate {
    
    // MARK: - properties
    @IBOutlet weak var txtAbout: UITextView!
    var emailAddress: String?
    
    // MARK: - override
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtAbout.layer.borderColor = UIColor.init(netHex: 0xd1d1d1).cgColor
        txtAbout.layer.borderWidth = 1.0
        txtAbout.layer.cornerRadius = 5
        txtAbout.clipsToBounds = true
        
        txtAbout.backgroundColor = UIColor.init(netHex: 0xfafafa)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // scroll text view to top
    override func viewDidLayoutSubviews() {
        self.txtAbout.setContentOffset(CGPoint.zero, animated: true)
    }
    
    // MARK: - btn export click
    @IBAction func btnExportClick(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Export data", message: "Enter your email", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: { (txtEmail) in
            txtEmail.placeholder = "example@gmail.com"
            })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {(_) in
            
            let email = alert.textFields![0]
            
            self.emailAddress = email.text
            
            print("Alert email = \(self.emailAddress)")
            
            if self.emailAddress != nil && self.validateEmail(email: self.emailAddress) && MFMailComposeViewController.canSendMail() {
                
                let mailComposeViewController = self.configuredMailComposeViewController()
                self.present(mailComposeViewController, animated: true, completion: nil)
            } else {
                
                self.alertSendEmailError()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: {(_) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
        
        for txt in alert.textFields! {
            txt.borderStyle = UITextBorderStyle.roundedRect
            if let container = txt.superview, let effectView = container.superview?.subviews.first, effectView is UIVisualEffectView {
                container.backgroundColor = UIColor.clear
                effectView.removeFromSuperview()
            }
        }
    }
    
    // MARK: - action send mail
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients([self.emailAddress!])
        mailComposerVC.setSubject("Email export data from MCalendar.")
        mailComposerVC.setMessageBody("Hi \(self.emailAddress!).<br/>This is your data csv. Have a good time.<br/>Regards", isHTML: true)
        ///////////////////// add csv file here
        if let csvContent = self.generateCsvData() {
            mailComposerVC.addAttachmentData(csvContent, mimeType: "text/csv", fileName: "MCalendar_\(Date().fileNameExtenstionTimeStamp()!).csv")
        }
        return mailComposerVC
    }
    
    func validateEmail(email: String?) -> Bool {
        print("validateEmail: \(email!)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email!)
    }
    
    func generateCsvData() -> Data? {
        
        let service = EventService()
        let lsEvent = service.getListEvent()
        
        guard lsEvent.count > 0 else {
            return nil
        }
        
        let content = NSMutableString()
        content.append("Event title, Start, End, Note\n")
        
        for eventDto in lsEvent {
            var note = eventDto.note!
            print("\"\(eventDto.title)\"")
            print("\"\(note)\"")
            note = "\"" + note.replacingOccurrences(of: "\"", with: "\"\"") + "\""
            content.append("\"\(eventDto.title.replacingOccurrences(of: "\"", with: "\"\""))\",\(eventDto.start),\(eventDto.end),\(note) \n")
        }
        
        return content.data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false)
    }
    
    func alertSendEmailError() {
        let alert = UIAlertController(title: "Error!", message: "Could not send email. Please check e-mail configuration and try again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {(_) in
            self.emailAddress = nil
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - MFMailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
