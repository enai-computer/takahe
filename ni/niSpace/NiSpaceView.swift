//Created on 9.10.23

import Cocoa

class NiSpaceView: NSView{
    
    
    @IBOutlet var spaceName: NSTextField!
    
    @IBOutlet weak var niScrollView: NiScroll!
    
    func setSpaceName(_ name: String){
        spaceName.stringValue = name
    }
    
}
