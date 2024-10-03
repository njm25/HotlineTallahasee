extends 'res://objects/modifier/Modifier.gd'
class_name WeaponAddMaxBounce

# Called when the node enters the scene tree for the first time.
func _init() -> void:
	
	var _add = {"max_bounces": 1}
	var _multiply = {}
	
	
	var _card_name = "Bouncer"
	var _type = "Weapon"
	
	self.card_name = _card_name
	self.type = _type
	self.add = _add
	self.multiply = _multiply
