extends Sprite3D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var identificador="Matilda"

# Called when the node enters the scene tree for the first time.
func _ready():
	init(identificador)

func init(identificador_):
	identificador=identificador_
	$Viewport/Label.text=identificador

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
