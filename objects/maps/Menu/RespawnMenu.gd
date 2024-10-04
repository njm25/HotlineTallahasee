extends Control

var menu
var map
	

func _ready() -> void:
	menu = get_parent()  # Assuming Main.gd is the parent node
	map = menu.get_parent().get_parent()
		# Connect button signals
	$VBoxContainer/RespawnButton.pressed.connect(_on_respawn_button_pressed)
		

func _on_respawn_button_pressed() -> void:
	map.spawn_player()
	map._toggle_pause_menu() 
	pass
