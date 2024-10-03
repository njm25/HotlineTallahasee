extends Control

# Reference to Main.gd script
var main_script

func _ready() -> void:
	main_script = get_parent()  # Assuming Main.gd is the parent node

	# Connect button signals
	$VBoxContainer/StartButton.pressed.connect(_on_start_game_pressed)
	$VBoxContainer/OptionsButton.pressed.connect(_on_options_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)

# Function called when "Start Game" is pressed
func _on_start_game_pressed() -> void:
	main_script.navigate("MapMenu")

# Function called when "Options" is pressed
func _on_options_pressed() -> void:
	main_script.navigate("OptionsMenu")

# Function called when "Quit Game" is pressed
func _on_quit_pressed() -> void:
	main_script._quit_game()
