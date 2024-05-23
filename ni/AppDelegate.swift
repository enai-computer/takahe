//  Created on 11.09.23.

import Cocoa
import Carbon.HIToolbox
import PostHog

@main
class AppDelegate: NSObject, NSApplicationDelegate {
	
	//TODO: move to a user controlled config file
	let min_inactive_switch_to_home: Double = 29.0
	
	//analytics
	private var applicationStarted: Date? = nil
	private var spacesLoaded: [UUID:Int] = [:]
	
	private var lastActive: Date? = nil
	//if loading fails we do not want to overwrite the space!
	private var dontStoreSpace = Set<UUID>()
	
    func applicationDidFinishLaunching(_ aNotification: Notification) {
		
		_ = Storage.db
		
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
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "ni")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving and Undo support

    @IBAction func saveAction(_ sender: AnyObject?) {
        // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
        let context = persistentContainer.viewContext

        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing before saving")
        }
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Customize this code block to include application-specific recovery steps.
                let nserror = error as NSError
                NSApplication.shared.presentError(nserror)
            }
        }
    }
	
    func windowWillReturnUndoManager(window: NSWindow) -> UndoManager? {
        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
        return persistentContainer.viewContext.undoManager
    }

	func applicationWillResignActive(_ notification: Notification) {
		let window = NSApplication.shared.keyWindow
		if (window != nil && window is DefaultWindow){
			if let controller = window!.contentViewController as? NiSpaceViewController{
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
		var userSentBackHome = false
		
		if(min_inactive_switch_to_home < minInactive){
			let window = getDefaultWindow(notification)
			if (window != nil){
				if let controller = window!.contentViewController as? NiSpaceViewController{
					//saved when going inactive. No need to do it again here
					controller.returnToHome(saveCurrentSpace: false)
				}
			}else{
				print("no window found")
			}
			userSentBackHome = true
		}
		
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
		let window = NSApplication.shared.keyWindow
		if (window != nil && window is DefaultWindow){
			if let controller = window!.contentViewController as? NiSpaceViewController{
				controller.storeCurrentSpace()
			}
		}

//        let context = persistentContainer.viewContext
//        
//        if !context.commitEditing() {
//            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing to terminate")
//            return .terminateCancel
//        }
//        
//        if !context.hasChanges {
//            return .terminateNow
//        }
//        
//        do {
//            try context.save()
//        } catch {
//            let nserror = error as NSError
//
//            // Customize this code block to include application-specific recovery steps.
//            let result = sender.presentError(nserror)
//            if (result) {
//                return .terminateCancel
//            }
//            
//            let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
//            let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
//            let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
//            let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
//            let alert = NSAlert()
//            alert.messageText = question
//            alert.informativeText = info
//            alert.addButton(withTitle: quitButton)
//            alert.addButton(withTitle: cancelButton)
//            
//            let answer = alert.runModal()
//            if answer == .alertSecondButtonReturn {
//                return .terminateCancel
//            }
//        }
        // If we got here, it is time to quit.
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
	
	private func getNiSpaceViewController() -> NiSpaceViewController?{
		let window = NSApplication.shared.keyWindow
		if (window != nil && window is DefaultWindow){
			if let controller = window!.contentViewController as? NiSpaceViewController{
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

