extends Node

# Script to access global variables, e.g. Player Stats, global booleans...

# Boleans used por Player when attacking/selecting enemies
onready var attack = false
onready var select = false
onready var move = false
onready var move_to_enemy = false


# Current target enemy
onready var target_enemy = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
