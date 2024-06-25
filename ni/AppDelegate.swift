//  Created on 11.09.23.

import Cocoa
import Carbon.HIToolbox
import PostHog

@main
class AppDelegate: NSObject, NSApplicationDelegate {
	
	//TODO: move to a user controlled config file
	let min_inactive_switch_to_home: Double = 29.0
	static var defaultWindowSize: CGSize?
	
	//analytics
	private var applicationStarted: Date? = nil
	private var spacesLoaded: [UUID:Int] = [:]
	
	private var lastActive: Date? = nil
	//if loading fails we do not want to overwrite the space!
	private var dontStoreSpace = Set<UUID>()
	
    func applicationDidFinishLaunching(_ aNotification: Notification) {
		
		_ = Storage.instance
		
		let POSTHOG_API_KEY = "phc_qwTCTecFkqQyd3OYFoiWniEjMLBmJ3KL8P5rNRqJYN1"
		let POSTHOG_HOST = "https://eu.i.posthog.com"
		let postHogConfig = PostHogConfig(apiKey: POSTHOG_API_KEY, host: POSTHOG_HOST)
		PostHogSDK.shared.setup(postHogConfig)
		
		applicationStarted = Date()
		setLocalKeyListeners()
    }
		
    func applicationWillTerminate(_ aNotification: Notification) {
        //TODO: Insert code here to tear down your application
		
		//PostHog
		let timeSinceStartMin = (Date().timeIntervalSinceReferenceDate - applicationStarted!.timeIntervalSinceReferenceDate) / 60
		PostHogSDK.shared.capture("Application_closed", properties: ["time_since_start_minutes": timeSinceStartMin, "nr_of_spaces_visted": spacesLoaded.count])
		PostHogSDK.shared.flush()
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

	func applicationWillResignActive(_ notification: Notification) {
		if let window = NSApplication.shared.mainWindow as? DefaultWindow{
			if let controller = window.contentViewController as? NiSpaceViewController{
				controller.storeCurrentSpace()
			}
		}
		lastActive = Date()
	}
	
	func applicationWillBecomeActive(_ notification: Notification) {
		if(lastActive == nil){
			return
		}
		let minInactive = (Date().timeIntervalSinceReferenceDate - lastActive!.timeIntervalSinceReferenceDate) / 60
		let userSentBackHome = false
		
//		if(min_inactive_switch_to_home < minInactive){
//			let window = getDefaultWindow(notification)
//			if (window != nil){
//				if let controller = window!.contentViewController as? NiSpaceViewController{
//					//saved when going inactive. No need to do it again here
//					controller.returnToHome(saveCurrentSpace: false)
//				}
//			}else{
//				print("no window found")
//			}
//			userSentBackHome = true
//		}
//		
		PostHogSDK.shared.capture("Application_became_active", properties: ["time_inactive_mins": minInactive, "sent_back_home": userSentBackHome])
	}
	
	private func getDefaultWindow(_ notification: Notification) -> DefaultWindow?{
		guard let appWind = (notification.object as? NSApplication)?.windows else {return nil}
		for win in appWind {
			if(win is DefaultWindow){
				return win as? DefaultWindow
			}
		}
		return nil
	}
	
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        // Save changes in the application's managed object context before the application terminates.
		let window = NSApplication.shared.mainWindow
		if (window != nil && window is DefaultWindow){
			if let controller = window!.contentViewController as? NiSpaceViewController{
				controller.storeCurrentSpace()
			}
		}
        return .terminateNow
    }

	func spaceLoadedSinceStart(_ spaceID: UUID) -> Int{
		if(spacesLoaded[spaceID] == nil){
			spacesLoaded[spaceID] = 1
			return 1
		}
		let nrOfLoads = spacesLoaded[spaceID]! + 1
		spacesLoaded[spaceID] = nrOfLoads
		return nrOfLoads
	}
	
	func disableSaveForSpace(_ spaceID: UUID){
		dontStoreSpace.insert(spaceID)
	}
	
	func allowedToSaveSpace(_ spaceID: UUID) -> Bool{
		return !dontStoreSpace.contains(spaceID)
	}
	
	@IBAction func switchToNextTab(_ sender: NSMenuItem) {
		getNiSpaceViewController()?.switchToNextTab()
	}
	
	@IBAction func switchToPrevTab(_ sender: NSMenuItem) {
		getNiSpaceViewController()?.switchToPrevTab()
	}
	
	@IBAction func createNewTab(_ sender: NSMenuItem) {
		getNiSpaceViewController()?.createNewTab()
	}
	
	@IBAction func toggleEditMode(_ sender: NSMenuItem){
		getNiSpaceViewController()?.toggleEditMode()
	}
	
	@IBAction func switchToNextWindow(_ sender: NSMenuItem) {
		getNiSpaceViewController()?.switchToNextWindow()
	}
	
	@IBAction func switchToPrevWindow(_ sender: NSMenuItem) {
		getNiSpaceViewController()?.switchToPrevWindow()
	}
	
	@IBAction func minimizeCF(_ sender: NSMenuItem) {
		getNiSpaceViewController()?.toggleMinimizeOnTopCF(sender)
	}
	
	@IBAction func showPalette(_ sender: NSMenuItem) {
		showPalette()
	}
	
	private func showPalette(){
		if (NSApplication.shared.keyWindow is NiHomeWindow){
			return
		}
		//TODO: make async
		getNiSpaceViewController()?.storeCurrentSpace()
		let	palette = NiPalette()
		palette.makeKeyAndOrderFront(nil)
	}
	
	private func getNiSpaceViewController() -> NiSpaceViewController?{
		if let window = NSApplication.shared.mainWindow as? DefaultWindow{
			if let controller = window.contentViewController as? NiSpaceViewController{
				return controller
			}
		}
		return nil
	}
	
	private func setLocalKeyListeners(){
		NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: {(event: NSEvent) in
			if(event.modifierFlags.contains(.command) && event.keyCode == kVK_LeftArrow){
				self.getNiSpaceViewController()?.switchToPrevWindow()
				return nil
			}
			if(event.modifierFlags.contains(.command) && event.keyCode == kVK_RightArrow){
				self.getNiSpaceViewController()?.switchToNextWindow()
				return nil
			}
			if(event.modifierFlags.contains(.command) && event.keyCode == kVK_ANSI_Slash){
				self.showPalette()
				return nil
			}
			if(event.modifierFlags.contains(.control) && event.modifierFlags.contains(.shift) && event.keyCode == kVK_Tab){
				self.getNiSpaceViewController()?.switchToPrevTab()
				return nil
			}
			if(event.modifierFlags.contains(.control) && event.keyCode == kVK_Tab){
				self.getNiSpaceViewController()?.switchToNextTab()
				return nil
			}
			return event
		})
	}
}

