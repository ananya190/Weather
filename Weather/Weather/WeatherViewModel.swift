//
//  WeatherViewModel.swift
//  Weather
//
//  Created by Ananya George on 8/10/21.
//
// Gets data from WeatherService and convert into a format that the WeatherView can use
import Foundation

private let defaultIcon = "❓"

private let iconMap = [
    "Drizze": "🌧",
    "Thunderstorm":"⛈",
    "Rain":"🌧",
    "Snow":"❄️",
    "Clear":"☀️",
    "Clouds":"☁️"
]


// ObservableObject can be observed for changes. It will publish announcements when the values are updated
public class WeatherViewModel: ObservableObject {
    @Published var cityName: String = "City Name"
    @Published var temperature: String = "--"
    @Published var weatherDescription: String = "--"
    @Published var weatherIcon: String = defaultIcon
    
    public let weatherService: WeatherService
    
    public init(weatherService: WeatherService) {
        self.weatherService = weatherService
    }
    
    public func refresh(){
        weatherService.loadWeatherData { weather in
            // this updates the main queue
            DispatchQueue.main.async {
                self.cityName = weather.city
                self.temperature = "\(weather.temperature)ºC"
                self.weatherDescription = weather.description.capitalized
                self.weatherIcon = iconMap[weather.iconName] ?? defaultIcon
            }
        }
    }
}
