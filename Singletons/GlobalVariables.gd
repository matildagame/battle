extends Node

# Script to access global variables, e.g. Player Stats, global booleans...
# It also contains some functions to determine the game proccedures...

# Reference to Player
#onready var player = get_node("/root/WorldMap/Navigation/Matilda") # World Map 
onready var player = get_node("/root/Laberinto/Navigation/Matilda") # Laberinto

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
func _on_Controller_s_attack():
	print("Señal caputarada: s_attack")
	print(attack)

	pass # Replace with function body.

func _on_Controller_s_select():
	print("Señal caputarada: s_select")
	pass # Replace with function body.


func _on_Controller_s_move():
#	print("Señal caputarada: s_move")
	pass
	

func _on_Controller_s_win():
	print("WIN!")

