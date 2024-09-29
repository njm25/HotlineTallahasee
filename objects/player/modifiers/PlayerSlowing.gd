extends 'res://objects/Modifier.gd'
class_name PlayerSlowing

# Initialize the slowing modifier
func _init() -> void:
	# Additive modifiers to slow down different parameters
	var _add = {
		"speed": -100,               # Decrease speed by 100
		"sprint_speed": -100,         # Decrease sprint speed
		"sneak_speed": -50,           # Decrease sneak speed
		"dash_speed": -200,           # Reduce dash speed
		"dash_duration": -0.1,        # Shorten dash duration
		"acceleration": -0.05,        # Decrease acceleration slightly
		"sliding_acceleration": -0.02, # Decrease sliding acceleration
		"sliding_deceleration": -0.002, # Decrease sliding deceleration
	}

	# Multiplicative modifiers to further slow down effects (e.g., reduce friction)
	var _multiply = {
		"default_friction": 0.8,  # Increase friction to slow down faster
		"no_friction": 0.8,       # Even when sneaking, increase friction
		"dash_friction": 0.8,     # Increase dash friction to slow down dash
		"push_force": 0.8,        # Reduce push force to make collisions weaker
	}

	var _card_name = "Slowdown"
	var _type = "Player"
	
	self.card_name = _card_name
	self.type = _type
	self.add = _add
	self.multiply = _multiply
