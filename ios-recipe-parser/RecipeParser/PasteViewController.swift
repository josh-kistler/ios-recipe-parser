//
//  Recipe Parser
//  Developed by Joshua Kistler and Justin Zheng
//  C323 Mobile App Development Final Project
//

import UIKit

class PasteViewController: UIViewController {
    
    @IBOutlet var recipeTitle: UITextField!
    @IBOutlet var recipe: UITextView!
    
    var appDelegate: AppDelegate?
    var recipeParserModel: RecipeParserModel?
    var shouldResetAfterSave = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.appDelegate = UIApplication.shared.delegate as? AppDelegate
        self.recipeParserModel = self.appDelegate?.recipeParserModel
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if shouldResetAfterSave {
            self.recipeTitle.text = ""
            self.recipe.text = ""
            view.endEditing(true)
            shouldResetAfterSave = false
        }
    }
    @IBAction func saveRecipe(_ sender: Any) {
        let titleText = recipeTitle.text ?? ""
        let recipeText = recipe.text ?? ""
        
        if recipeText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            print("No recipe text entered.")
            return
        }
        
        let trimmedTitle = titleText.trimmingCharacters(in: .whitespacesAndNewlines)
        let baseTitle: String
        if trimmedTitle.isEmpty {
            baseTitle = "Untitled Recipe"
        }else {
            baseTitle = trimmedTitle
        }
        let finalTitle = makeUniqueTitle(baseTitle)
        recipeParserModel?.saveRecipe(title: finalTitle, ingredientText: recipeText)
        
        let parsedIngredients = recipeParserModel?.parseIngredientText(recipeText)
        
        if let unwrapParsedIngredients = parsedIngredients {
            print("Recipe saved.")
            for ingredient in unwrapParsedIngredients {
                print("amount: \(ingredient.amount),unit: \(ingredient.unit), name: \(ingredient.name)")
            }
        }
        
        reloadRecipeList()
        shouldResetAfterSave = true
        //recipeParserModel?.setReminder()
    }
    
    func reloadRecipeList() {
        guard let tabBarController = self.tabBarController, let vcs = tabBarController.viewControllers else{
            return
        }
        if let nav = vcs[1] as? UINavigationController, let rlvc = nav.topViewController as? RecipeListTableViewController {
            rlvc.tableView.reloadData()
        } else if let rlvc = vcs[1] as? RecipeListTableViewController {
            rlvc.tableView.reloadData()
        }
    }
    
    func makeUniqueTitle(_ baseTitle: String)-> String {
        guard let recipes = recipeParserModel?.recipeList else {
            return baseTitle
        }
        
        let existingTitles = recipes.map { $0.title }
        if !existingTitles.contains(baseTitle) {
            return baseTitle
        }
        
        var count = 2
        var newTitle = "\(baseTitle) \(count)"
        while existingTitles.contains(newTitle) {
            count += 1
            newTitle = "\(baseTitle) \(count)"
        }
        return newTitle
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
