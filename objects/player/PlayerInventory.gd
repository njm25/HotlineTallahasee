extends Node2D
class_name PlayerInventory

var _weapon_scene = preload("res://objects/weapons/Weapon.tscn")

@export var inventory_slots := []  # Array to hold weapons
@export var current_weapon: Weapon = null

var current_weapon_index := -1  # -1 indicates no weapon equipped
var weapon_instance = null
var player = null  # Reference to the player node

func _init() -> void:
	pass

func create_weapon(weapon: Weapon, _player):
	# Set the player reference if not already set
	if player == null:
		player = _player

	# Holster the current weapon (remove from scene)
	if weapon_instance != null:
		weapon_instance.queue_free()  # Remove the current weapon from the scene
		weapon_instance = null
		current_weapon = null
	
	# Add the weapon to the inventory if it's not already there
	if weapon not in inventory_slots:
		inventory_slots.append(weapon)

	# Set the current weapon index to the index of the new weapon
	current_weapon_index = inventory_slots.find(weapon)
	current_weapon = weapon

	# Update the weapon instance and equip the new weapon
	update_weapon()

func update_weapon():
	# Clear the current weapon sprite and instance before updating
	if weapon_instance != null:
		weapon_instance.queue_free()  # Free the current weapon instance
		weapon_instance = null

	if current_weapon_index == -1:
		# No weapon equipped
		current_weapon = null
	else:
		# Equip the current weapon
		current_weapon = inventory_slots[current_weapon_index]
		
		# Instantiate a new weapon instance and add it to the player
		weapon_instance = _weapon_scene.instantiate()
		player.add_child(weapon_instance)
		
		# Set the weapon's sprite or other properties as needed
		weapon_instance.set_wep_sprite(current_weapon.get_gun_type())

func next_weapon():
	var inventory_size = inventory_slots.size()
	if inventory_size == 0:
		# No weapons in inventory
		current_weapon_index = -1
	else:
		if current_weapon_index == -1:
			# Currently no weapon, move to first weapon
			current_weapon_index = 0
		elif current_weapon_index < inventory_size - 1:
			# Move to next weapon
			current_weapon_index += 1
		else:
			# Currently at last weapon, move to no weapon
			current_weapon_index = -1
	update_weapon()

func prev_weapon():
	var inventory_size = inventory_slots.size()
	if inventory_size == 0:
		# No weapons in inventory
		current_weapon_index = -1
	else:
		if current_weapon_index == -1:
			# Currently no weapon, move to last weapon
			current_weapon_index = inventory_size - 1
		elif current_weapon_index > 0:
			# Move to previous weapon
			current_weapon_index -= 1
		else:
			# Currently at first weapon, move to no weapon
			current_weapon_index = -1
	update_weapon()
