//
//  ViewController.swift
//  WeatherApp
//
//  Created by Churong Zhang on 12/26/18.
//  Copyright © 2018 Churong Zhang. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON



class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "4a7cecdd5087a1e77acd6fbb66c4552b"
    /***Get your own App ID at https://openweathermap.org/appid ****/
    var params: [String:String]?
    var location: CLLocation?

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        //////// ask user for
        //locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.startUpdatingLocation()
        
        
        
    }
    @objc func activeAgain()
    {
        print("active again")
        RefreshPressed(self)
    }
    
   
    
    @IBAction func RefreshPressed(_ sender: Any) {
//        if location!.horizontalAccuracy > 0 {
//            getWeatherData(url: WEATHER_URL, parameters: params!)
//            print("Refresh in the same location")
//        }
//        else {
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
            print("Refresh with a new loaction")
//        }
        
    }
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData(url: String, parameters:[String:String]){
        
        Alamofire.request(url, method:.get, parameters: parameters).responseJSON { respond in
            if respond.result.isSuccess {
                print("Success! Got the weather Data")
                
               //print(respond)
                
                //print(Int64(self.timeIntervalSince1970 * 1000))
             //   print(Date().timeIntervalSince1970 * 1000)
               // print(NSDate().timeIntervalSince1970 * 1000)
                
                let weatherJSON : JSON = JSON(respond.result.value!)
                self.updateWeatherData(json: weatherJSON)
            }
            else {
              //  print("Error \(respond.result.error)")
                self.cityLabel.text = "Connection Issues"
            }
        }
    }

 
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json: JSON){
        if let tempResult = json["main"]["temp"].double{
       // print("udating data")
        weatherDataModel.temperature = Int(tempResult - 273.15)
        weatherDataModel.city = json["name"].stringValue
        weatherDataModel.condition = json["weather"][0]["id"].intValue
        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
            updateUIWithWeatherData()
        }
        else
        {
            cityLabel.text = "Weather Unavailable"
        }
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    func updateUIWithWeatherData()
    {
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature) ℃"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations[locations.count - 1]
        if location!.horizontalAccuracy > 0{
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            
            print("longitude = \(location!.coordinate.longitude), latitude = \(location!.coordinate.latitude)")
            
            let latitude = "\(location!.coordinate.latitude)"
            let longitude = "\(location!.coordinate.longitude)"
            
            //let params: [String:String] = ["lat": latitude, "lon": longitude, "appid" : APP_ID]
            params = ["lat": latitude, "lon": longitude, "appid" : APP_ID]
            getWeatherData(url: WEATHER_URL, parameters: params!)
            
        }
        
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnterANewCityName(city: String) {
        let param : [String:String] = ["q": city, "appid": APP_ID]
        print ("Switch city")
        getWeatherData(url: WEATHER_URL, parameters: param)
        
    }

    
    //Write the PrepareForSegue Method here
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
        }
    }
    
    
    
}


