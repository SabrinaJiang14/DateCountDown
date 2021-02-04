//
//  ViewController.swift
//  DateCountDown
//
//  Created by sabrina on 2021/1/26.
//

import Cocoa
import Combine

class ViewController: NSViewController {
    
    //MARK: - IBOutlet
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var imgBack: NSImageView!
    @IBOutlet var setting: NSMenu!
    
    //MARK: - Public priperty
    var repoImp:RepositoryImp!
    
    //MARK: - Private priperty
    private var cancellables:Set<AnyCancellable> = Set<AnyCancellable>()
    private var dataSources:[CountDown] = [] {
        didSet{ tableView.reloadData() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        repoImp.$dataSource.sink { [weak self] (result) in
            self?.dataSources = result.filter({ $0.isInvalid == false })
        }.store(in: &cancellables)
        
        tableView.backgroundColor = .clear
        tableView.enclosingScrollView?.drawsBackground = false
        tableView.intercellSpacing = NSSize(width: 0, height: 1)
        tableView.gridColor = .clear
        tableView.gridStyleMask = .solidHorizontalGridLineMask
        
        // Do any additional setup after loading the view.
        
        var image = NSImage(named: "Sky")
        image = image?.resizeImage(NSSize(width: self.view.bounds.width, height: self.view.bounds.height))
        imgBack.image = image
        imgBack.alphaValue = 0.5
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window?.makeKeyAndOrderFront(self.view)
        NSApplication.shared.activate(ignoringOtherApps: true)
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func tapCreateAction() {
        guard let appDelegate = NSApplication.shared.delegate as? AppDelegate,
              let itemManager = appDelegate.statusItemManager else {
            return
        }
        itemManager.showCreateVC()
    }
    
    @IBAction func tapSettingAction(_ sender: NSButton) {
        let newFrame = sender.convert(sender.frame, from: sender)
        if setting != nil {
            self.setting.popUp(positioning: nil, at: NSPoint(x: newFrame.origin.x, y: newFrame.origin.y), in: sender.superview)
        }
    }
    
    @IBAction func tapSettingItemAction(_ sender: NSMenuItem) {
        if sender.tag == 1 {
            tapCreateAction()
        }else{
            NSApplication.shared.terminate(self)
        }
    }
    
}

extension ViewController : NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return dataSources.count
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return row == 0 ? 90 : 40
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let df = DateFormatter()
        df.setupLocalAndFormat()
        let data = dataSources[row]
        let date = df.date(from: data.date) ?? Date()
        let diffComponents = Calendar.current.dateComponents([.day, .hour], from: Date(), to: date)
        let day:Double = Double(diffComponents.day ?? 0)
        var diffTimeInterval:Double = 0.0
        if day <= 0.0 {
            diffTimeInterval = Double(diffComponents.hour ?? 0) / 24.0
        }else{
            diffTimeInterval = Double(day)
        }
        if row == 0 {
            let firstCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "FirstCustomCell"), owner: self) as! FirstCustomCell
            firstCell.txtName.stringValue = data.name
            firstCell.txtTime.stringValue = data.date
            firstCell.txtCountdown.stringValue = String(format: "%.1f", diffTimeInterval)
            return firstCell
        }else{
            let smallCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "SmallCustomCell"), owner: self) as! SmallCustomCell
            smallCell.txtName.stringValue = data.name
            smallCell.txtTime.stringValue = data.date
            smallCell.txtCountdown.stringValue = String(format: "%.0f", diffTimeInterval)
            return smallCell
        }
    }
}
