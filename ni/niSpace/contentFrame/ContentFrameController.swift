//
//  ContentFrameController.swift
//  ni
//
//  Created by Patrick Lukas on 12/3/23.
//

import Foundation
import Cocoa
import WebKit

class ContentFrameController: NSViewController{
    
    
    override func loadView() {
        self.view = NSView.loadFromNib(nibName: "ContentFrameView", owner: self)! as! ContentFrameView
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor(.sandLight1).cgColor
    }
    

}
