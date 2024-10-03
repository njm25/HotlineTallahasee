extends Control

# List of map names (can be extended later)
var maps = ["DevIsland", "ScaryHouse"]
var main_script

	

func _ready() -> void:
	main_script = get_parent()  # Assuming Main.gd is the parent node
		# Connect button signals
	$VBoxContainer/BackButton.pressed.connect(_on_back_button_pressed)
	create_map_list()

# Function to dynamically load map buttons
func create_map_list() -> void:
	var vbox = $VBoxContainer  # Make sure you have a VBoxContainer in your scene


	# Dynamically create buttons for each map
	for i in range(maps.size()):
		var button = Button.new()
		button.text = normalize_name(maps[i])
		button.pressed.connect(_on_map_button_pressed.bind(i))
		vbox.add_child(button)

# Normalize map names by adding spaces before camel-case words
func normalize_name(map_name: String) -> String:
	var normalized_name = ""
	for i in range(map_name.length()):
		var char = map_name[i]
		if char != char.to_lower() and i > 0:
			normalized_name += " "  # Add a space before uppercase letters
		normalized_name += char
	return normalized_name

# Function called when a map button is pressed
func _on_map_button_pressed(index: int) -> void:
	var selected_map = maps[index]
	var map_path = "res://objects/maps/" + selected_map + "/" + selected_map + ".tscn"
	get_tree().change_scene_to_file(map_path)# Function called when a map button is pressed

func _on_back_button_pressed() -> void:
	main_script.navigate("MainMenu")
	pass
