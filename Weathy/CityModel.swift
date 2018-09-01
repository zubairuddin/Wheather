//
//  CityModel.swift
//  Clima
//
//  Created by Zubair.Nagori on 06/08/18.
//  Copyright © 2018 Avicenna. All rights reserved.
//

import Foundation

struct City: Decodable {
    let name: String
    let asciiname: String
    let latitude: String
    let longitude: String
}

struct Cities: Decodable {
    let cities: [City]
}
