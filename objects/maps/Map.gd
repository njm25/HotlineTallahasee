extends Node2D
class_name Map

var player_scene = preload("res://objects/player/Player.tscn")
var player_instance
var player
var player_is_dead: bool = false

var menu_scene = preload("res://objects/maps/Menu/Menu.tscn")  # Preload the menu scene
var menu_instance
var canvas_layer_instance  # This will store the dynamically created CanvasLayer

var camera_scene = preload("res://objects/world/Camera/Camera.tscn")  # Preload the menu scene
var camera_instance

var player_gui: PackedScene = preload("res://objects/player/PlayerGUI.tscn")
var player_gui_instance = null
# Signal for respawn and death
var gui_layer_instance

signal player_respawned(new_player)
signal player_died

func _ready() -> void:
	pass

func start_game():
	create_camera()
	spawn_player()
	create_game_manager(player)
	instance_player_gui()

func instance_player_gui():
	# Create a new CanvasLayer dynamically if it doesn't exist
	if not gui_layer_instance:
		gui_layer_instance = CanvasLayer.new()
		add_child(gui_layer_instance)

	# Remove all children from the CanvasLayer (including any previous GUI elements)
	for child in gui_layer_instance.get_children():
		child.queue_free()

	# Instantiate the Player GUI and add it to the CanvasLayer
	player_gui_instance = player_gui.instantiate()
	gui_layer_instance.add_child(player_gui_instance)
	player_gui_instance.set_player(player)


func create_camera():
	camera_instance = camera_scene.instantiate()
	add_child(camera_instance)

func create_game_manager(player: PlayerController):
	var game_manager = load("res://objects/maps/GameManager.tscn").instantiate()
	game_manager.player = player
	add_child(game_manager)

func spawn_player():
	player_instance = player_scene.instantiate()
	add_child(player_instance)
	player = player_instance.get_node("Player/PlayerController")

	# Connect to the death signal from the player
	player.connect("player_died", self._on_player_died)

	# Emit signal when player respawns
	emit_signal("player_respawned", player)

# Called when the player dies
func _on_player_died():
	if is_instance_valid(player_instance):
		player_instance.queue_free()
		player = null
		player_instance = null
		show_respawn_menu()

func show_respawn_menu():
	# Create a new CanvasLayer if it doesn't exist
	if not canvas_layer_instance:
		canvas_layer_instance = CanvasLayer.new()
		add_child(canvas_layer_instance)

	# Remove all children from the CanvasLayer (including PauseMenu if present)
	for child in canvas_layer_instance.get_children():
		child.queue_free()

	# Instantiate the RespawnMenu and add it to the CanvasLayer
	menu_instance = menu_scene.instantiate()  # Instantiate the menu scene
	canvas_layer_instance.add_child(menu_instance)

	# Navigate to the RespawnMenu control in the Menu scene
	var respawn_menu = menu_instance.navigate("RespawnMenu")
	if respawn_menu:
		respawn_menu.grab_focus()  # Ensure the respawn menu control gets focus

# Detect input for escape key
func _input(event):
	if event.is_action_pressed("ui_cancel"):  # Escape key is mapped to "ui_cancel" in InputMap
		if player:
			_toggle_pause_menu()

# Toggle the pause menu visibility
func _toggle_pause_menu():
	if menu_instance and canvas_layer_instance:
		# If the menu is already open, remove it and the CanvasLayer
		canvas_layer_instance.queue_free()  # Remove the canvas layer and the menu
		canvas_layer_instance = null
		menu_instance = null

		# Re-enable player input when menu is closed
		if player:
			player.is_paused = false
	else:
		# Create a new CanvasLayer dynamically if it doesn't exist
		if not canvas_layer_instance:
			canvas_layer_instance = CanvasLayer.new()  # Create the CanvasLayer
			add_child(canvas_layer_instance)  # Add it as a child to the current scene

		menu_instance = menu_scene.instantiate()  # Instantiate the menu scene
		canvas_layer_instance.add_child(menu_instance)  # Add the menu to the CanvasLayer

		# Navigate to the PauseMenu control in the Menu scene
		var pause_menu = menu_instance.navigate("PauseMenu")
		if pause_menu:
			pause_menu.grab_focus()  # Ensure the pause menu control gets focus

		# Disable player input while the menu is active
		if player:
			player.is_paused = true
