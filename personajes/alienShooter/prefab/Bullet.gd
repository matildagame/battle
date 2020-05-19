extends Area

var damage = 10;

export(float) var PROJECTILE_SPEED = 0.05;
var direction 

#onready var player = get_node("/root/WorldMap/Navigation/Matilda") # World Map 
onready var player = get_node("/root/Laberinto/Navigation/Matilda") # Laberinto

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var motion =  direction*PROJECTILE_SPEED
	translate(motion)


func _on_Timer_timeout():
	queue_free()
	pass


func _on_Bullet_body_entered(body):
#	print("bullet collision!")
	if(body==player):
		print("Matilda Reached!")
		player.take_damage(damage)
		#hacer daño
		queue_free()
