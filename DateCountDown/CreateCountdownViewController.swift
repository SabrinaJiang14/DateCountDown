//
//  CreateCountdownViewController.swift
//  DateCountDown
//
//  Created by sabrina on 2021/1/27.
//

import Cocoa
import Combine

class CreateCountdownViewController: NSViewController {

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var btnRemove: NSButton!
    @IBOutlet weak var btnIsShowValid: NSButton!
    
    //MARK: - Public priperty
    var repoImp:RepositoryImp?
    
    //MARK: - Private priperty
    private var dataSources:[CountDown] = [] {
        didSet { tableView.reloadData() }
    }
    private var originDataSource:[CountDown] = []
    
    private var cancellables:Set<AnyCancellable> = Set<AnyCancellable>()
    private var isInvalid:Bool = false {
        didSet { reload(datas: originDataSource) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        repoImp?.$dataSource.sink { [weak self] (result) in
            self?.originDataSource = result
            self?.reload(datas: result)
        }.store(in: &cancellables)
        
        btnRemove.isEnabled = false
    }
    
    private func reload(datas:[CountDown]) {
        if !isInvalid {
            dataSources = datas.filter({ $0.isInvalid == false })
        }else{
            dataSources = datas
        }
    }
    
    private func refreshStatusBarItem() {
        guard let appDelegate = NSApplication.shared.delegate as? AppDelegate,
              let itemManager = appDelegate.statusItemManager else {
            return
        }
        itemManager.reload()
    }
    
    @IBAction func tapAddAction(_ sender: NSButton) {
        guard let appDelegate = NSApplication.shared.delegate as? AppDelegate,
              let itemManager = appDelegate.statusItemManager else {
            return
        }
        itemManager.showAddVC(sender: sender)
    }
    
    @IBAction func tapRemoveAction(_ sender: NSButton) {
        if tableView.selectedRow != -1 {
            let index = tableView.selectedRow
            repoImp?.remove(by: dataSources[index])
            sender.isEnabled = false
            refreshStatusBarItem()
        }
    }
    
    @IBAction func columnDidSelected(_ sender: NSTableView) {
        let index = sender.selectedRow
        btnRemove.isEnabled = index != -1
    }
    
    
    @IBAction func tapEventIsInvaild(_ sender: NSButton) {
        let flag = sender.state == .on
        isInvalid = flag
    }
}

extension CreateCountdownViewController: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return dataSources.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let column = tableColumn, let view = tableView.makeView(withIdentifier: column.identifier, owner: self) as? NSTableCellView else {
            return nil
        }
        
        if column == tableView.tableColumns[0] {
            view.textField?.stringValue = dataSources[row].name
        }else{
            view.textField?.stringValue = dataSources[row].date
        }
        
        return view
    }
}
