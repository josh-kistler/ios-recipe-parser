//
//  Recipe Parser
//  Developed by Joshua Kistler and Justin Zheng
//  C323 Mobile App Development Final Project
//

import Foundation

class Recipe: Codable{
    var title: String
    var selected: Bool
    var ingredientText: String
    var instructionText: String
    var ingredients: [Ingredient]
    
    init(title: String, selected: Bool = false, ingredientText: String, instructionText: String = "", ingredients: [Ingredient] = []){
        self.title = title
        self.selected = selected
        self.ingredientText = ingredientText
        self.instructionText = instructionText
        self.ingredients = ingredients
    }
}
