extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var nombre="Matilda"

var identificador
var camera
var offset

# Called when the node enters the scene tree for the first time.
func _ready():
	identificador = $CanvasLayer/Identificador
	camera=get_node("../Camera")
	offset = Vector2(identificador.get_size().x/2, 0)
	identificador.text=nombre

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	identificador.set_global_position(camera.unproject_position(global_transform.origin) - offset)
