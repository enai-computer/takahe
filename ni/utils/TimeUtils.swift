//
//  TimeUtils.swift
//  ni
//
//  Created by Patrick Lukas on 15/4/24.
//

import Foundation

let _localisedDateFormatter = getLocalisedDateFormatter()

func getLocalHour() -> Int{
	var cal = Calendar(identifier: .gregorian)
	cal.timeZone = TimeZone.current
	return cal.component(.hour, from: Date())
}

func getLocalisedDateFormatter() -> DateFormatter{
	let f = DateFormatter()
	
	f.timeStyle = .short
	f.timeZone = TimeZone.current
	f.locale = Locale.current
	f.calendar = Calendar.current
	
	return f
}

func getLocalisedTime() -> String{
	return _localisedDateFormatter.string(from: Date())
}
