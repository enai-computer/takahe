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
		symbolName = weather?.currentWeather.symbolName ?? "sun.max.fill"
	}
	
	static let placeholder = WeatherData(weather: nil)
}

struct WeatherView: View {
	@State private var weatherData = WeatherData.placeholder
	@State private var currentTime = getLocalisedTime()
	let cityName = "Berlin, Germany"
	let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
	
	var body: some View {
		VStack(alignment: .trailing, spacing: 4.0) {
			HStack{
				Text(cityName)
					.font(.custom("Sohne-Buch", size: 18))
					.foregroundColor(.sand11)
				Image(systemName: weatherData.symbolName)
					.font(.custom("Sohne-Buch", size: 18))
					.tint(.yellow)
					.foregroundColor(.sand115)
			}
			.padding(.bottom, 9.0)
			HStack(alignment: .lastTextBaseline, spacing: 4) {
				Text(currentTime)
					.font(.custom("Sohne-Buch", size: 18))
					.foregroundColor(.sand11)
				Text(" | ")
					.font(.custom("Sohne-Buch", size: 18))
					.foregroundColor(.sand11)
				Text(weatherData.temperature)
					.font(.custom("Sohne-Buch", size: 18))
					.foregroundColor(.sand11)
				Text("°C ")
					.font(.custom("Sohne-Buch", size: 18))
					.foregroundColor(.sand11)
			}
		}
		.frame(alignment: .trailing)
		.onReceive(timer) { _ in
			self.currentTime = getLocalisedTime()
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
	
}


#Preview {
	WeatherView()
}
