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
    private var firstCancellable:AnyCancellable?
    private let timeInterval:TimeInterval = 60*60
    private var firstLaunch:Bool = true
    
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
        repoImp.$firstItem.sink { [weak self] (first) in
            guard let self = self else { return }
            self.firstItem = first
            self.tick()
            if self.firstLaunch {
                self.initFirstTime()
                self.firstLaunch = false
            }
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
    // correction the loop time
    private func initFirstTime() {
        if let list = firstItem {
            let df = DateFormatter()
            df.setupLocalAndFormat()
            let lhs = df.date(from: list.date)
            let diffComponents = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: Date(), to: lhs!)
            let minute = diffComponents.minute ?? 0
            let second = diffComponents.second ?? 0
//            let minute = 0
//            let second = 7
            if (minute != 0 || second != 0) {
                let correctionTime = (minute * 60) + second + 1
                Print.info(correctionTime)
                firstCancellable = Timer.publish(every: TimeInterval(correctionTime), on: .main, in: .common)
                    .autoconnect()
                    .sink { [weak self] (time) in
                        Print.info(time)
                        self?.reload()
                        self?.initRegularTime()
                        self?.firstCancellable = nil
                }
            }else{
                initRegularTime()
            }
        }
    }
    
    // every 1 hour run ones
    private func initRegularTime() {
        Timer.publish(every: timeInterval, on: .main, in: .common).autoconnect().sink { [weak self] (time) in
            Print.info(time)
            self?.reload()
        }.store(in: &cancellables)
    }
    
    private func tick() {
        if let list = firstItem {
            let df = DateFormatter()
            df.setupLocalAndFormat()
            let lhs = df.date(from: list.date)
            let diffComponents = Calendar.current.dateComponents([.day, .hour], from: Date(), to: lhs!)
            var title = ""
            let day = diffComponents.day ?? 0
            if day <= 0 {
                title = String(format: "離 %@ 還有 %d 小時", list.name, abs(diffComponents.hour ?? 0))
            }else{
                title = String(format: "離 %@ 還有 %d 天", list.name, day)
            }
            
            statusItem?.button?.title = title
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
