extends Node

# Supossed to be emmited when an user has joined
signal token_id_ready(token)

# Resources for the spwan procedure, texture, meshes...



var matildaLib

# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect to signal manager
	connect("token_id_ready", self, "_on_token_id_ready")
	
	var MatildaLib=preload("MatildaLib.gd")
	matildaLib=MatildaLib.new()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func init():
	matildaLib.init()
	pass
	
func register(nombre,contrasenia,direccion_servidor,puerto_servidor):
	matildaLib.register(nombre,contrasenia,direccion_servidor,puerto_servidor)

func join(partida_id,token):
	matildaLib.join(partida_id,token)

# User has joined, needs to be spwaned
func _on_token_id_ready(token):
	# Extract Information from the token (e.g. "user:model:texture:haircolor" -> "jjramos:0:1:3")
	
	# Example given
	token = "jjramos:0:1:3"
	var IDs = token.split(":")
	var user_id = int(IDs[0])
	var gender_id  = int(IDs[1])
	var texture_id  =int(IDs[2])
	var hair_id = int(IDs[3])
	
	# TODO:Set position
	var position = Vector3(0,0,0)
	
	# Spwan the player
	spawn(user_id,gender_id,texture_id,hair_id,position)


func spawn(user_id,gender_id,texture_id,hair_id, position):
	# Instanciate player
	var player = preload("res://personajes/Matilda/prefab/Matilda.tscn")
	# Add specific features
	player.set_gender(gender_id)
	player.set_hair_tone(hair_id)
	player.set_texture(texture_id)
	player.set_position(position)
	
	#TODO:
	# Add player as a child of Laberinto/Navigation (Main scene)
	
	pass
	
