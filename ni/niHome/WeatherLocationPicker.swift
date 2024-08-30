//
//  WeatherLocationPicker.swift
//  ni
//
//  Created by Patrick Lukas on 29/8/24.
//

import SwiftUI
import CoreLocation

class WeatherLocationModel: ObservableObject, Hashable, Codable{
	static func == (lhs: WeatherLocationModel, rhs: WeatherLocationModel) -> Bool {
		return lhs.city == rhs.city && lhs.country == rhs.country
	}
	
	let city: String
	let country: String
	let coordinates: CLLocation
	
	enum CodingKeys: String, CodingKey {
		case city
		case country
		case latCoordinate
		case longCoordinate
	}
	
	init(city: String, country: String, coordinates: CLLocation) {
		self.city = city
		self.country = country
		self.coordinates = coordinates
	}
	
	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		city = try container.decode(String.self, forKey: .city)
		country = try container.decode(String.self, forKey: .country)
		let lat = try container.decode(Double.self, forKey: .latCoordinate)
		let long = try container.decode(Double.self, forKey: .longCoordinate)
		self.coordinates = CLLocation(latitude: lat, longitude: long)
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(city, forKey: .city)
		try container.encode(country, forKey: .country)
		try container.encode(coordinates.coordinate.latitude, forKey: .latCoordinate)
		try container.encode(coordinates.coordinate.longitude, forKey: .longCoordinate)
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(city)
		hasher.combine(country)
		hasher.combine(coordinates)
	}
}

struct WeatherLocationPicker: View {
	
	@Binding var pickerShown: Bool
	@Binding var changeLocation: WeatherLocationModel
	
	@State private var searchText = ""
	@State private var locationSearchResults: WeatherLocationModel?
	@State private var cityName: String = ""
	@State private var isLoading: Bool
	
	@State private var hoversOnResult = false
	
	let geocoder = CLGeocoder()
	
	init(shown: Binding<Bool>, changeLocation: Binding<WeatherLocationModel>){
		self.isLoading = false
		self._pickerShown = shown
		self._changeLocation = changeLocation
	}
	
	var body: some View {
		VStack {
			SearchBar(text: $searchText, onSubmit: performSearch)
			
			if isLoading {
				ProgressView()
					.progressViewStyle(CircularProgressViewStyle())
			} else {
				if let res: WeatherLocationModel = locationSearchResults{
					Text("\(res.city), \(res.country)")
					.font(.custom("Sohne-Buch", size: 13))
					.foregroundColor(hoversOnResult ? .birkin : .sand12)
					.padding(.bottom, 16.0)
					.onHover { hovering in
						withAnimation {
							hoversOnResult = hovering
						}
					}
					.onTapGesture {
						UserSettings.updateValue(
							setting: .homeViewWeatherLocation,
							value: res
						)
						changeLocation = res
						pickerShown.toggle()
					}
				}else{
					Text("No results found")
					.font(.custom("Sohne-Buch", size: 13))
					.foregroundColor(.sand12)
					.padding(.bottom, 16.0)
				}
			}
		}
	}
	
	private func performSearch() {
		isLoading = true
		Task {
			do{
				let res = try await threadsafeSearch(searchText)
				DispatchQueue.main.async {
					self.locationSearchResults = res
					self.isLoading = false
				}
			}catch{
				print(error)
				DispatchQueue.main.async {
					self.isLoading = false
				}
			}
		}
	}
	
	private func threadsafeSearch(_ find: String) async throws -> WeatherLocationModel? {
		let results = try await geocoder.geocodeAddressString(find)
		for r in results{
			if let loc = r.location{
				return WeatherLocationModel(
					city: r.name ?? "",
					country: r.country ?? "",
					coordinates: loc
				)
			}
		}
		return nil
	}
}

struct SearchBar: View {
	@Binding var text: String
	var onSubmit: () -> Void
	
	var body: some View {
		HStack {
			TextField("Find your city...", text: $text, onCommit: onSubmit)
				.textFieldStyle(RoundedBorderTextFieldStyle())
				.font(.custom("Sohne-Buch", size: 13))
				.foregroundColor(.sand12)
			
			Button(action: onSubmit) {
				Text("search")
				.font(.custom("Sohne-Buch", size: 13))
				.foregroundColor(.sand12)
			}
		}
		.padding()
	}
}

//#Preview{
//	@State var shown: Bool = true
//	WeatherLocationPicker(shown: $shown)
//}
