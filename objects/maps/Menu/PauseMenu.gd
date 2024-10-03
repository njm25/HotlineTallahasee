extends Control

var main_script

	

func _ready() -> void:
	main_script = get_parent()  # Assuming Main.gd is the parent node
		# Connect button signals
	$VBoxContainer/ResumeButton.pressed.connect(_on_resume_button_pressed)
	$VBoxContainer/OptionsButton.pressed.connect(_on_options_button_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_button_pressed)
	$VBoxContainer/MainMenuButton.pressed.connect(_on_main_menu_button_pressed)

func _on_resume_button_pressed() -> void:
	main_script.get_parent().get_parent()._toggle_pause_menu()  # Call the function to hide the menu
func _on_options_button_pressed() -> void:
	main_script.navigate("OptionsMenu")
	pass
func _on_quit_button_pressed() -> void:
	main_script._quit_game()
func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://objects/maps/Menu/Menu.tscn")
