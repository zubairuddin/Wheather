//
//  ViewController.swift
//  WeatherApp
//
//  Created by Avicenna on 01/09/2018.
//  Copyright (c) 2018 Avicenna. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

enum TempratureUnit {
    case fahrenheit
    case celcius
}

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "23030bfcf6b163c0e6ab7a0d6fdfe610"
    
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
 
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var btnFahrenheit: UIButton!
    
    var selectedTempratureUnit: TempratureUnit!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        //By default fahrenheit will be selected
        selectedTempratureUnit = .fahrenheit
    }
       
    //MARK: - Networking
    func getWeatherData(url: String, parameters: [String: String]) {
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                
                print("Success! Got the weather data")
                let weatherJSON : JSON = JSON(response.result.value!)
                
                print(weatherJSON)
                
                self.updateWeatherData(json: weatherJSON)
                
            }
            else {
                print("Error \(String(describing: response.result.error))")
                self.cityLabel.text = "Connection Issues"
            }
        }
        
    }
    
    func updateWeatherData(json : JSON) {
    
        let tempResult = json["main"]["temp"].doubleValue

        if tempResult > 0 {
            print("City = \(json["name"].stringValue),Kelvin= \(tempResult) Fahrenheit = \(Int(tempResult - 273.15) * 9 / 5 + 32), Celcius = \(Int(tempResult - 273.15))")
            //The temp returned from openWeatherMap API is in kelvin, we need to convert it in celcius or fahrenheit
            weatherDataModel.temperatureCelcius = Int(tempResult - 273.15)
            weatherDataModel.temperatureFahrenheit = Int(tempResult - 273.15) * 9 / 5 + 32
            
            weatherDataModel.city = json["name"].stringValue
            
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
            
            updateUIWithWeatherData()

        }
        else {
            let alert = UIAlertController(title: "City not found!", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func updateUIWithWeatherData() {
        
        cityLabel.text = weatherDataModel.city
        
        //If fahrenheit is selected then show temprature in fahrenheit else show temprature in celcius
        temperatureLabel.text = selectedTempratureUnit == .fahrenheit ? "\(weatherDataModel.temperatureFahrenheit)°" : "\(weatherDataModel.temperatureCelcius)°"
        
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    
    //MARK: - Location Manager Delegate Methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            
            self.locationManager.stopUpdatingLocation()
            
            print("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let params = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
            
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }

    //MARK: - Change City Delegate methods
    func userEnteredANewCityName(city: City) {
        //let params : [String : String] = ["q" : city, "appid" : APP_ID]
        
        let params = ["lat" : city.latitude, "lon" : city.longitude, "appid" : APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
    }
    
    //MARK: - Actions
    @IBAction func changeCityAction(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ChangeCityViewController") as! ChangeCityViewController
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        
        selectedTempratureUnit = sender.selectedSegmentIndex == 0 ? .fahrenheit : .celcius
        updateUIWithWeatherData()
    }
    
}











