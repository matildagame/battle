extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var offset=2

# Called when the node enters the scene tree for the first time.
func _ready():
	var x=0
	var position=Vector3(0,0,0)
	
	for mesh in range(0,1):
		for texture_id in range (0,2):	
			for hair_id in range (0,2):		
				var playerID=str(mesh)+":"+str(texture_id)+":"+str(hair_id)
				position.x+=offset
				spawn(playerID,mesh,texture_id,hair_id,position)	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func spawn(user_id,mesh_id,texture_id,hair_id, position):
	var player=null
	
	if mesh_id == 0: # MATILDA
		# Preload player packaged scene and instancaite
#		var player = preload("res://personajes/Matilda/prefab/Matilda.tscn").instance() #Original Matilda
		player = preload("res://personajes/Matilda2.0/prefab/Matilda2.0.tscn").instance() # Matilda 2.0

		
		
	elif mesh_id == 1: # MATILDO
		# Preload player packaged scene and instancaite
		player = preload("res://personajes/Matildo2.0/prefab/Matildo2.0.tscn").instance() # Matildo 2.0
#		var player = preload("res://personajes/Matilda/prefab/Matilda.tscn").instance() #Original Matilda
		# Add player as a child of Laberinto/Navigation (Main scene)
		# OJO

	if player!=null:
	# Add specific features
		add_child(player)
			
		player.set_alias(user_id)
		player.set_hair_tone(hair_id)
		player.set_texture(texture_id)
		player.set_position(position)
		player.set_username("")


