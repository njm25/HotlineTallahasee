extends CharacterBody2D

@export var speed = 250
@export var sprint_speed = 500
@export var friction = 0.1
@export var acceleration = 0.1
@export var push_force = 80
@export var no_friction = 0.2  # No friction when sneaking

func get_input():
	var input = Vector2()
	var current_speed = speed  # Default walking speed
	
	# Check for sprinting
	if Input.is_action_pressed('run'):
		current_speed = sprint_speed
	
	# Get directional input
	if Input.is_action_pressed('ui_right'):
		input.x += 1
	if Input.is_action_pressed('ui_left'):
		input.x -= 1
	if Input.is_action_pressed('ui_down'):
		input.y += 1
	if Input.is_action_pressed('ui_up'):
		input.y -= 1
	if Input.is_action_pressed('reload'):
		get_parent().player_inventory.current_weapon.reload()
	
	return input.normalized() * current_speed

func _process(delta):
	look_at(get_global_mouse_position())

func _physics_process(delta):
	var direction = get_input()
	var current_friction = friction  # Default friction

	# If sneaking, override friction to none
	if Input.is_action_pressed('sneak'):
		current_friction = no_friction
	
	if direction.length() > 0:
		velocity = velocity.lerp(direction, acceleration)
	else:
		velocity = velocity.lerp(Vector2.ZERO, current_friction)

	move_and_slide()
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody2D:
			c.get_collider().apply_central_impulse(-c.get_normal() * push_force)
func _on_area_2d_body_entered(body):
	print("Character entered the area")
