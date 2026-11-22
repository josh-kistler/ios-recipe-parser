# Recipe Parser for iOS

An iOS application that converts recipe ingredient lists into organized grocery lists.

Users can save recipes, select the recipes they plan to make, and automatically generate a combined grocery list from their ingredients. The app parses ingredient text into structured components, combines matching ingredients across recipes, organizes grocery items by category, and persists saved recipes between launches.

Built as a two-person iOS development project. I served as the **lead developer**.

## Features

### Recipe Parsing

Users can paste ingredient lists into the app and save them as recipes.

The parser processes each ingredient line into structured data containing:

- Amount
- Unit
- Ingredient name

For example:

```text
2 cups flour
1 tbsp olive oil
3 cloves garlic
```

is represented internally as individual `Ingredient` objects with separate amount, unit, and name properties.

### Natural Language Tokenization

Ingredient text is tokenized using Apple's **Natural Language** framework through `NLTokenizer`.

The parser uses the resulting tokens and a collection of recognized measurement units to separate quantities and units from ingredient names.

Recognized units include common measurements such as:

```text
tsp
tbsp
cups
lb
oz
g
kg
ml
clove
can
```

### Recipe Management

Saved recipes can be:

- Viewed
- Edited
- Deleted
- Selected for grocery-list generation

Duplicate recipe titles are automatically given unique names to avoid collisions.

### Grocery List Generation

Users select the recipes they plan to prepare.

The application then traverses the ingredients from those recipes and builds a combined grocery list.

When two ingredients have matching names and measurement units, their quantities are combined when both amounts can be represented numerically.

This allows multiple selected recipes to contribute to one consolidated shopping list.

### Grocery Categories

Generated ingredients are organized into grocery-store-style sections such as:

- Produce
- Dairy and Eggs
- Meat and Seafood
- Bakery and Bread
- Pasta, Rice, and Grains
- Canned and Jarred
- Frozen
- Spices and Seasonings
- Oils and Condiments
- Baking
- Beverages
- Other

Ingredient names are matched against category keywords before the grocery list is displayed.

### Persistent Storage

Recipes are persisted using **Core Data**.

Stored recipe data includes:

- Title
- Original ingredient text
- Instruction text
- Selection state

Recipes are loaded back from persistent storage when the application is opened, and changes to recipes or selection state are saved to Core Data.

### Local Notifications

The app integrates Apple's **UserNotifications** framework.

Users can select a date and time for a grocery-shopping reminder, and the application schedules a local notification after obtaining notification permission.

## Application Flow

```text
Paste Recipe
     │
     ▼
Parse Ingredient Text
     │
     ▼
Save Recipe
     │
     ▼
Core Data
     │
     ▼
Recipe Library
     │
     ├── View / Edit / Delete
     │
     └── Select Recipes
              │
              ▼
       Combine Ingredients
              │
              ▼
       Categorize Ingredients
              │
              ▼
        Grocery List
```

## Architecture

The project separates its data models, application logic, persistence behavior, and view controllers.

### `RecipeParserModel.swift`

Contains the application's primary business logic, including:

- Ingredient parsing
- Natural-language tokenization
- Grocery-list generation
- Ingredient categorization
- Core Data persistence
- Recipe updates and deletion
- Selection persistence
- Reminder scheduling

### `Recipe.swift`

Represents a saved recipe and stores its:

- Title
- Selection state
- Ingredient text
- Instruction text
- Parsed ingredients

### `Ingredient.swift`

Represents an individual parsed ingredient using:

```swift
name
amount
unit
```

### `GroceryList.swift`

Represents the collection of ingredients generated from selected recipes.

### View Controllers

The UIKit interface is divided across dedicated controllers for:

- Recipe input
- Saved recipe browsing
- Recipe viewing and editing
- Grocery-list display
- Reminder scheduling

## Technologies

- Swift
- UIKit
- Xcode
- Core Data
- NaturalLanguage
- `NLTokenizer`
- UserNotifications
- Storyboards
- MVC-style application structure

## Running the Project

1. Clone the repository.

```bash
git clone https://github.com/josh-kistler/ios-recipe-parser.git
```

2. Open:

```text
RecipeParser.xcodeproj
```

in Xcode.

3. Select an appropriate iPhone simulator or connected iOS device.

4. Build and run the application.

No external dependencies or third-party packages are required.

## Team Project

Recipe Parser was developed as a **two-person university software-development project**.

I served as the **lead developer** on the project.

The repository preserves the collaborative nature of the original project rather than presenting the application as individual work.

## What This Project Demonstrates

This project demonstrates the integration of several native iOS technologies into a complete application rather than an isolated programming exercise.

Key software-engineering concepts include:

- Transforming unstructured user input into structured application data
- Native iOS persistence
- Model and UI separation
- Multi-screen application state
- Data aggregation
- Text processing
- Local notifications
- CRUD operations
- Collaborative software development
