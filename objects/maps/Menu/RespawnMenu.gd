extends Control

var menu
	

func _ready() -> void:
	menu = get_parent()  # Assuming Main.gd is the parent node
		# Connect button signals
	$VBoxContainer/RespawnButton.pressed.connect(_on_respawn_button_pressed)
		

func _on_respawn_button_pressed() -> void:
	get_tree().change_scene_to_file("res://objects/maps/Menu/Menu.tscn")
