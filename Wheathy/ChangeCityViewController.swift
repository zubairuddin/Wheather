//
//  ChangeCityViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit


//Write the protocol declaration here:
protocol ChangeCityDelegate {
    func userEnteredANewCityName(city: String)
}


class ChangeCityViewController: UIViewController {
    
    var delegate : ChangeCityDelegate?
    
    @IBOutlet weak var tblCities: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var allCities: Cities!
    
    override func viewDidLoad() {
        
        //Register nib cell
        tblCities.register(CityCell.self, forCellReuseIdentifier: "CityCell")

        //Get all the cities from file and parse the response
        let filePath = Bundle.main.path(forResource: "United Kingdom", ofType: ".json")
        let data = try! Data(contentsOf: URL(fileURLWithPath: filePath!), options: .alwaysMapped)
        let dict = try! JSONSerialization.jsonObject(with: data, options: .allowFragments)
        print(dict)
        
        allCities = try! JSONDecoder().decode(Cities.self, from: data)

    }
    
    @IBAction func getWeatherPressed(_ sender: AnyObject) {
        
    }
    
    

    //This is the IBAction that gets called when the user taps the back button. It dismisses the ChangeCityViewController.
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ChangeCityViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allCities.cities.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell", for: indexPath) as! CityCell
        
        let city = allCities.cities[indexPath.row]
        cell.lblCityName.text = city.name
        
        return cell
    }
}
