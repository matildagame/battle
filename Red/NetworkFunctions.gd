extends Node

# Supossed to be emmited when an user has joined
signal token_id_ready(token)

# Variables
var matildaLib
# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect to signal manager
	connect("token_id_ready", self, "_on_token_id_ready")
	emit_signal("token_id_ready","jjramos:0:0:2")
	
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
	token = "jjramos:0:1:0"
	var IDs = token.split(":")
	var user_id = IDs[0]
	var gender_id  = int(IDs[1])
	var texture_id  =int(IDs[2])
	var hair_id = int(IDs[3])
	
	# TODO: Set position within a predefinited area
	var position = Vector3(-1.578,0.242,-18.31)
	
	# Spwan the player
	spawn(user_id,gender_id,texture_id,hair_id,position)

func spawn(user_id,gender_id,texture_id,hair_id, position):

	if gender_id == 0: # MATILDA
		# Preload player packaged scene and instancaite
#		var player = preload("res://personajes/Matilda/prefab/Matilda.tscn").instance() #Original Matilda
		var player = preload("res://personajes/Matilda2.0/prefab/Matilda2.0.tscn").instance() # Matilda 2.0

		# Add player as a child of Laberinto/Navigation (Main scene)
		# OJO
		get_node("/root/Laberinto/Navigation").add_child(player) # Laberinto
		# Add specific features
		player.set_alias(user_id)
		player.set_hair_tone(hair_id)
		player.set_texture(texture_id)
		player.set_position(position)
		
	elif gender_id == 1: # MATILDO
		# Preload player packaged scene and instancaite
#		var player = preload("res://personajes/Matildo2.0/prefab/Matildo2.0.tscn").instance() # Matildo 2.0
		var player = preload("res://personajes/Matilda/prefab/Matilda.tscn").instance() #Original Matilda
		# Add player as a child of Laberinto/Navigation (Main scene)
		# OJO
		get_node("/root/Laberinto/Navigation").add_child(player) # Laberinto
		# Add specific features
		player.set_alias(user_id)
		player.set_hair_tone(hair_id)
		player.set_texture(texture_id)
		player.set_position(position)
	
