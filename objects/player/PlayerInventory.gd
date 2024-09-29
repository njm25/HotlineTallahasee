extends Node2D
class_name PlayerInventory

var _weapon_scene = preload("res://objects/player/CurrentWeapon.tscn")

@export var inventory_slots := []  # Array to hold weapons
@export var current_weapon: Weapon = null
var current_weapon_index := -1  # -1 indicates no weapon equipped
var weapon_instance = null
var player = null  # Reference to the player node

# Store applied modifiers for weapons dynamically
var weapon_modifiers := {}  # Dictionary with weapon -> list of modifiers
var weapon_defaults := {}  # Store original weapon stats

func apply_modifier(modifier: Modifier):
	# Save andapply the modifier to all weapons
	for weapon in inventory_slots:
		# Initialize the modifiers and default storage if not done yet
		if weapon not in weapon_modifiers:
			weapon_modifiers[weapon] = []
		if weapon not in weapon_defaults:
			weapon_defaults[weapon] = {}
		
		# Save the modifier
		weapon_modifiers[weapon].append({
			"add": modifier.add.duplicate(),
			"multiply": modifier.multiply.duplicate()
		})
		
		# Apply additive modifiers dynamically to the weapon
		for key in modifier.add.keys():
			if not weapon_defaults[weapon].has(key):
				weapon_defaults[weapon][key] = weapon.get(key)  # Store the original value
			var old_value = weapon.get(key)
			weapon.set(key, old_value + modifier.add[key])
		
		# Apply multiplicative modifiers dynamically to the weapon
		for key in modifier.multiply.keys():
			if not weapon_defaults[weapon].has(key):
				weapon_defaults[weapon][key] = weapon.get(key)  # Store the original value for multiplication
			var old_value = weapon.get(key)
			weapon.set(key, old_value * modifier.multiply[key])

func remove_modifier(modifier: Modifier):
	# Remove the effects of the specified modifier from all weapons
	for weapon in inventory_slots:
		
		# Apply the inverse of additive modifiers
		for key in modifier.add.keys():
			if key in weapon:
				var old_value = weapon.get(key)
				weapon.set(key, old_value - modifier.add[key])
				
		# Apply the inverse of multiplicative modifiers
		for key in modifier.multiply.keys():
			if key in weapon:
				if modifier.multiply[key] != 0:
					var old_value = weapon.get(key)
					weapon.set(key, old_value / modifier.multiply[key])
				
		# Remove the modifier from the list if it exists
		if weapon in weapon_modifiers:
			var modifiers_to_remove = []
			for i in range(weapon_modifiers[weapon].size()):
				var stored_modifier = weapon_modifiers[weapon][i]
				if stored_modifier["add"] == modifier.add and stored_modifier["multiply"] == modifier.multiply:
					modifiers_to_remove.append(i)
			
			for i in modifiers_to_remove:
				weapon_modifiers[weapon].remove_at(i)
			

func restore_defaults():
	# Restore defaults for all weapons and clear the modifier lists
	for weapon in inventory_slots:
		restore_defaults_for_weapon(weapon)
		weapon_modifiers[weapon].clear()

func restore_defaults_for_weapon(weapon: Weapon):
	# Restore the default values for a specific weapon
	if weapon in weapon_defaults:
		for key in weapon_defaults[weapon]:
			weapon.set(key, weapon_defaults[weapon][key])

func apply_modifier_to_weapon(modifier: Modifier, weapon: Weapon):
	# Apply a modifier to a single weapon (used after removing a modifier)
	for key in modifier.add.keys():
		weapon.set(key, weapon.get(key) + modifier.add[key])
	for key in modifier.multiply.keys():
		weapon.set(key, weapon.get(key) * modifier.multiply[key])
		
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

	# Reapply modifiers to the weapon if any are saved
	if weapon in weapon_modifiers:
		for modifier in weapon_modifiers[weapon]:
			apply_modifier_to_weapon(modifier, weapon)

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
		weapon_instance.set_wep(current_weapon)

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
