extends RigidBody2D

@export var friction = 0.1 

func _ready():
	pass  # Function body can be defined here if needed

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if state.get_contact_count() > 0:
		# Apply friction only when colliding
		state.linear_velocity *= friction
		state.angular_velocity *= friction
