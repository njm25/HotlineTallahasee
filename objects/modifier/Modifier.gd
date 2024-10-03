extends Node
class_name Modifier

var add := {}        # Dictionary to hold additive modifiers
var multiply := {}   # Dictionary to hold multiplicative modifiers
var type = ""
var card_name = ""

# Use _init for constructors with parameters
func _init(add = {}, multiply = {}):
	self.add = add
	self.multiply = multiply
	self.type = "None"
	self.card_name = "None"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
