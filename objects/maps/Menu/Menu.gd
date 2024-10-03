extends Node

var navigator: Navigator
var menus = {}  # Stores the menus as a dictionary (menu name -> Control)
var current_menu: Control

# Array of menu names
var menu_names = [
	"MainMenu",
	"MapMenu",
	"OptionsMenu",
	"PauseMenu"
]

# Base path where the menus are stored
var base_path = "res://objects/maps/Menu/"
var main_script = null

func _ready() -> void:
	main_script = self  # Set main_script to this instance for easy reference
	# Initialize the Navigator
	navigator = Navigator.new()
	
	# Resolve menu paths dynamically and load all menus
	for name in menu_names:
		var path = base_path + name + ".tscn"
		var scene = load(path).instantiate()  # Use instantiate() in Godot 4
		add_child(scene)
		scene.hide()  # Initially hide all menus
		menus[name] = scene  # Store the menu in the dictionary with its name as key
	navigator.initialize(menus)
	# Start by navigating to the MainMenu
	navigate("MainMenu")

# Function to navigate to any menu by its name
func navigate(menu_name: String) -> void:
	navigator.navigate_to(menu_name)

# Function to quit the game
func _quit_game() -> void:
	get_tree().quit()
