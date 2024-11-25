extends Node2D

# Round base class
class_name Round
@export var dict_of_possible_enemies = {
	"Gremlin": 0.6,
	"Gromlin": 0.2,
	"Mangler": 0.2,
}
@export var spawning_rate: float = 1.0  # Time in seconds between spawns
@export var max_enemies: int = 10  # Maximum number of enemies for this round

func _init():
	pass
