extends KinematicBody

# stats (Vida de los enemigos)
var curHp : int = 3
var maxHp : int = 3
 
# attacking
var damage : int = 1
var attackDist : float = 0.9
var attackRate : float = 2.67 # Update un animation time

# Chasing
var chaseRate : float = 0.1
var MaxDistance = 5
	#We move on to the next step.
 
# physics
var move_speed : float = 1.5

# Navmesh
var path = []
var path_ind = 0
var target = Vector3(0,1,0)
onready var nav = get_parent()
 
# vectors
var vel : Vector3 = Vector3()
 
# components
onready var chase_timer = get_node("ChaseTimer")
onready var attack_timer = get_node("AttackTimer")
onready var anim = get_node("AnimationPlayer")
onready var ray_cast = get_node("RayCast") 
onready var player = get_node("/root/WorldMap/Navigation/Matilda") 


# Aux variables
onready var target_reached = false
onready var chasing_area = false
onready var attacking_area = false
# Estados Animaciones
enum ESTADOS {parado,andando,atacando,muriendo,bailando,rotando_derecha,rotando_izquierda}
# Estado Inicial
var estado=ESTADOS.parado

func _ready():

	print(ray_cast)
	# set the timer wait time
	chase_timer.wait_time = chaseRate
	chase_timer.start()
	
	attack_timer.wait_time = attackRate

# TIMERS	
func _on_ChaseTimer_timeout():
	# Cada "Chase Rate" segundos, actulizamos la persecución
	
	# Vector pointing to player
	var EnemyToPlayer = player.translation - translation
	
	# If we are inside the detecting area...
	if EnemyToPlayer.length() < MaxDistance:
		# Update chasing area
		chasing_area = true;

		# If we are outside the attack area, get there (move_to)
		if translation.distance_to(player.translation) > attackDist:
			move_to(player.translation)
			target_reached=false
			
		elif translation.distance_to(player.translation) <= attackDist and target_reached==false:
			print("reached")
			target_reached=true;
			attack_timer.start()
	else:
#		print("Estas muy lejos, no te persigo...")
		chasing_area = false;
		pararse()
		
# TIMERS	
func _on_AttackTimer_timeout():
	# Ataque cuerpo a cuerpo
	# if we're within the attack distance - attack the player
#	if matilda is reached
	if target_reached:
		# Matila still alive...
		if player.curHp > 0:
			attack_timer.start()
			print("Mons: Toma!")
			player.take_damage(damage) # Take damage from Player
			
		else:
			# Matilda is dead, then any more attacks
			attack_timer.stop()
		
		
	
# called 60 times a second
func _physics_process (_delta):

	# get the distance from us to the player
	var dist = translation.distance_to(player.translation) # Matilda

	# if we're outside of the attack distance and within chasing area, chase after the player
	if !target_reached and chasing_area:
		andar()	
		# Navmesh Chasing
		if path_ind < path.size():
			# Navigation
			var move_vec = (path[path_ind] - global_transform.origin)
			if move_vec.length() < 0.1:
				path_ind += 1
			else:
				# Face the path
				look_at(path[path_ind],Vector3(0,1,0))
				rotation_degrees.y += 180 # Por algun motivo hay que rotarlo 180º
				# Move through the path
				move_and_slide(move_vec.normalized() * move_speed, Vector3(0, 1, 0))		
	
	# Target reached within chasing area
	elif target_reached:
	
#		# Look at player within the attack range
		look_at(player.translation,Vector3(0,1,0))
		rotation_degrees.y += 180 
		pararse()
		
		if player.curHp > 0:
			atacar()

		else:
#			print("Mons:ESTAS MUERTA")
			anim.play("default")
			estado=ESTADOS.parado	

#	print(anim.get_current_animation())
	
func move_to(target_pos):
	target = target_pos
	path = nav.get_simple_path(global_transform.origin, target_pos)
	path_ind = 0
		
func andar():
#	$Temporizador.start(andar_temporizador)
	estado=ESTADOS.andando
	anim.play("andar")

func pararse():
#	$Temporizador.start(andar_temporizador)
	
	if estado != ESTADOS.atacando:
		anim.play("default")
		estado=ESTADOS.parado

func atacar():
#	$Temporizador.start(andar_temporizador)
#	player.take_damage(damage) # Matilda
	estado=ESTADOS.atacando
	anim.play("atacar")
	

