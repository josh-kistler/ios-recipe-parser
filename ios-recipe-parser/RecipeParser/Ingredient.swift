//
//  Recipe Parser
//  Developed by Joshua Kistler and Justin Zheng
//  C323 Mobile App Development Final Project
//

import Foundation

class Ingredient: Codable {
    var name: String
    var amount: String
    var unit: String
    
    init(name: String, amount: String = "", unit: String = ""){
        self.name = name
        self.amount = amount
        self.unit = unit
    }
}
