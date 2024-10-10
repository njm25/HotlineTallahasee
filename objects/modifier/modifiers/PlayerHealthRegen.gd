extends 'res://objects/modifier/Modifier.gd'
class_name PlayerHealthRegen

# Define properties for the regen effect
var regen_amount: int = 1  # Amount of health to regenerate per tick
var regen_interval: float = 1.0  # Time interval between each regen tick
var max_health: int = 100  # Assume player's max health is 100, adjust as needed

# Timer for controlling the regen interval
var regen_timer: Timer = null

# Reference to the player (assumed that the modifier is applied to the player)
var player = null

func _init():
	# Set basic card name and type for the modifier
	self.card_name = "Health Regeneration"
	self.type = "Player"

# Called when the modifier is activated (e.g., player enters a power-up area)
func _ready():
	player = get_parent()  # Assume the modifier is a child of the player
	regen_timer = Timer.new()
	add_child(regen_timer)
	regen_timer.wait_time = regen_interval
	regen_timer.connect("timeout", Callable(self, "_on_regen_tick"))  # Correct connection
	regen_timer.start()

# Called on each regen tick
func _on_regen_tick():
	if player.health < max_health:
		player.health += regen_amount
		if player.health > max_health:
			player.health = max_health  # Cap health at max
		print("Regenerating health. Current health:", player.health)
	else:
		regen_timer.stop()  # Stop regeneration when health is full

# Called when the modifier is removed or expired
func _exit_tree():
	regen_timer.stop()
	regen_timer.queue_free()
