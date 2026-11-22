//
//  Recipe Parser
//  Developed by Joshua Kistler and Justin Zheng
//  C323 Mobile App Development Final Project
//

import Foundation
import NaturalLanguage
import CoreData
import UIKit
import UserNotifications

class RecipeParserModel {
    
    var recipeList: [Recipe] = []
    var groceryList = GroceryList()
    
    let knownUnits = [
        "tsp", "tbsp", "cups", "lb", "lbs", "oz", "gal", "g", "kg", "ml", "l", "clove", "cloves", "can", "cans"
    ]
    
    // constructors
    init() {
        loadRecipesFromCoreData()
    }
    init(recipeList: [Recipe], groceryList: GroceryList = GroceryList()) {
        self.recipeList = recipeList
        self.groceryList = groceryList
    }
    
    func parseIngredientText(_ text: String) -> [Ingredient] {
        var parsedIngredients: [Ingredient] = []
        
        let lines = text.components(separatedBy: .newlines)
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if trimmedLine.isEmpty {
                continue
            }
            
            let ingredient = parseLine(trimmedLine)
            parsedIngredients.append(ingredient)
        }
        return parsedIngredients
    }
    
    func parseLine(_ line: String) -> Ingredient {
        let parts = tokenizeLine(line)
        
        if parts.count == 0 {
            return Ingredient(name: "")
        }
        
        var amount = ""
        var unit = ""
        var name = ""
        
        if parts.count >= 1 {
            let firstPart = parts[0]
            
            if Double(firstPart) != nil || firstPart.contains("/") {
                amount = firstPart
            }
        }
        if amount != "" && parts.count >= 2 {
            let secondPart = parts[1].lowercased()
            
            if knownUnits.contains(secondPart) {
                unit = parts[1]
            }
        }
        
        var startIndex = 0
        
        if amount != "" {
            startIndex = 1
        }
        
        if unit != "" {
            startIndex = 2
        }
        
        if parts.count > startIndex {
            name = parts[startIndex...].joined(separator: " ")
        }
        
        return Ingredient(name: name, amount: amount, unit: unit)
    }
    
    func tokenizeLine(_ line: String) -> [String] {
        var tokens: [String] = []
        
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = line
        
        tokenizer.enumerateTokens(in: line.startIndex..<line.endIndex){
            tokenRange, _ in
            let token = String(line[tokenRange])
            tokens.append(token)
            return true
        }
        return tokens
    }
    
    func saveRecipe(title: String, ingredientText: String, instructionText: String = ""){
        let parsedIngredients = parseIngredientText(ingredientText)
        let newRecipe = Recipe(
            title: title,
            selected: false,
            ingredientText: ingredientText,
            instructionText: instructionText,
            ingredients: parsedIngredients
        )
        recipeList.append(newRecipe)
        saveRecipeToCoreData(recipe: newRecipe)
    }
    
    func createList(from recipes: [Recipe]) -> GroceryList{
        var groupedIngredients: [Ingredient] = []
        for recipe in recipes{
            for ingredient in recipe.ingredients {
                var foundMatch = false
                for existingIngredient in groupedIngredients {
                    if existingIngredient.name.lowercased(with: .current)
                        == ingredient.name.lowercased(with: .current)
                        && existingIngredient.unit.lowercased(with: .current)
                        == ingredient.unit.lowercased(with: .current){
                        if let oldAmount = Double(existingIngredient.amount),
                           let newAmount = Double(ingredient.amount){
                            existingIngredient.amount = "\(oldAmount + newAmount)"}
                        foundMatch = true
                        break}}
                if !foundMatch{
                    let newIngredient = Ingredient(name: ingredient.name,
                    amount: ingredient.amount,unit: ingredient.unit)
                    groupedIngredients.append(newIngredient)}}}
        groceryList = GroceryList(ingredients: groupedIngredients)
        return groceryList
}
    
    func setReminder(){
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                let content = UNMutableNotificationContent()
                content.title = "Recipe Parser Reminder"
                content.body = "Don't forget to check your grocery list"
                content.sound = .default
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
                
                let request = UNNotificationRequest(identifier: "groceryReminder", content: content, trigger: trigger)
                
                center.add(request){ error in
                    if error == nil {
                        print("Reminder scheduled")
                    }else {
                        print("Failed to schedule reminder")
                    }
                }
            } else{
                print("Notification access denied")
            }
        }
    }
    
    func getContext() -> NSManagedObjectContext? {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        return appDelegate?.persistentContainer.viewContext
    }
    
    func saveRecipeToCoreData(recipe: Recipe) {
        guard let context = getContext() else { return }
        
        guard let recipeEntity = NSEntityDescription.entity(forEntityName: "RecipeEntity", in: context) else { return }
        
        let recipeObject = NSManagedObject(entity: recipeEntity, insertInto: context)
        recipeObject.setValue(recipe.title, forKey: "title")
        recipeObject.setValue(recipe.ingredientText, forKey: "ingredientText")
        recipeObject.setValue(recipe.instructionText, forKey: "instructionText")
        recipeObject.setValue(recipe.selected, forKey: "selected")
        
        
        do {
            try context.save()
        } catch {
            print("Failed to save recipe to Core Data")
        }
    }
    
    func loadRecipesFromCoreData() {
        guard let context = getContext() else { return }
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName:"RecipeEntity")
        
        do {
            let results = try context.fetch(fetchRequest)
            recipeList.removeAll()
            
            for object in results {
                let title = object.value(forKey: "title") as? String ?? "Untitled Recipe"
                let ingredientText = object.value(forKey: "ingredientText") as? String ?? ""
                let instructionText = object.value(forKey: "instructionText") as? String ?? ""
                let selected = object.value(forKey: "selected") as? Bool ?? false
                let parsedingredients = parseIngredientText(ingredientText)
                let recipe = Recipe(
                    title: title,
                    selected: selected,
                    ingredientText:ingredientText,
                    instructionText: instructionText,
                    ingredients: parsedingredients
                )
                recipeList.append(recipe)
                
            }
        } catch {
            print("Failed to load recipes from Core Data")
        }
    }
    
    func updateRecipeSelectionInCoreData(title: String, selected: Bool){
        guard let context = getContext() else { return }
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName:"RecipeEntity")
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        
        do{
            let results = try context.fetch(fetchRequest)
            if let recipeObject = results.first {
                recipeObject.setValue(selected, forKey: "selected")
                try context.save()
            }
        }catch {
            print ("Failed to update recipe selection")
        }
    }
    
    func deleteRecipe(title: String) {
        recipeList.removeAll { $0.title == title }
        deleteRecipeFromCoreData(title: title)
    }
    
    func deleteRecipeFromCoreData(title: String){
        guard let context = getContext() else { return }
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName:"RecipeEntity")
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        
        do{
            let results = try context.fetch(fetchRequest)
            for object in results{
                context.delete(object)
            }
            try context.save()
        }catch {
            print("Failed to delete recipe from Core Data")
        }
    }
    func updateRecipe(oldTitle: String, newIngredientText: String, newInstructionText: String){
        if let recipe = recipeList.first(where: { $0.title == oldTitle }) {
            recipe.ingredientText = newIngredientText
            recipe.instructionText = newInstructionText
            recipe.ingredients = parseIngredientText(newIngredientText)
        }
        updateRecipeInCoreData(title: oldTitle, newIngredientText: newIngredientText, newInstructionText: newInstructionText)
    }
    
    func updateRecipeInCoreData(title: String, newIngredientText: String, newInstructionText: String){
        guard let context = getContext() else { return }
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName:"RecipeEntity")
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        
        do{
            let results = try context.fetch(fetchRequest)
            
            if let recipeObject = results.first {
                recipeObject.setValue(newIngredientText, forKey: "ingredientText")
                recipeObject.setValue(newInstructionText, forKey: "instructionText")
                try context.save()
            }
        }catch {
            print("Failed to update recipe in Core Data")
        }
    }
    
    func getCategory(for ingredient: Ingredient) -> String {
        let name = ingredient.name.lowercased()
        
        let categoryMap: [String: [String]] = [
            "Produce": [
                "apple", "banana", "orange", "lemon", "lime", "grape", "strawberry", "blueberry",
                "raspberry", "blackberry", "peach", "pear", "pineapple", "mango", "avocado",
                "tomato", "onion", "garlic", "potato", "sweet potato", "carrot", "celery",
                "cucumber", "lettuce", "spinach", "kale", "broccoli", "cauliflower", "pepper",
                "jalapeno", "zucchini", "squash", "corn", "cabbage", "mushroom", "cilantro",
                "parsley", "basil", "ginger"
            ],
            
            "Dairy and Eggs": [
                "milk", "butter", "cheese", "cream", "sour cream", "yogurt", "egg", "eggs",
                "half and half", "mozzarella", "cheddar", "parmesan", "cream cheese"
            ],
            
            "Meat and Seafood": [
                "chicken", "beef", "pork", "turkey", "bacon", "sausage", "ham", "steak",
                "ground beef", "ground turkey", "salmon", "tuna", "shrimp", "fish"
            ],
            
            "Bakery and Bread": [
                "bread", "bun", "roll", "bagel", "tortilla", "pita", "naan", "croissant"
            ],
            
            "Pasta Rice and Grains": [
                "rice", "pasta", "spaghetti", "macaroni", "noodle", "quinoa", "oats",
                "flour", "breadcrumb", "breadcrumbs", "cereal"
            ],
            
            "Canned and Jarred": [
                "beans", "black beans", "kidney beans", "chickpeas", "tomato sauce",
                "tomato paste", "salsa", "broth", "stock", "soup", "coconut milk"
            ],
            
            "Frozen": [
                "frozen peas", "frozen corn", "frozen berries", "frozen spinach",
                "ice cream", "frozen pizza"
            ],
            
            "Spices and Seasonings": [
                "salt", "pepper", "cumin", "paprika", "oregano", "basil", "thyme",
                "rosemary", "chili powder", "garlic powder", "onion powder", "cinnamon",
                "nutmeg", "red pepper flakes"
            ],
            
            "Oils and Condiments": [
                "oil", "olive oil", "vegetable oil", "vinegar", "soy sauce", "hot sauce",
                "mustard", "ketchup", "mayonnaise", "mayo", "honey", "maple syrup", "bbq sauce"
            ],
            
            "Baking": [
                "sugar", "brown sugar", "powdered sugar", "baking powder", "baking soda",
                "vanilla", "cocoa powder", "chocolate chips", "yeast"
            ],
            
            "Beverages": [
                "coffee", "tea", "juice", "soda", "water", "sparkling water"
            ]
        ]
        
        for (category, keywords) in categoryMap {
            for keyword in keywords {
                if name.contains(keyword) {
                    return category
                }
            }
        }
        
        return "Other"
    }
}

