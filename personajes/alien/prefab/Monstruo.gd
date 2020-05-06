extends KinematicBody

# stats (Vida de los enemigos)
var curHp : int = 3
var maxHp : int = 3
 
# attacking
var damage : int = 1
var attackDist : float = 0.5
var attackRate : float = 2.67 # Update un animation time

# Chasing
var chaseRate : float = 0.1
var MaxDistance = 5
 
# physics
var move_speed : float = 1

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
onready var ray_cast = get_node("RayCastMonster") 
onready var player = get_node("/root/WorldMap/Navigation/Matilda") 

# Aux variables
# Areas
onready var target_detected = false
onready var target_reached = false
onready var chasing_area = false
onready var attacking_area = false

var EnemyToPlayer # Vector pointing to player
var AngleToPlayer # Angle to Player
var forward  # Monter's forward direction
var FOV = 90 # Monster's Filed Of Vision

# Estados Animaciones
enum ESTADOS {parado,andando,atacando,muriendo,bailando,rotando_derecha,rotando_izquierda}
# Estado Inicial
var estado=ESTADOS.parado

func _ready():

	# Configure ray_cast (Add collision exception to rayCast)
	ray_cast.add_exception($CollisionShape)
	
	# set the timers wait time
	chase_timer.wait_time = chaseRate
	chase_timer.start()
	attack_timer.wait_time = attackRate
	
# TIMERS	
func _on_AttackTimer_timeout():
	# Ataque cuerpo a cuerpo
	# if matilda currently reached
	if target_reached:
		# Matila still alive...
		if player.curHp > 0:
			attack_timer.start()
			print("Mons: Toma!")
			player.take_damage(damage)
			
		# Matila death
		else:
			# Matilda is dead, then any more attacks
			attack_timer.stop()	

# TIMERS	
func _on_ChaseTimer_timeout():
	# Every "Chase Rate" seconds, update chasing
	
	# Update navemesh path to player 
	update_path(player.translation)
	# Update Monter's forward direction
	forward = $Skeleton.get_global_transform().basis.z
	# Update Vector pointing to player
	EnemyToPlayer = player.translation - translation
	# Update angle regarding to the player
	AngleToPlayer = rad2deg(acos(EnemyToPlayer.normalized().dot(forward.normalized())))
	# Update raycast pointing vector to player
	ray_cast.cast_to = EnemyToPlayer


	# Nested Chasing process:
	# If monster is inside the detecting area...
	if EnemyToPlayer.length() < MaxDistance:
#		print("Dentro del de area de persecucion")
		# Update chasing area ojo donde poner esto
		chasing_area = true;
		# Check if the player is inside the field of view of the monster
		if AngleToPlayer < FOV:
#			print("Dentro del FOV")
			if ray_cast.is_colliding():
				if ray_cast.get_collider() == player:
#					print("Ahora no hay nada entre tu y yo!")
					target_detected = true;
				else:
					pass
#					target_detected = false;

	else:

		chasing_area = false;
		target_detected = false;
		pararse()
	
	# Once chasing parameters are up to date: Attacking paramenters	
	if target_detected:
		if translation.distance_to(player.translation) > attackDist:
#			print("Voy a por ti!")
			target_reached=false
		# Within attack area. Attack! Target reached
		elif translation.distance_to(player.translation) <= attackDist and !target_reached:
#			print("reached")
			target_reached=true;
			attack_timer.start()

# called 60 times a second
func _physics_process (_delta):
	
	if chasing_area and target_detected and !target_reached :
		andar()	
		# Navmesh Chasing
		if path_ind < path.size():
			# Navigation
			var move_vec = (path[path_ind] - global_transform.origin)
			if move_vec.length() < 0.1:
				path_ind += 1
			else:
				# Face the path
				$Skeleton.look_at(path[path_ind],Vector3(0,1,0))
				$Skeleton.rotation_degrees.y += 180 # ¿?
#				gun.look_at(path[path_ind],Vector3(0,1,0))
				# Move through the path
				move_and_slide(move_vec.normalized() * move_speed, Vector3(1, 0, 0))		
	
	# Target reached within chasing area
	elif target_reached:
		# Look at player within the attack range
		$Skeleton.look_at(player.translation,Vector3(0,1,0))
		$Skeleton.rotation_degrees.y += 180 # ¿?

		pararse()
		if player.curHp > 0:
			atacar()
			pass
		else:
			anim.play("default")
			estado=ESTADOS.parado	
		
	
func update_path(target_pos):
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

#	player.take_damage(damage) # Matilda
	estado=ESTADOS.atacando
	anim.play("atacar")
	
