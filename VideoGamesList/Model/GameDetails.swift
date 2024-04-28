//
//  GameDetails.swift
//  VideoGamesList
//
//  Created by Umut on 24.04.2024.
//

import UIKit

struct GameDetails: Codable {
    let id : Int
    let name : String
    let released : String
    let metacritic : Int
    let rating : Double
    let background_image : String
    let description_raw : String
}

