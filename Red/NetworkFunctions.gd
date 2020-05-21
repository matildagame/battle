extends Node

signal token_id_ready(token)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var matildaLib

# Called when the node enters the scene tree for the first time.
func _ready():
	var MatildaLib=preload("MatildaLib.gd")
	matildaLib=MatildaLib.new()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func init():
	###matildaLib.init()
	pass
	
func register(nombre,contrasenia,direccion_servidor,puerto_servidor):
	matildaLib.register(nombre,contrasenia,direccion_servidor,puerto_servidor)

func join(partida_id,token):
	matildaLib.join(partida_id,token)
