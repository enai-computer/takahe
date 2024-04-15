//
//  HomeViewUtils.swift
//  ni
//
//  Created by Patrick Lukas on 11/4/24.
//

import Foundation
import Cocoa

func getWelcomeMessage() -> String{
	
	let currentHour = getHour()
	
	if(3 < currentHour && currentHour < 12){
		return "Good morning"
	}
	
	if(11 < currentHour && currentHour < 18){
		return "Good afternoon"
	}
	
	if(17 < currentHour && currentHour < 23){
		return "Good evening"
	}
	return "Hello"
}

func getHour() -> Int{
	var cal = Calendar(identifier: .gregorian)
	cal.timeZone = TimeZone.current
	return cal.component(.hour, from: Date())
}

func openExistingSpace(spaceId: UUID, name: String){
	let appDelegate = NSApp.delegate as! AppDelegate
	appDelegate.loadExistingSpace(niSpaceID: spaceId, name: name)
}

func openNewSpace(){
	let appDelegate = NSApp.delegate as! AppDelegate
	appDelegate.switchToNewSpace()
}
