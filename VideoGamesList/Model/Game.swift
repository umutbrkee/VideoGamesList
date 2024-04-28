//
//  Game.swift
//  VideoGamesList
//
//  Created by Umut on 24.04.2024.
//

import Foundation

struct Games: Decodable {
    let results : [Game]
}

struct Game: Decodable {
    static func == (lhs: Game, rhs: Game) -> Bool {
        return lhs.name == rhs.name
    }
    
    let id : Int
    let name : String
    let released : String
    let rating : Double
    let background_image : String
}

