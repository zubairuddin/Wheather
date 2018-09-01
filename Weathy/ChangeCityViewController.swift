//
//  ChangeCityViewController.swift
//  WeatherApp
//
//  Created by Avicenna on 01/09/2018.
//  Copyright (c) 2018 Avicenna. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol ChangeCityDelegate {
    func userEnteredANewCityName(city: City)
}

class ChangeCityViewController: UIViewController {
    
    var delegate : ChangeCityDelegate?
    
    @IBOutlet weak var tblCities: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var allCities: Cities!
    var arrAllCitiesSorted = [City]()
    var arrFilteredCities = [City]()
    var isSearching = false
    
    override func viewDidLoad() {
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Get all the cities from file and parse the response
        
        let filePath = Bundle.main.path(forResource: "United States", ofType: ".json")
        
        //Show the loader
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.show()
        
        DispatchQueue.global().async {
            let data = try! Data(contentsOf: URL(fileURLWithPath: filePath!), options: .alwaysMapped)
            
            self.allCities = try! JSONDecoder().decode(Cities.self, from: data)
            self.arrAllCitiesSorted = self.allCities.cities.sorted(by: {$0.name < $1.name})
            
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.tblCities.reloadData()
            }
        }
        
        //Add Gesture regognizer to dismiss keyboard when user clicks on the table view
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
            city = arrAllCitiesSorted[index]
        }
        
        return city
    }
    
}

extension ChangeCityViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isSearching {
            return arrFilteredCities.count
        }
        
        return arrAllCitiesSorted.count
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
        delegate?.userEnteredANewCityName(city: city)
        self.navigationController?.popViewController(animated: true)
    }
}
extension ChangeCityViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        isSearching = false
        searchBar.text = ""
        tblCities.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if !searchText.isEmpty {
            isSearching = true
            arrFilteredCities = arrAllCitiesSorted.filter{
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
