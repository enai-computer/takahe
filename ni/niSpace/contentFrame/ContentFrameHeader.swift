//Created on 03.10.23

import Cocoa

class ContentFrameHeader: NSTextField{
    
    override func mouseDown(with event: NSEvent) {
        self.makeEditable()
    }
    
    func makeEditable(){
        self.isEditable = true
        
        self.backgroundColor = .sandDark1
        self.textColor = .sandLight1
    }
    
    func disableEdit(){
        self.isEditable = false
        
        self.backgroundColor = .sandLight1
        self.textColor = .sandDark1
    }
    
    open override func currentEditor() -> NSText? {
        let editor = super.currentEditor()
        
        if
            let fieldEditor = editor as? NSTextView,
            let customInsertionPointColor
        {
            fieldEditor.insertionPointColor = customInsertionPointColor
            fieldEditor.updateInsertionPointStateAndRestartTimer(true)
        }
        
        return editor
    }
    
    var customInsertionPointColor: NSColor?{
        get {
            .sandLight1
        }
        set {

        }
    }
    
}

