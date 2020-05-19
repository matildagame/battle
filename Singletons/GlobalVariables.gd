extends Node

# Script to access global variables, e.g. Player Stats, global booleans...
# It also contains some functions to determine the game proccedures...

# Reference to Player
#onready var player = get_node("/root/WorldMap/Navigation/Matilda") # World Map 
onready var player = get_node("/root/Laberinto/Navigation/Matilda") # Laberinto

# -----------------------------------------------------------------------------
# GAME PARAMETERS
#------------------------------------------------------------------------------
var game_over = false
var win = false;

enum MODE { TIME_TRIAL, REACH_THE_GATE }
export(MODE) var mode = MODE.REACH_THE_GATE

# Time Trial
export var mins = 5

# -----------------------------------------------------------------------------
# ATTACKING PARAMETERS
#------------------------------------------------------------------------------
# Current target enemy object
onready var target_enemy = null
# Boleans used por Player when attacking/selecting enemies
onready var attack = false
onready var select = false
onready var move = false
onready var move_to_enemy = false

# ----------------------------------------------------------------------------
#------------------------------------------------------------------------------
func _ready():
#	timer = get_node("Timer")

	if mode == MODE.TIME_TRIAL:
		$Timer.wait_time = mins*60;
		$Timer.start()

# -----------------------------------------------------------------------------
# PROCCEDURE FUNCTIONS
#------------------------------------------------------------------------------
# Time Trial timeout
func _on_Timer_timeout():
	print("¡Game Over!")


# If the target is reached
func _on_Target_body_entered(body):
	if body == player:
		print("Mission accomplished!")
		GlobalVariables.win = true
