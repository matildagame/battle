extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var global

# Called when the node enters the scene tree for the first time.
func _ready():
	
	global=$"/root/GlobalVariables"	
	
	# Let's put the players:
	spawn_the_players(global.player_list)

func spawn_the_players(players_list):
	
	for playerID in players_list:
		var local=false
		
		var player=players_list[playerID]
		if playerID==global.playerID:
			local=true
		
		spawn(player["playerID"],int(player["mesh"]),int(player["body_texture"]),\
			int(player["hair_texture"]),player["position"], player["username"],local)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



func spawn(user_id,mesh_id,texture_id,hair_id, position,username, local):
	var player=null
	
	if mesh_id == 0: # MATILDA
		# Preload player packaged scene and instancaite
#		var player = preload("res://personajes/Matilda/prefab/Matilda.tscn").instance() #Original Matilda
		player = preload("res://personajes/Matilda2.0/prefab/Matilda2.0.tscn").instance() # Matilda 2.0

		# Add player as a child of Laberinto/Navigation (Main scene)
		# OJO
		get_node("/root/Laberinto/Navigation").add_child(player) # Laberinto
		# Add specific features
#		player.set_alias(username)
#		player.set_hair_tone(hair_id)
#		player.set_texture(texture_id)
#		player.set_position(position)
#		player.set_playerID(user_id)
#		player.set_local(local)
		
	elif mesh_id == 1: # MATILDO
		# Preload player packaged scene and instancaite
		player = preload("res://personajes/Matildo2.0/prefab/Matildo2.0.tscn").instance() # Matildo 2.0
#		var player = preload("res://personajes/Matilda/prefab/Matilda.tscn").instance() #Original Matilda
		# Add player as a child of Laberinto/Navigation (Main scene)
		# OJO
		get_node("/root/Laberinto/Navigation").add_child(player) # Laberinto
		# Add specific features
#		player.set_alias(user_id)
#		player.set_hair_tone(hair_id)
#		player.set_texture(texture_id)
#		player.set_position(position)

	if player!=null:
		player.set_alias(username)
		player.set_hair_tone(hair_id)
		player.set_texture(texture_id)
		player.set_position(position)
		player.set_playerID(user_id)
		player.set_local(local)
