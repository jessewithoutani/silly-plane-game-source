extends Node3D

@onready var raycast : RayCast3D = $RayCast3D
@onready var collider = $Plane/StaticBody3D

var tree = preload("res://prefabs/tree.tscn")
const RADIUS = 500

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(5000):
		var x = randf_range(-RADIUS, RADIUS)
		var y = randf_range(-RADIUS, RADIUS)
		
		raycast.position.x = x
		raycast.position.z = y
		raycast.force_raycast_update()
		
		if raycast.is_colliding() and raycast.get_collider() == collider:
			var new_tree : Node3D = tree.instantiate()
			new_tree.position = raycast.get_collision_point()
			add_child(new_tree)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
