//
//  TimeUtils.swift
//  ni
//
//  Created by Patrick Lukas on 15/4/24.
//

import Foundation

func getLocalHour() -> Int{
	var cal = Calendar(identifier: .gregorian)
	cal.timeZone = TimeZone.current
	return cal.component(.hour, from: Date())
}

func getLocalisedTime() -> String{
	let f = DateFormatter()
	
	f.timeStyle = .short
	f.timeZone = TimeZone.current
	f.locale = Locale.current
	f.calendar = Calendar.current
	
	return f.string(from: Date())
}
