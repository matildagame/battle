extends Area

# Script for detecting if the Player have reached the target

# Reference to target
onready var player = get_node("/root/Laberinto/Navigation/Matilda") 

# Called when the node enters the scene tree for the first time.
func _ready():
		# Connect win signal to the global node
	GlobalVariables.connect("s_win", GlobalVariables, "_on_Controller_s_win")

func _on_Target_body_entered(body):
	if body == player:
		GlobalVariables.win = true
		GlobalVariables.emit_signal("s_win")
