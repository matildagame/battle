extends Node

# Script to access global variables, e.g. Player Stats, global booleans...
# It also contains some functions to determine the game proccedures...

# Reference to Player
#onready var player = get_node("/root/WorldMap/Navigation/Matilda") # World Map 
#onready var player = get_node("/root/Laberinto/Navigation/Matilda") # Laberinto

# Event Signals
signal s_attack
signal s_select
signal s_move
signal s_win


# -----------------------------------------------------------------------------
# GAME PARAMETERS
#------------------------------------------------------------------------------
var game_over = false
var win = false;

enum MODE { TIME_TRIAL, REACH_THE_GATE }
export(MODE) var mode = MODE.REACH_THE_GATE

export var playerID=""
export var player_list={}

# Time Trial
export var mins = 5

# -----------------------------------------------------------------------------
# ATTACKING PARAMETERS
#------------------------------------------------------------------------------
export var automatic_attack = true;
# Current target enemy object
onready var target_enemy = null
# Boleans used por Player when attacking/selecting enemies
onready var attack = false
onready var select = false
onready var move = false
onready var move_to_enemy = false

#aux
onready var aux = false

# ----------------------------------------------------------------------------
#------------------------------------------------------------------------------
func _ready():
#	timer = get_node("Timer")
#	print(ee)

	if mode == MODE.TIME_TRIAL:
		$Timer.wait_time = mins*60;
		$Timer.start()

# -----------------------------------------------------------------------------
# PROCCEDURE FUNCTIONS
#------------------------------------------------------------------------------
# Time Trial timeout
func _on_Timer_timeout():
	print("¡Game Over!")
	
# Signal Handlers
func _on_Controller_s_move(target_pos):
	if(!attack and !select):
		print("Señal caputarada: s_move")
	pass

func _on_Controller_s_attack(target_pos):
	print("Señal caputarada: s_attack")

	pass # Replace with function body.

func _on_Controller_s_select(target_pos):
	print("Señal caputarada: s_select")
	pass # Replace with function body.

func _on_Controller_s_win():
	print("WIN!")
	# TODO: Through "Congratulations window..."

func set_players_list(list):
	player_list.clear()
		
	for player in list:
		var character={}
		character["playerID"]=player["playerID"]
		character["mesh_id"]=player["mesh"]
		character["texture_id"]=player["body_texture"]
		character["hair_id"]=player["hair_texture"]
		character["username"]=player["username"]
		character["position"]=null
				
		player_list[player["playerID"]]=player # Debería ser character
	
	pass
	
func set_players_positions(list):
	
	for id in list:
		player_list[id["playerID"]]["position"]=id["position"]
	
func start_level(level):
	
	########################
#	var character={}
#	character["playerID"]=playerID
#	character["username"]=playerID
#	character["mesh_id"]=0
#	character["texture_id"]=0
#	character["hair_id"]=0
#	character["position"]=Vector3(-1.578,0,-18.31)	
#
#	player_list[playerID]=character
	########################
		
	# Let's change the scene:
	get_tree().change_scene("res://Niveles/"+level)
	
