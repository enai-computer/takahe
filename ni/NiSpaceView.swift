//Created on 9.10.23

import Cocoa

class NiSpaceView: NSView{
    
    
    @IBOutlet var spaceName: NSTextField!
    
    func setSpaceName(_ name: String){
        spaceName.stringValue = name
    }
    
}
