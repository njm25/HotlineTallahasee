extends Object
class_name playerInventory

@export var inventory_slots = []
@export var current_weapon = []

# Called when the node enters the scene tree for the first time.
func _init() -> void:
	pass # Replace with function body.
	
func switch_weapon(weapon: Weapon, player):
	# Remove the old weapon if any

	# Assign the new weapon
	current_weapon = weapon
	
	# Add the weapon to the player as a child
	player.add_child(current_weapon, true)
	
	player.move_child(player.get_child(0), player.get_child_count() -1 )
	print(player.get_children())
