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
	@State var weatherLocation: WeatherLocationModel
	let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
	
	@State private var showCityPicker = false
	
	init(for location: WeatherLocationModel){
		self.weatherLocation = location
	}
	
	var body: some View {
		VStack(alignment: .trailing, spacing: 4.0) {
			HStack{
				Text("\(weatherLocation.city), \(weatherLocation.country)" )
					.font(.custom("Sohne-Buch", size: 18))
					.foregroundColor(.sand11)
				Image(systemName: weatherData.symbolName)
					.font(.custom("Sohne-Buch", size: 18))
					.foregroundColor(.sand115)
			}
			.padding(.bottom, 6.0)
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
		.popover(isPresented: $showCityPicker) {
			WeatherLocationPicker(shown: $showCityPicker, changeLocation: $weatherLocation)
		}
		.onTapGesture {
			showCityPicker.toggle()
		}
		.onChange(of: weatherLocation){
			Task{
				await fetchWeather()
			}
		}
	}
	
	func fetchWeather() async {
		do {
			let coordinates = weatherLocation.coordinates
			let weather = try await WeatherService.shared.weather(for: coordinates)
			weatherData = WeatherData(weather: weather)
		} catch {
			print("Error fetching weather: \(error)")
		}
	}
	
}


#Preview {
	WeatherView(for: 
		WeatherLocationModel(
			city: "Berlin",
			country: "Germany",
			coordinates: CLLocation(latitude: 52.5200, longitude: 13.4050) // Berlin coordinates
		)
	)
}
