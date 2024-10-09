extends Area2D
class_name SpawnRegion

@export var gremlin: bool = false
@export var gromlin: bool = false
@export var slugmo: bool = false
@export var spawn_enabled: bool = true

var game_manager: GameManager

# Function to determine if a specific enemy can spawn in this region
func can_spawn_enemy(enemy_type: String) -> bool:
	if not spawn_enabled:
		return false
	
	match enemy_type.to_lower():
		"gremlin":
			return gremlin
		"gromlin":
			return gromlin
		"slugmo":
			return slugmo
		_:
			return false

# Function to get a random position within the collision polygon
func get_random_position() -> Vector2:
	var collision_polygon = get_node("CollisionPolygon2D")
	if collision_polygon:
		return random_point_in_polygon(collision_polygon.polygon)
	return global_position

# Helper function to get a random point in a polygon
func random_point_in_polygon(polygon: PackedVector2Array) -> Vector2:
	var triangles = Geometry2D.triangulate_polygon(polygon)
	var total_area = 0
	var triangle_areas = []
	
	# Calculate the area of each triangle and the total area
	for i in range(0, triangles.size(), 3):
		var a = polygon[triangles[i]]
		var b = polygon[triangles[i + 1]]
		var c = polygon[triangles[i + 2]]
		var area = triangle_area(a, b, c)
		total_area += area
		triangle_areas.append(area)
	
	# Choose a random triangle, weighted by area
	var random_value = randf() * total_area
	var chosen_triangle = -1
	var accumulated_area = 0
	
	for i in range(triangle_areas.size()):
		accumulated_area += triangle_areas[i]
		if random_value <= accumulated_area:
			chosen_triangle = i
			break
	
	# Get a random point in the chosen triangle
	var a = polygon[triangles[chosen_triangle * 3]]
	var b = polygon[triangles[chosen_triangle * 3 + 1]]
	var c = polygon[triangles[chosen_triangle * 3 + 2]]
	
	var r1 = sqrt(randf())
	var r2 = randf()
	var point = (1 - r1) * a + r1 * (1 - r2) * b + r1 * r2 * c
	
	return point + global_position

# Helper function to calculate the area of a triangle
func triangle_area(a: Vector2, b: Vector2, c: Vector2) -> float:
	return abs((b.x - a.x) * (c.y - a.y) - (c.x - a.x) * (b.y - a.y)) / 2
