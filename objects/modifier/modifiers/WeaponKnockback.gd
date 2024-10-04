extends 'res://objects/modifier/Modifier.gd'
class_name Knocker

# Initialize the slowing modifier
func _init() -> void:
	# Additive modifiers to slow down different parameters
	var _add = {
		"knockback": 500
	
	}

	var _multiply = {
		"recoil_force": 2
	}

	var _card_name = "Knocker"
	var _type = "Weapon"
	
	self.card_name = _card_name
	self.type = _type
	self.add = _add
	self.multiply = _multiply
