extends Node2D
class_name Weapon


var _projectile = preload("res://objects/weapons/Projectile.tscn")

func _init() -> void:
	pass # Replace with function body.

func set_wep_sprite(weapon):
	var sprite = get_node(weapon)
	sprite.set_visible(true)
		
func clear_wep_sprite(weapon):
	var sprite = get_node(weapon)
	sprite.set_visible(false)
	
func reload():
	print("reloading")
	
	
func test_print():
	print("test print")
	
