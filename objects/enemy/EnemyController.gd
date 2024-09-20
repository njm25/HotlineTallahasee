extends CharacterBody2D
class_name EnemyController
var player_in_area = null  # Variable to hold reference to the player
@export var turn_speed = 5.0  # Adjust this value to change how quickly the enemy turns

func _ready():
	var area = get_node("Area2D")
	area.connect("body_entered", self._on_area_body_entered)
	area.connect("body_exited", self._on_area_body_exited)

func _on_area_body_entered(body):
	if body is PlayerController:
		print("sum")
		player_in_area = body  # Store the player reference

func _on_area_body_exited(body):
	if body is PlayerController:
		player_in_area = null  # Clear the player reference when they exit the area

func _process(delta):
	if player_in_area:
		# Calculate the direction vector towards the player
		var direction = (player_in_area.global_position - global_position).normalized()
		# Calculate the angle to the player
		var target_angle = direction.angle()
		# Smoothly rotate towards the target angle
		rotation = lerp_angle(rotation, target_angle, turn_speed * delta)
