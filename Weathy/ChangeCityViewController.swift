//
//  ChangeCityViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit

protocol ChangeCityDelegate {
    func userEnteredANewCityName(city: String)
}

class ChangeCityViewController: UIViewController {
    
    var delegate : ChangeCityDelegate?
    
    @IBOutlet weak var tblCities: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var allCities: Cities!
    var arrFilteredCities = [City]()
    var isSearching = false
    
    override func viewDidLoad() {
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Get all the cities from file and parse the response
        let filePath = Bundle.main.path(forResource: "United Kingdom", ofType: ".json")
        let data = try! Data(contentsOf: URL(fileURLWithPath: filePath!), options: .alwaysMapped)
        
        allCities = try! JSONDecoder().decode(Cities.self, from: data)
        
        //print(allCities)
        
        //Add Gesture regognizer to dismiss keyboard when user clicks on the table view
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        gestureRecognizer.numberOfTapsRequired = 1
        //self.view.addGestureRecognizer(gestureRecognizer)

    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func getCity(atIndex index:Int) -> City {
        var city: City!
        
        if isSearching {
            city = arrFilteredCities[index]
        }
        else {
            city = allCities.cities[index]
        }
        
        return city
    }
    
}

extension ChangeCityViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isSearching {
            return arrFilteredCities.count
        }
        
        return allCities.cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell", for: indexPath) as! CityCell
        
        let city = getCity(atIndex: indexPath.row)
        cell.lblCityName.text = city.name
        
        return cell
    }
    
}
extension ChangeCityViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let city = getCity(atIndex: indexPath.row)
        delegate?.userEnteredANewCityName(city: city.name)
        self.navigationController?.popViewController(animated: true)
    }
}
extension ChangeCityViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        searchBar.text = ""
        tblCities.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if !searchText.isEmpty {
            isSearching = true
            arrFilteredCities = allCities.cities.filter{
                return $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
        else {
            isSearching = false
        }
        
        tblCities.reloadData()
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//        isSearching = false
//        searchBar.text = ""
//        tblCities.reloadData()
    }
}
