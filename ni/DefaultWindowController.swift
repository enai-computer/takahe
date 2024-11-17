//Created on 07.10.23

import Cocoa

class DefaultWindowController: NSWindowController, NSWindowDelegate{
    
	private var prevScreenWidth: CGFloat? = nil
	private var prevScreenSize: CGSize? = nil
	private var spaceSaved = false
	private var spaceViewController: NiSpaceViewController? { contentViewController as? NiSpaceViewController }

    override func windowDidLoad() {
        super.windowDidLoad()
		window?.toggleFullScreen(nil)
		window?.isReleasedWhenClosed = true
		window?.delegate = self

		contentViewController = NiSpaceViewController()

		//HELP: in case you need to know the fonts
//		for family: String in NSFontManager.shared.availableFonts{
//			print(family)
//		}
	}

	func window(_ window: NSWindow, willUseFullScreenPresentationOptions proposedOptions: NSApplication.PresentationOptions = []) -> NSApplication.PresentationOptions {
		return [
			.fullScreen,
			// Both need to be combined to work: <https://developer.apple.com/documentation/appkit/nsapplication/presentationoptions>
			.hideMenuBar, .hideDock
		]
	}

	func windowDidEnterFullScreen(_ notification: Notification){
		guard let spaceViewController else { assertionFailure(); return }
		if(UserSettings.shared.isDefaultConfig){
			DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .milliseconds(500))){
				spaceViewController.showHomeView(canBeDismissed: false)
			}
		}else{
			spaceViewController.showHomeView(canBeDismissed: false)
		}
	}
	
	func windowDidChangeScreen(_ notification: Notification) {
		guard let windowObj = notification.object as? NSWindow else{return}
		AppDelegate.defaultWindowSize = windowObj.frame.size
		
		prevScreenSize = windowObj.frame.size
		
		//otherwise we have a screen reload on App start
		if(prevScreenWidth == nil){
			prevScreenWidth = windowObj.frame.width
			return
		}

		//application might be inactive soon
		if((NSApplication.shared.isActive || windowObj.isOnActiveSpace) && prevScreenWidth != windowObj.frame.width && !spaceSaved){
			guard let spaceViewController = contentViewController as? NiSpaceViewController else {return}
			spaceViewController.storeCurrentSpace()
			self.spaceSaved = true
		}
		
		//application will be active soon
		if(windowObj.isOnActiveSpace && prevScreenWidth != windowObj.frame.width){
			Task{
				try await Task.sleep(for: .milliseconds(300))
				DispatchQueue.main.async {
					self.doSpaceResize(windowObj)
				}
			}
		}
	}
	
	@MainActor
	private func doSpaceResize(_ windowObj: NSWindow){
		guard let spaceViewController = contentViewController as? NiSpaceViewController else {return}
		if(prevScreenWidth == windowObj.frame.width){
			return
		}
		spaceViewController.reloadSpace()
		self.spaceSaved = false
		
		prevScreenWidth = windowObj.frame.width
	}

	func windowWillClose(_ notification: Notification) {
		NSApplication.shared.terminate(nil)
	}
}
