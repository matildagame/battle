extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var network=$"/root/NetworkFunctions"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_pressed():
	var nombre=$Panel/VBoxContainer/HBoxContainer/Nombre.text
	var contrasenia=$Panel/VBoxContainer/HBoxContainer2/Contrasena.text
	var direccion_servidor=$Panel/VBoxContainer/HBoxContainer6/Servidor.text
	var puerto_servidor=str($Panel/VBoxContainer/HBoxContainer5/Puerto.text)
	var partida_id=$Panel/VBoxContainer/HBoxContainer3/partidaID.text
	
	network.init()
	network.register(nombre,contrasenia,direccion_servidor,puerto_servidor)
	
	yield(network.matildaLib,"registered_received")
	print("Registrado")
	
	#We ask for joining a match..
	network.join(partida_id,network.matildaLib.token_id)
	# And wait until the response is received. Is it ok to block the application?
	yield(network.matildaLib,"join_setup")
	print("En partida..")
