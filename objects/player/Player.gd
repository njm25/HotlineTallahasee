extends Node2D  # Ensure you're extending Node2D here for get_global_mouse_position to work

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var player_inventory = get_node("PlayerController/PlayerInventory")
	var player = get_node("PlayerController")
	var current_weapon = null
	var ammo_label = get_node("GUI/AmmoLabel")
	var tool_gun_label = get_node("GUI/ToolGunLabel")
	var cards_label = get_node("GUI/CardsLabel")  # New label to display cards
	var health_label = get_node("GUI/HealthLabel")  # New label to display cards
	
	if player_inventory:
			
		current_weapon = player_inventory.current_weapon
	# Ensure current weapon is a Weapon instance
	if current_weapon is Weapon:
		

		# Handle ammo display for weapons that have ammo
		if current_weapon.has_ammo:
			ammo_label.text = str(current_weapon.current_ammo)
		else:
			ammo_label.text = ""

		# Handle ToolGun specific logic
		if current_weapon.get_gun_type() == "ToolGun":
			# Get global mouse position
			var mouse_pos = get_global_mouse_position()  # This will now work as you're in Node2D
			
			# Apply manual offset to move the label up and left
			var offset = Vector2(0, -20)  # Adjust the offset values as needed
			tool_gun_label.global_position = mouse_pos + offset
			
			# Update the label text
			tool_gun_label.text = current_weapon.get_selected_enemy_type()
			
			# Ensure the label is visible and within bounds
			tool_gun_label.visible = true
		else:
			tool_gun_label.visible = false
	else:
		# Clear labels if no valid weapon is selected
		ammo_label.text = ""
		tool_gun_label.text = ""
		tool_gun_label.visible = false
	
	# Access the CardManager and update CardsLabel with card names
	var card_manager = get_node("PlayerController/CardManager")  # Assuming CardManager is a child of PlayerInventory
	var card_names = ""
	
	if card_manager:
		for card in card_manager.cards:
			card_names += card.card_name + "\n"  # Append each card's name to the label text
	var current_health = 0
	if player:
		current_health = player.health
	# Update the CardsLabel text
	cards_label.text = card_names
	health_label.text = str(current_health)
