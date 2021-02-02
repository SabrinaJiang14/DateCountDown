//
//  StatusItemManager.swift
//  DateCountDown
//
//  Created by sabrina on 2021/1/26.
//

import Cocoa
import Combine

class StatusItemManager : NSObject {
    var statusItem : NSStatusItem?
    var popover : NSPopover?
    var converterVC : ViewController?
    var windowController: NSWindowController!
    let repoImp = RepositoryImp()
    
    private var firstItem:CountDown?
    private var cancellables:Set<AnyCancellable> = Set<AnyCancellable>()
    private let timeInterval:TimeInterval = 60*60
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initilized()
    }
    
    override init() {
        super.init()
    }
    
    func initilized() {
        initStatusItem()
        initPopover()
        initTime()
        repoImp.$firstItem.sink { [weak self] (first) in
            self?.firstItem = first
            self?.tick()
        }.store(in: &cancellables)
    }
    
    @objc func reload() {
        repoImp.reloadData()
    }
    
    @objc func showConverterVC() {
        guard let pop = popover, let button = statusItem?.button else { return }
        if converterVC == nil {
            let storyboard = NSStoryboard(name: "Main", bundle: nil)
            guard let vc = storyboard.instantiateController(withIdentifier: .init(stringLiteral: "converterID")) as? ViewController else {
                return
            }
            converterVC = vc
            converterVC?.repoImp = repoImp
        }
        
        pop.contentViewController = converterVC
        pop.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        
    }
    
    func showCreateVC() {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let createVC = storyboard.instantiateController(withIdentifier: "CreateCountdownViewController") as! CreateCountdownViewController
        createVC.repoImp = repoImp
        windowController = storyboard.instantiateController(withIdentifier: "Settings") as? NSWindowController
        windowController.window?.contentViewController = createVC
        windowController.showWindow(createVC)
    }
    
    func showAddVC(sender:NSButton) {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let add = storyboard.instantiateController(withIdentifier: .init(stringLiteral: "AddViewController")) as! AddViewController
        add.repoImp = repoImp
        windowController.contentViewController?.presentAsSheet(add)
    }
}

private extension StatusItemManager {
    private func initTime() {
        Timer.publish(every: timeInterval, on: .main, in: .common).autoconnect().sink { [weak self] (time) in
            self?.reload()
        }.store(in: &cancellables)
    }
    
    private func tick() {
        if let list = firstItem {
            let df = DateFormatter()
            df.setupLocalAndFormat()
            let lhs = df.date(from: list.date)
            let diffComponents = Calendar.current.dateComponents([.day], from: lhs!, to: Date())
            statusItem?.button?.title = String(format: "離 %@ 還有 %d 天", list.name, abs(diffComponents.day ?? 0))
            statusItem?.button?.image = nil
        }else{
            statusItem?.button?.image = NSImage(named: "date")
            statusItem?.button?.title = ""
        }
        
    }
    
    private func initStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        let itemImgae = NSImage(named: "date")
        itemImgae?.isTemplate = true
        statusItem?.button?.image = itemImgae
        
        statusItem?.button?.target = self
        statusItem?.button?.action = #selector(showConverterVC)
    }
    
    private func initPopover() {
        popover = NSPopover()
        popover?.behavior = .transient
    }
}
