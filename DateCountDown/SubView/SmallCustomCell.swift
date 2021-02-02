//
//  SmallCustomCell.swift
//  DateCountDown
//
//  Created by sabrina on 2021/1/27.
//

import Cocoa

class SmallCustomCell: NSTableCellView {

    @IBOutlet weak var txtName: NSTextField!
    @IBOutlet weak var txtTime: NSTextField!
    @IBOutlet weak var txtCountdown: NSTextField!
    
    
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        // Drawing code here.
    }
    
}
