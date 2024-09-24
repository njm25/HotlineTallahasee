extends 'res://objects/Modifier.gd'
class_name WeaponAddMaxBounce

# Called when the node enters the scene tree for the first time.
func _init() -> void:
	
	var _add = {"max_bounces": 1}
	var _multiply = {}
	
	self.add = _add
	self.multiply = _multiply
