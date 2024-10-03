extends Control

var main_script

	

func _ready() -> void:
	main_script = get_parent()  # Assuming Main.gd is the parent node
		# Connect button signals
	$VBoxContainer/BackButton.pressed.connect(_on_back_button_pressed)

func _on_back_button_pressed() -> void:
	main_script.back()
	pass
