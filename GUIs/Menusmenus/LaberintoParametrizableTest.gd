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
	
	#network.register_user(,)