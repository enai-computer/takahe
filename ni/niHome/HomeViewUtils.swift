//
//  HomeViewUtils.swift
//  ni
//
//  Created by Patrick Lukas on 11/4/24.
//

import Foundation

func getWelcomeMessage() -> String{
	
	let currentHour = getHour()
	
	if(3 < currentHour && currentHour < 12){
		return "Good morning"
	}
	
	if(3 < currentHour && currentHour < 18){
		return "Good afternoon"
	}
	
	if(3 < currentHour && currentHour < 23){
		return "Good evening"
	}
	return "Welcome"
}

func getHour() -> Int{
	var cal = Calendar(identifier: .gregorian)
	cal.timeZone = TimeZone.current
	return cal.component(.hour, from: Date())
}
