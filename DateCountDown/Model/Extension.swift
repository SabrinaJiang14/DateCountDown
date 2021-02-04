//
//  Extension.swift
//  DateCountDown
//
//  Created by sabrina on 2021/1/27.
//

import Cocoa

extension NSImage {
    public func resizeImage(_ size: NSSize) -> NSImage {
        let targetFrame = NSRect(origin: CGPoint(x: 0, y: 0), size: size);
        let targetImage = NSImage(size: size)
        let selfSize = self.size
        let ratioHeight = size.height / selfSize.height
        let ratioWidth = size.width / selfSize.width
        var cropRect = NSZeroRect
        if ratioHeight >= ratioWidth {
            cropRect.size.width = floor (size.width / ratioHeight)
            cropRect.size.height = selfSize.height
        } else {
            cropRect.size.width = selfSize.width
            cropRect.size.height = floor(size.height / ratioWidth)
        }

        cropRect.origin.x = floor((selfSize.width - cropRect.size.width) / 2)
        cropRect.origin.y = floor((selfSize.height - cropRect.size.height) / 2)

        targetImage.lockFocus()
        self.draw(in: targetFrame,
                  from: cropRect,
                  operation: .copy,
                  fraction: 1.0,
                  respectFlipped: true,
                  hints: [
                            NSImageRep.HintKey.interpolation : NSImageInterpolation.low.rawValue
                          ])

        targetImage.unlockFocus()
        return targetImage
    }
}


extension UserDefaults {
    @UserDefaultsArrayMaster("COUNTDOWN_LISTS", [])
    static var countdownLists : [CountDown]
}

extension DateFormatter {
    func setupLocalAndFormat() {
        self.dateFormat = "yyyy/MM/dd EEEE"
        self.locale = Locale(identifier: "zh_TW")
    }
}

enum Print {
    static public func info<T>(_ message:T, file:String = #file, function:String = #function, line:Int = #line) {
        #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        print("\n✅ [INFO] [\(fileName)][\(function)][\(line)] : \(message)")
        #endif
    }
}
