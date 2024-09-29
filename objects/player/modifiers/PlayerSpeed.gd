extends 'res://objects/Modifier.gd'
class_name PlayerSpeed

# Initialize the slowing modifier
func _init() -> void:
	# Additive modifiers to slow down different parameters
	var _add = {
		"speed": 100
	
	}

	var _multiply = {
	}

	self.add = _add
	self.multiply = _multiply
