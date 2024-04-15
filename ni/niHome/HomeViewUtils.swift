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
	
	if(11 < currentHour && currentHour < 18){
		return "Good afternoon"
	}
	
	if(17 < currentHour && currentHour < 23){
		return "Good evening"
	}
	return "Hello"
}
