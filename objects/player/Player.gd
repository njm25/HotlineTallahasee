extends Node2D  # Ensure you're extending Node2D here for get_global_mouse_position to work

@export var health = 100
@export var player_inventory = []

# Called when the node enters the scene tree for the first time.
func _ready():
	var player_inventory = get_node("PlayerController/PlayerInventory")
	var player = get_node("PlayerController")
	var pistol = Pistol.new()
	var toolgun = ToolGun.new()
	var testgun = TestGun.new()
	
	player_inventory.create_weapon(pistol, player)
	player_inventory.create_weapon(toolgun, player)
	player_inventory.create_weapon(testgun, player)

func test_print():
	print("this works")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var player_inventory = get_node("PlayerController/PlayerInventory")
	var current_weapon = player_inventory.current_weapon
	var ammo_label = get_node("GUI/AmmoLabel")
	var tool_gun_label = get_node("GUI/ToolGunLabel")
	
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
