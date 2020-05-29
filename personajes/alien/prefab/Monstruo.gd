extends KinematicBody

# stats (Vida de los enemigos)

export var maxHp : int = 2
var curHp = maxHp
 
# attacking
var damage : int = 20
var attackDist : float = 0.5
var attackRate : float = 2.67 # Update un animation time

# Chasing
var chaseRate : float = 0.1
var MaxDistance = 5
 
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
onready var die_timer = get_node("DieTimer")
onready var anim = get_node("AnimationPlayer")
onready var ray_cast = get_node("RayCast") 
#onready var player = get_node("/root/WorldMap/Navigation/Matilda") # World Map 
onready var player = get_node("/root/Laberinto/Navigation/Matilda") # Laberinto

# Materials
const selected = preload("res://personajes/alien/material/AlienSeleccionado.material")
const not_selected = preload("res://personajes/alien/material/Alien.material")

# Aux variables
var muerto = false
# Areas
onready var target_detected = false
onready var target_reached = false
onready var chasing_area = false
onready var attacking_area = false

var EnemyToPlayer # Vector pointing to player
var AngleToPlayer # Angle to Player
var forward  # Monter's forward direction
var FOV = 180 # Monster's Filed Of Vision

# Estados Animaciones
enum ESTADOS {parado,andando,atacando,muriendo,bailando,rotando_derecha,rotando_izquierda}
# Estado Inicial
var estado=ESTADOS.parado

func _ready():
	# Connect signals to the global node
	GlobalVariables.connect("s_select", GlobalVariables, "_on_Controller_s_select")
	GlobalVariables.connect("s_attack", GlobalVariables, "_on_Controller_s_attack")	

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
	if target_reached and !muerto:
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
	
	if player==null:
		player = get_node("/root/Laberinto/Navigation/Matilda")
	
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
		if !muerto:
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
	
	if chasing_area and target_detected and !target_reached and !muerto:
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
	elif target_reached  and !muerto:
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
	
func morir_atras():

#	player.take_damage(damage) # Matilda
	estado=ESTADOS.muriendo
	anim.play("morir-atras")
	muerto = true;


# Funciones Interfaz
func take_damage(damageToTake):
#	print("Matilda: AU!!!")
	curHp -= damageToTake
	print("Healthy Point: " + str(curHp))
	# if our health reaches 0 - die
	if curHp <= 0:
		die_timer.start();
		morir_atras()



func _input(event):
	# General Input
	if event is InputEventMouseButton  and event.button_index == 1 and event.pressed:
		GlobalVariables.attack = false;
		GlobalVariables.select = false;
		GlobalVariables.target_enemy = null;
		
		$Skeleton/alienMesh.set_surface_material(0,not_selected)


func _on_Monstruo_input_event(camera, event, click_position, click_normal, shape_idx):
	# Select
	if event is InputEventMouseButton  and event.button_index == 1 and event.pressed and !event.doubleclick:
		print('Single click: Seleccionar', event)
		#TODO: Show monsters stats somehow through the HUD
		GlobalVariables.attack = false;
		GlobalVariables.select = true;
		GlobalVariables.move = false;
		
		# Update the target enemy (Monster has been selected!)
		GlobalVariables.target_enemy = get_node(get_path())
		
		$Skeleton/alienMesh.set_surface_material(0,selected)
		
		# Seleted, emit correspondig signal
		GlobalVariables.emit_signal("s_select")
		
	# Attack
	elif event is InputEventMouseButton and event.button_index == 1 and event.pressed  and  event.doubleclick :
		print('double click: Atacar ', event)
		GlobalVariables.attack = true;
		GlobalVariables.select = true;
		GlobalVariables.move = true;
		# Update the targer enemy  (Monster has been selected to be attacked!)
		GlobalVariables.target_enemy = get_node(get_path())
		
		$Skeleton/alienMesh.set_surface_material(0,selected)

		# Attacked, emit correspondig signal
		GlobalVariables.emit_signal("s_attack")
	
# Emitted when mouse pointer enters the monster's shape
func _on_Monstruo_mouse_entered():
	pass
#	print("Raton sobre Monstruo")

func _on_Monstruo_mouse_exited():
	pass
#	print("Raton sale Monstruo")


func _on_DieTimer_timeout():
	$CollisionShape.queue_free()


