//
//  WeatherWidget.swift
//  ni
//
//  Created by Patrick Lukas on 29/8/24.
//

import SwiftUI
import WeatherKit
import WidgetKit
import CoreLocation

struct WeatherData {
	let temperature: String
	let symbolName: String
	
	init(weather: Weather?) {
		let temp = weather?.currentWeather.temperature.value ?? 0
		temperature = String(format: "%.0f", temp)
		symbolName =  "cloud.sun"	//weather?.currentWeather.symbolName ?? "sun.max.fill"
	}
	
	static let placeholder = WeatherData(weather: nil)
}

struct WeatherView: View {
	@State private var weatherData = WeatherData.placeholder
	@State private var currentTime = getCurrentTime()
	let cityName = "Berlin, Germany"
	let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
	
	var body: some View {
		HStack(spacing: 8) {
			VStack(alignment: .trailing) {
				HStack{
					Text(cityName)
						.font(.system(size: 24, weight: .medium))
						.foregroundColor(.sand11)
					Image(systemName: weatherData.symbolName)
						.font(.system(size: 24))
						.tint(.yellow)
						.foregroundColor(.sand115)
				}
				.padding(.bottom, 9.0)
				
				HStack(alignment: .lastTextBaseline, spacing: 8) {
					Text(currentTime)
						.font(.system(size: 24, weight: .bold))
						.foregroundColor(.sand11)
					Text(" | ")
						.font(.system(size: 24, weight: .bold))
						.foregroundColor(.sand11)
					Text(weatherData.temperature)
						.font(.system(size: 24, weight: .bold))
						.foregroundColor(.sand11)
					Text("°C ")
						.font(.system(size: 24, weight: .medium))
						.foregroundColor(.sand11)
				}
			}
		}
		.padding()
		.onReceive(timer) { _ in
			self.currentTime = WeatherView.getCurrentTime()
		}
		.task {
			await fetchWeather()
		}
	}
	
	private func fetchWeather() async {
		do {
			let location = CLLocation(latitude: 52.5200, longitude: 13.4050) // Berlin coordinates
			let weather = try await WeatherService.shared.weather(for: location)
			weatherData = WeatherData(weather: weather)
		} catch {
			print("Error fetching weather: \(error)")
		}
	}
	
	private static func getCurrentTime() -> String {
		let formatter = DateFormatter()
		formatter.timeStyle = .short
		return formatter.string(from: Date())
	}
}


#Preview {
	WeatherView()
}
