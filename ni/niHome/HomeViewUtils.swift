//
//  HomeViewUtils.swift
//  ni
//
//  Created by Patrick Lukas on 11/4/24.
//

import Foundation
import Cocoa

func getWelcomeMessage() -> String{
	
	let currentHour = getLocalHour()
	
	if(3 < currentHour && currentHour < 12){
		return "Good morning"
	}
	
	if(11 < currentHour && currentHour < 20){
		return "Good afternoon"
	}
	
	if(19 < currentHour && currentHour < 24){
		return "Good evening"
	}
	return "Hello"
}
