extends KinematicBody

# Health points
export var maxHp : int = 3
var curHp : int = maxHp
# Energy points
export var maxEp : int = 3
var curEp : int = maxEp
# Ammunition points
export var maxAp : int = 3
var curAp : int = maxAp

# attacking
var damage : int = 1
var attackDist : float = 4
var attackRate : float = 1.5

# Navigation variables
var path = []
var path_ind = 0
const move_speed = 2
onready var nav = get_parent()

# Get components
onready var anim = get_node("AnimationPlayer")
onready var attack_timer = get_node("AttackTimer")

# Scene resources
const BULLET = preload("res://personajes/Matilda/prefab/MatildaBullet.tscn")
var BulletPosition # Where the bullet is gonna be instaciated

# Auxiliary scripts
var LineDrawer = preload("res://Personajes/Matilda/prefab/DrawLine3D.gd").new()

# Auxiliary vbles
var muerta=false;
# Estados Animaciones
enum ESTADOS {parado,andando,muriendo,bailando,rotando_derecha,rotando_izquierda}
# Estado Inicial
var estado=ESTADOS.parado

func _ready():

	BulletPosition = $Skeleton # Ojo, esto tiene que ser donde esté el arma!
	
	add_to_group("units")
	add_child(LineDrawer)
	
	attack_timer.wait_time = attackRate
	attack_timer.start()
	
func _on_AttackTimer_timeout():
	
	if(GlobalVariables.target_enemy!=null):
		var enemy_ray_cast = get_node(str(GlobalVariables.target_enemy.get_path()) + "/RayCast")
		# While attack distance is not reached or there is not direct vision, keep moving...
		if translation.distance_to(GlobalVariables.target_enemy.translation) <= attackDist and enemy_ray_cast.get_collider() == self:
			if GlobalVariables.target_enemy.curHp > 0:
				print("Matilda: Toma!")
				# Instanciate and fire a bullet
				fire()
			
func fire():
	var bullet = BULLET.instance()
	get_node("/root/").add_child(bullet)
	# Bullet Position se debera corresponder con el arma
	bullet.set_translation(BulletPosition.get_global_transform().origin)
	bullet.direction = BulletPosition.get_global_transform().basis.z
			
func _physics_process(delta):
	# Go through the path!	
	if GlobalVariables.move:
		if path_ind < path.size():
			andar()	
			var move_vec = (path[path_ind] - global_transform.origin)
			#---------------------------------------------------------------------------------
			# Normal Movement, Wherever, reach the path!
			#---------------------------------------------------------------------------------
			if !GlobalVariables.attack:
				if move_vec.length() < 0.1:
					path_ind += 1
				else:
					# Face the path
					look_at(path[path_ind],Vector3(0,1,0))
					rotation_degrees.y += 180 # Por algun motivo hay que rotarlo 180º
					# Moth through the path
					move_and_slide(move_vec.normalized() * move_speed, Vector3(0, 1, 0))
			#---------------------------------------------------------------------------------
			# Attacking Movement, Move towards till the attack distance is reached	
			#---------------------------------------------------------------------------------			
			else:
				# If there is an enemy selected to be attacked...
				if(GlobalVariables.target_enemy!=null):
					var enemy_ray_cast = get_node(str(GlobalVariables.target_enemy.get_path()) + "/RayCast")
					# While attack distance is not reached or there is not direct vision, keep moving...
					if translation.distance_to(GlobalVariables.target_enemy.translation) > attackDist or enemy_ray_cast.get_collider() != self:

						if move_vec.length() < 0.1:
							path_ind += 1	
						else:
							# Face the path
							look_at(path[path_ind],Vector3(0,1,0))
							rotation_degrees.y += 180 # Por algun motivo hay que rotarlo 180º
							# Moth through the path
							move_and_slide(move_vec.normalized() * move_speed, Vector3(0, 1, 0))
							
					elif translation.distance_to(GlobalVariables.target_enemy.translation) <= attackDist and enemy_ray_cast.get_collider() == self:
#						print("Te veo!")
						# Face the enemy
						look_at(GlobalVariables.target_enemy.translation,Vector3(0,1,0))
						rotation_degrees.y += 180 # Por algun motivo hay que rotarlo 180º	
						pararse()							
					else:
						pararse()	
										
		# Ha llegado a destino
		if path_ind == path.size() and !muerta:
			pararse()
			
	else:
		# Only selected...
		pararse()		
				
#		
func update_path(target_pos):
	path = nav.get_simple_path(global_transform.origin, target_pos,true)
	path_ind = 0

	var curve = Curve3D.new()	
	curve.bake_interval = 0.1
	# Set path poits to curve
	for i in range(len(path)):
		curve.add_point(path[i])
		# Draw Line
	# Create a proper curve from the path (¿Create Smoothed Version?)
	path = curve.get_baked_points()
		
# Funciones Interfaz
func take_damage(damageToTake):
#	print("Matilda: AU!!!")
	curHp -= damageToTake
	print("Healthy Point: " + str(curHp))
	# if our health reaches 0 - die
	if curHp <= 0:
		morir();
				
func take_health(healthToTake):
	if curHp < maxHp:
		curHp += healthToTake
	print("Healthy Point: " + str(curHp))	
	
func take_energy(energyToTake):
	if curEp < maxEp:
		curEp += energyToTake

func take_ammunition(ammunitionToTake):
	if curAp < maxAp:
		curAp += ammunitionToTake


# Funciones de Animacion
func morir():
	print("Matilda: Me muero :(")
	estado=ESTADOS.muriendo
	anim.play("morir-espaldas")
	muerta=true;
 
func andar():
	estado=ESTADOS.andando
	anim.play("andando")

func pararse():
	estado=ESTADOS.parado
	anim.play("default")


func draw_path(path):
	for i in range(len(path)):
		if i<len(path)-1:
			LineDrawer.DrawLine(path[i],path[i+1],Color(1, 0, 0),5)
	



