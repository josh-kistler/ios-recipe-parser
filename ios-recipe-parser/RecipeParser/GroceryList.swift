//
//  Recipe Parser
//  Developed by Joshua Kistler and Justin Zheng
//  C323 Mobile App Development Final Project
//

import Foundation

class GroceryList: Codable {
    var ingredients: [Ingredient]
    
    init(ingredients: [Ingredient] = []) {
        self.ingredients = ingredients
    }
}
