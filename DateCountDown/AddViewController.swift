//
//  AddViewController.swift
//  DateCountDown
//
//  Created by sabrina on 2021/1/27.
//

import Cocoa

class AddViewController: NSViewController {
    @IBOutlet weak var txtName: NSTextField!
    @IBOutlet weak var dateField: NSDatePicker!
    @IBOutlet weak var dateView: NSDatePicker!
    @IBOutlet weak var btnDone: NSButton!
    
    //MARK: - Public priperty
    var repoImp:RepositoryImp?
    
    //MARK: - Private priperty
    private let TEXTFIELD_MAX_LIMIT = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        dateField.minDate = Date()
        dateField.target = self
        dateField.action = #selector(valueChanged(sender:))
        
        dateView.minDate = Date()
        dateView.target = self
        dateView.action = #selector(valueChanged(sender:))
        
        txtName.delegate = self
        btnDone.isEnabled = false
    }
    
    @objc func valueChanged(sender:NSDatePicker) {
        if sender == dateField {
            dateView.dateValue = sender.dateValue
        }else{
            dateField.dateValue = sender.dateValue
        }
    }
    
    @IBAction func tapCancelAction(_ sender: NSButton) {
        self.dismiss(nil)
    }
    
    @IBAction func tapDoneAction(_ sender: NSButton) {
        saveEventToDB()
        registerEventToNotifications()
        refreshStatusBarItem()
        self.dismiss(nil)
    }
    
    private func refreshStatusBarItem() {
        guard let appDelegate = NSApplication.shared.delegate as? AppDelegate,
              let itemManager = appDelegate.statusItemManager else {
            return
        }
        itemManager.reload()
    }
    
    private func saveEventToDB() {
        let name = txtName.stringValue
        let df = DateFormatter()
        df.setupLocalAndFormat()
        let date = df.string(from: dateField.dateValue)
        let newCountdown = CountDown(name: name, date: date)
        repoImp?.save(by: newCountdown)
    }
    
    private func registerEventToNotifications() {
        let name = txtName.stringValue
        let df = DateFormatter()
        df.dateFormat = "yyyyMMddHHmmss"
        let registeriIdentifier = df.string(from: dateField.dateValue)
        let localNotify = LocalNotifications()
        localNotify.register(identifier: registeriIdentifier, date: dateField.dateValue, event: name) { (msg) in
            print(msg)
        } failure: { (err) in
            print(err.localizedDescription)
        }

    }
}

extension AddViewController : NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        let text = obj.object as! NSTextField
        let stringValue = text.stringValue
        btnDone.isEnabled = stringValue.count > 0
        if stringValue.count > TEXTFIELD_MAX_LIMIT {
            let index = stringValue.index(stringValue.startIndex, offsetBy: TEXTFIELD_MAX_LIMIT)
            text.stringValue = String(stringValue[..<index])
        }
    }
}
