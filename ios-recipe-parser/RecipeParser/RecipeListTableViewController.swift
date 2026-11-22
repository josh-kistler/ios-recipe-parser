//
//  Recipe Parser
//  Developed by Joshua Kistler and Justin Zheng
//  C323 Mobile App Development Final Project
//

import UIKit

class RecipeListTableViewController: UITableViewController {
    
    var appDelegate: AppDelegate?
    var recipeParserModel: RecipeParserModel?
    
    var recipeList: [Recipe] {
        recipeParserModel?.recipeList ?? []
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.appDelegate = UIApplication.shared.delegate as? AppDelegate
        self.recipeParserModel = self.appDelegate?.recipeParserModel
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        recipeParserModel?.loadRecipesFromCoreData( )
        tableView.reloadData( )
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipeList.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipeListIdentifier", for: indexPath)
        let recipe = recipeList[indexPath.row]
        
        cell.textLabel?.text = recipe.title
        cell.accessoryType = .none
        
        let checkButton = UIButton(type: .system)
        if recipe.selected == true {
            checkButton.setTitle("✓", for: .normal)
        } else {
            checkButton.setTitle("○", for: .normal)
        }
        
        checkButton.setTitleColor(.systemBlue, for: .normal)
        checkButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        checkButton.tag = indexPath.row
        checkButton.addTarget(self, action: #selector(toggleRecipeSelected(_:)), for: .touchUpInside)
        cell.accessoryView = checkButton
        return cell
    }
    @objc func toggleRecipeSelected(_ sender: UIButton){
        let row = sender.tag
        if row >= recipeList.count { return }
        let recipe = recipeList[row]
        recipe.selected.toggle()
        recipeParserModel?.updateRecipeSelectionInCoreData(title: recipe.title, selected: recipe.selected)
        let indexPath = IndexPath(row: row, section: 0)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? RecipeViewController,
           let indexPath = tableView.indexPathForSelectedRow {
            destination.recipeObject = recipeList[indexPath.row]
        }
    }
}
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
