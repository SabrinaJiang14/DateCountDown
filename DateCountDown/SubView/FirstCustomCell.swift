//
//  FirstCustomCell.swift
//  DateCountDown
//
//  Created by sabrina on 2021/1/27.
//

import Cocoa

class FirstCustomCell: NSTableCellView {
    
    @IBOutlet weak var viewStack: NSStackView!
    @IBOutlet weak var txtCountdown: NSTextField!
    @IBOutlet weak var txtName: NSTextField!
    @IBOutlet weak var txtTime: NSTextField!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        self.wantsLayer = true
        self.layer?.backgroundColor = .clear
        // Drawing code here.
    }
    
}
