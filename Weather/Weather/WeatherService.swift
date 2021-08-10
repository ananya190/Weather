//
//  WeatherService.swift
//  Weather
//
//  Created by Ananya George on 8/10/21.
//

import CoreLocation
import Foundation

public final class WeatherService: NSObject {
        
    private let locationManager = CLLocationManager()
    // apiKey stored in an untracked file
    private let API_KEY = apiKey
    // completion handler - executed once data received
    private var completionHandler: ((Weather) -> Void)?
    
    // implementing CLLocationManager delegate
    public override init(){
        super.init()
        // object to be notified when an event occurs
        locationManager.delegate = self
        
        
    }
    
    public func loadWeatherData(_ completionHandler: @escaping ((Weather) -> Void)){
        // escaping closures are executed after the function they're passed to returns
        self.completionHandler  = completionHandler
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // sends request to OpenWeatherMap using coordinates and API Key
    // api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={API key}
    private func makeDataRequest(forCoordinates coordinates: CLLocationCoordinate2D){
        guard let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(coordinates.latitude)&lon=\(coordinates.longitude)&appid=\(API_KEY)&units=metric".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            guard error == nil, let data = data else {
                return
            }
            // if data exists and there is no error, decode the JSON
            if let response = try? JSONDecoder().decode(APIResponse.self, from: data) {
                // optional try returns nil if an error is thrown
                self.completionHandler?(Weather(response: response))
            }
            
        }.resume()
        
    }
    
}

extension WeatherService: CLLocationManagerDelegate {
    
    public func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.first else { return }
        makeDataRequest(forCoordinates: location.coordinate)
    }
    
    public func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        // print the error
        print("Something went wrong: \(error.localizedDescription)")
    }
}

// Struct for response
struct APIResponse: Decodable {
    let name: String
    let main: APIMain
    let weather: [APIWeather]
}

struct APIMain: Decodable {
    let temp: Double
}


struct APIWeather: Decodable {
    
    let description: String
    let iconName: String
    
    
    
    
    
    enum CodingKeys: String, CodingKey {
        case description
        case iconName = "main"
    }
}


