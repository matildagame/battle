extends Area

# Script for detecting if the Player have reached the target

# Reference to target
onready var player = get_node("/root/WorldMap/Navigation/Matilda") 

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

#func _on_Target_body_entered(body):
#	if body == player:
#		print("Mission accomplished!")
#		GlobalVariables.win = true
