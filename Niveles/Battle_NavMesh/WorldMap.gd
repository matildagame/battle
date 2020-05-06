extends Spatial

onready var navmesh = get_node("Navigation/NavigationMeshInstance")

func _ready():
	navmesh.enabled=true;
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
