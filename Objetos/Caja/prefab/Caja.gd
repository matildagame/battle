extends Area

enum TIPO { MUNICION, VIDA, ENERGIA}
export(TIPO) var tipo = TIPO.VIDA
export var quantity = 1

# Referencia a matilda
onready var player = get_node("/root/WorldMap/Navigation/Matilda") 

# Called when the node enters the scene tree for the first time.
func _ready():
	if tipo == TIPO.VIDA:
		pass
		# TODO: MeshInstance, animation, etc..
	elif tipo == TIPO.MUNICION:
		pass
		# TODO: MeshInstance, animation, etc..
	elif tipo == TIPO.ENERGIA:
		pass
		# TODO: MeshInstance, animation, etc..
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_Caja_body_entered(body):
	#	print("bullet collision!")
	if(body==player):
		print("Caja entered")
		
		if tipo == TIPO.VIDA:
			# TODO:
			player.take_health(quantity)
		elif tipo == TIPO.MUNICION:
			player.take_ammunition(quantity)
			# TODO:
		elif tipo == TIPO.ENERGIA:
			player.take_energy(quantity)
			#TODO:
		
		# TODO: Animacion desaparer
		queue_free()
