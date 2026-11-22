//
//  Recipe Parser
//  Developed by Joshua Kistler and Justin Zheng
//  C323 Mobile App Development Final Project
//

import UIKit

class GroceryListTableViewController: UITableViewController {
    
    var appDelegate: AppDelegate?
    var recipeParserModel: RecipeParserModel?
    var groceryIngredients: [Ingredient]{
        recipeParserModel?.groceryList.ingredients ?? []
    }
    
    var categoryOrder: [String] = []
    var categorizedIngredients: [String: [Ingredient]] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.appDelegate = UIApplication.shared.delegate as? AppDelegate
        self.recipeParserModel = self.appDelegate?.recipeParserModel

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        recipeParserModel?.loadRecipesFromCoreData()
        let selectedRecipes = recipeParserModel?.recipeList.filter{ $0.selected } ?? []
        _ = recipeParserModel?.createList(from: selectedRecipes)
        tableView.reloadData()
        buildCategories()
        tableView.reloadData()
    }
    
    func buildCategories() {
        categorizedIngredients.removeAll()
        categoryOrder.removeAll()
        
        for ingredient in groceryIngredients {
            let category = recipeParserModel?.getCategory(for: ingredient) ?? "Other"
            if categorizedIngredients[category] == nil {
                categorizedIngredients[category] = []
                categoryOrder.append(category)
            }
            categorizedIngredients[category]?.append(ingredient)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return categoryOrder.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let category = categoryOrder[section]
        // from selected recipes, get a set of ingredients and get size
        return categorizedIngredients[category]?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        return categoryOrder[section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groceryListIdentifier", for: indexPath)
        let category = categoryOrder[indexPath.section]
        guard let ingredient = categorizedIngredients[category]?[indexPath.row] else{
            return cell
        }
        var text = ""
        
        if ingredient.amount != "" {
            text += ingredient.amount + " "
        }
        
        if ingredient.unit != "" {
            text += ingredient.unit + " "
        }
        
        text += ingredient.name
        cell.textLabel?.text = text
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // for each cell, print each ingredient with optionally units and amount
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
