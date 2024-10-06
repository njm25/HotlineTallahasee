extends Control

var player: PlayerController = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_labels()

# Sets the player instance to the GUI for data binding or interaction
func set_player(player_instance: PlayerController) -> void:
	player = player_instance

# Updates the GUI elements based on the player's current status
func update_labels() -> void:
	if not player:
		return

	var player_inventory = player.get_node("PlayerInventory")
	var current_weapon = player_inventory.current_weapon if player_inventory else null
	var ammo_label = get_node("AmmoLabel")
	var tool_gun_label = get_node("ToolGunLabel")
	var cards_label = get_node("CardsLabel")
	var health_label = get_node("HealthLabel")

	# Handle ammo display for weapons that have ammo
	if current_weapon and current_weapon is Weapon and current_weapon.has_ammo:
		ammo_label.text = str(current_weapon.current_ammo)
	else:
		ammo_label.text = ""

	# Handle ToolGun specific logic
	if current_weapon and current_weapon.get_gun_type() == "ToolGun":
		var mouse_pos = get_global_mouse_position()
		var offset = Vector2(0, -20)
		tool_gun_label.global_position = mouse_pos + offset
		tool_gun_label.text = current_weapon.get_selected_enemy_type()
		tool_gun_label.visible = true
	else:
		tool_gun_label.visible = false

	# Update CardsLabel text with card names from CardManager
	var card_manager = player.get_node("CardManager") if player else null
	var card_names = ""
	if card_manager:
		for card in card_manager.cards:
			card_names += card.card_name + "\n"
	cards_label.text = card_names

	# Update health label with player's current health
	health_label.text = str(player.health) if player else ""
