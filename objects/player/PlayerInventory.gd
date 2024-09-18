extends Node2D
class_name PlayerInventory

@export var inventory_slots = []
@export var current_weapon: Weapon = Weapon.new()

# Called when the node enters the scene tree for the first time.
func _init() -> void:
	pass
	
	
func switch_weapon(weapon: Weapon, player):
	# Remove the old weapon if any

	# Assign the new weapon
	current_weapon = weapon
	
	# Add the weapon to the player as a child
	player.add_child(current_weapon, true)
	if(current_weapon is Pistol):
		print("weapon is pistol")
