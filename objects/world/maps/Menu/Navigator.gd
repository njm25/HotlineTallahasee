extends Node

class_name Navigator

var menus = {}  # The dictionary of all menus

# Initialize the navigator with the menu dictionary
func initialize(menus_dict: Dictionary) -> void:
	menus = menus_dict

# Function to navigate to a menu by its name
func navigate_to(menu_name: String) -> void:
	if menus.has(menu_name):
		var target_menu = menus[menu_name]
		for menu in menus.values():
			menu.hide()  # Hide all menus
		target_menu.show()  # Show only the selected menu
	else:
		print("Menu with name " + menu_name + " does not exist.")
