//
//  RepositoryImp.swift
//  DateCountDown
//
//  Created by sabrina on 2021/1/29.
//

import Cocoa
import Combine

class RepositoryImp : NSObject {
    
    @Published var dataSource:[CountDown] = []
    @Published var firstItem:CountDown?
    
    override init() {
        super.init()
        self.reloadData()
    }
    
    func save(by item:CountDown) {
        var list = UserDefaults.countdownLists
        list.append(item)
        refreshList(list: list)
    }
    
    func remove(by item:CountDown) {
        var list = UserDefaults.countdownLists
        if let index = list.firstIndex(where: { $0.name == item.name }) {
            list.remove(at: index)
            refreshList(list: list)
        }
    }
    
    func clearAllData() {
        UserDefaults.countdownLists = []
        dataSource = []
        firstItem = nil
        LocalNotifications.removeAllNotify()
    }
    
    func reloadData() {
        let list = UserDefaults.countdownLists
        refreshList(list: list)
    }
}

private extension RepositoryImp {
    private func refreshList(list:[CountDown]) {
        let df = DateFormatter()
        df.setupLocalAndFormat()
        var copyList:[CountDown] = []
        for var c in list {
            let date = df.date(from: c.date) ?? Date()
            let diffComponents = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: Date(), to: date)
            guard let day = diffComponents.day, let hour = diffComponents.hour, let minute = diffComponents.minute, let second = diffComponents.second else {
                break
            }
            
            let isInvalid:Bool = (day <= 0 && hour <= 0 && minute <= 0 && second <= 0)
            c.isInvalid = isInvalid
            copyList.append(c)
        }
        
        copyList = copyList.sorted(by: { (c1, c2) -> Bool in
            let d1 = df.date(from: c1.date)
            let d2 = df.date(from: c2.date)
            return d1!.compare(d2!) == .orderedAscending
        })
        dataSource = copyList
        firstItem = copyList.filter{ $0.isInvalid == false }.first
        UserDefaults.countdownLists = copyList
    }
}
