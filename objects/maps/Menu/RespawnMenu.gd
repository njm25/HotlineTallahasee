extends Control

var menu

func _ready() -> void:
	menu = get_parent()  # Assuming Main.gd is the parent node
	# Connect button signals
	$VBoxContainer/RespawnButton.pressed.connect(_on_respawn_button_pressed)

	# Slowly modulate opacity of children on ready
	$VBoxContainer/Bar.modulate.a = 0.0
	$VBoxContainer/YouDied.modulate.a = 0.0

	var tween = get_tree().create_tween()
	tween.tween_property($VBoxContainer/Bar, "modulate:a", 1.0, 1.0)
	tween.tween_property($VBoxContainer/YouDied, "modulate:a", 1.0, 1.0)

func _on_respawn_button_pressed() -> void:
	get_tree().change_scene_to_file("res://objects/maps/Menu/Menu.tscn")
