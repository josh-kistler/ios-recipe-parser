//
//  Recipe Parser
//  Developed by Joshua Kistler and Justin Zheng
//  C323 Mobile App Development Final Project
//

import UIKit

class RecipeViewController: UIViewController {
    
    @IBOutlet var ingredientText: UITextView!
    @IBOutlet var instructionText: UITextView!
    
    var recipeObject: Recipe?
    var appDelegate: AppDelegate?
    var recipeParserModel: RecipeParserModel?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.appDelegate = UIApplication.shared.delegate as? AppDelegate
        self.recipeParserModel = self.appDelegate?.recipeParserModel
        
        if let recipe = recipeObject {
            ingredientText.text = recipe.ingredientText
            instructionText.text = recipe.instructionText
            self.title = recipe.title
        }
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func editRecipe(_ sender: Any) {
        guard let recipe = recipeObject else {
            return
        }
        let newIngredientText = ingredientText.text ?? ""
        let newInstructionText = instructionText.text ?? ""
        
        recipeParserModel?.updateRecipe(oldTitle: recipe.title, newIngredientText: newIngredientText, newInstructionText: newInstructionText)
        print("Recipe Updated")
    }
    
    @IBAction func deleteRecipe(_ sender: Any) {
        guard let recipe = recipeObject else { return }
        recipeParserModel?.deleteRecipe(title: recipe.title)
        navigationController?.popViewController(animated: true)
    }
}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

