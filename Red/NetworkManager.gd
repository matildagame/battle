extends Node

# Signals (events)
signal register_reply(playerID)
signal start_match(list)
signal players_list_update(list)

# Variables
var matildaLib
	
# Called when the node enters the scene tree for the first time.
func _ready():
#	MatildaLib=load("res://Red/MatildaLib.gd")
#	matildaLib=MatildaLib.new()


	matildaLib=get_node("/root/MatildaLib")
	
	matildaLib.connect("register_reply", self, "_on_register_reply")
	matildaLib.connect("players_list_update", self, "_on_players_list_update")
	matildaLib.connect("start_match", self, "_on_start_match")
	
func init():
	matildaLib.init()
	pass

func register(nombre,room,mesh,body_texture,hair_texture,direccion_servidor,puerto_servidor):
	return matildaLib.register(nombre,room,mesh,body_texture,hair_texture,direccion_servidor,puerto_servidor)

func _on_register_reply(playerID):
	emit_signal("register_reply",playerID)

func _on_players_list_update(list):
	emit_signal("players_list_update",list)

func _on_start_match(list):
	emit_signal("start_match",list)
		
func set_lib_port(lib_port):
	matildaLib.lib_puerto=lib_port
