extends 'res://objects/maps/Map.gd'
func _ready() -> void: 
	create_camera()
	spawn_player()
	instance_player_gui()

func spawn_player():
	super.spawn_player()
	#if is_instance_valid(player_instance):
	#	player.invincibility = true
		
func _init() -> void:
	pass
