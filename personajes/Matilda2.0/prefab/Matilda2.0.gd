extends KinematicBody

# Name/id
export var alias : String="Matilda"

# if this is a remote character, its value is "false"
export var is_local: bool =false

# Signals: These are our events
signal created(object_,name_)

# Health points
export var maxHp : int = 100
var curHp : int = maxHp
# Energy points
export var maxEp : int = 100
var curEp : int = maxEp
# Ammunition points
export var maxAp : int = 100
var curAp : int = maxAp

# attacking
var damage : int = 1
var attackDist : float = 4
var attackRate : float = 1.5

# Navigation variables
var path = []
var path_ind = 0
var move_speed = 3
onready var nav = get_parent()

# Hair tone:
# enum HAIR_COLOR {violet,green,white,black}
export(int,"violet","yellow","cyan","grey","red","green") var hair_color

# Get components
onready var anim = get_node("AnimationPlayer")
onready var attack_timer = get_node("AttackTimer")
# HUD Components
# Healthy points components
onready var life_bar = get_node("HUD/TopStats/LifeBar/Count/Marco/Life")
onready var life_count = get_node("HUD/TopStats/LifeBar/Count/Background/Number")
const vida_20 = preload("res://GUIs/HUD/assets/barra_vida/vida_20.png")
const vida_40 = preload("res://GUIs/HUD/assets/barra_vida/vida_40.png")
const vida_60 = preload("res://GUIs/HUD/assets/barra_vida/vida_60.png")
const vida_80 = preload("res://GUIs/HUD/assets/barra_vida/vida_80.png")
const vida_100 = preload("res://GUIs/HUD/assets/barra_vida/vida_100.png")
# Energy points components
onready var energy_bar = get_node("HUD/TopStats/EnergyBar/Count/Marco/Energy")
onready var energy_count = get_node("HUD/TopStats/EnergyBar/Count/Background/Number")
const energia_20 = preload("res://GUIs/HUD/assets/barra_energia/energia_20.png")
const energia_40 = preload("res://GUIs/HUD/assets/barra_energia/energia_40.png")
const energia_60 = preload("res://GUIs/HUD/assets/barra_energia/energia_60.png")
const energia_80 = preload("res://GUIs/HUD/assets/barra_energia/energia_80.png")
const energia_100 = preload("res://GUIs/HUD/assets/barra_energia/energia_100.png")
# Ammunition points components
onready var ammuntion_count = get_node("HUD/TopStats/AmmunitionBar/Count/Background/Number")

# Scene resources
const BULLET = preload("res://personajes/Matilda2.0/prefab/MatildaBullet2.0.tscn")
var BulletPosition # Where the bullet is gonna be instaciated

# Auxiliary scripts
var LineDrawer = preload("res://Personajes/Matilda/prefab/DrawLine3D.gd").new()

# Auxiliary vbles
var muerta=false;
var correr=false;
var moving=false;
# Estados Animaciones
enum ESTADOS {parado,andando,corriendo,muriendo,bailando,rotando_derecha,rotando_izquierda}
# Estado Inicial
var estado=ESTADOS.parado


func _ready():
	
	init(vida_100,maxHp,energia_100,maxEp,maxAp,is_local)
	
	add_to_group("units")
	add_child(LineDrawer)
	
	attack_timer.wait_time = attackRate
	attack_timer.start()
	BulletPosition = $Skeleton # Ojo, esto tiene que ser donde esté el arma!


# Just ot instantiate and change parameters afterwards:
func init(vida_100_, maxHP_ ,energia_100_,maxEp_,maxAp_,is_local_):
	# Set Inicial Stats
	# Health
	life_bar.set_texture(vida_100_)
	life_count.text = str(maxHP_)
	# Energy
	energy_bar.set_texture(energia_100_)
	energy_count.text = str(maxEp_)
	# Ammunition
	energy_count.text = str(maxAp_)
	
	is_local=is_local_
	if is_local:
		# Let's say it's happening
		emit_signal("created",self,alias)

#-------------------------------------------------------------------------------
# SPAWN FUNCTIONS
#-------------------------------------------------------------------------------
# set the body texture, from a set of base materials
# set the player alias, taken from the token

func spawn(id_alias,id_gender,id,tone,id_texure):
	pass

# Set gender (Meshes,)
func set_gender(id_gender):
	# O: Female Mesh
	# 1: Male Mesh	
	var mesh=["idle.dae"]
#	# TODO: Add meshes
#	var matilda_mesh = load("res://personajes/Matilda/modelo/matilda.mesh")
#	print(matilda_mesh)
#	$Skeleton/Cuerpo.mesh = matilda_mesh
#	$Skeleton/Cuerpo.set_surface_material(0, load("res://personajes/Matilda/modelo/Material_001.material"))

	pass
	
func set_alias(id_alias):
	alias = id_alias
	$MejorIdentificador.nombre = id_alias
	print(alias)
	
# set the hair color, from a set of base materials
func set_hair_tone(id_tone):
	var hair_texture=["pelo_principal.jpg",
	"pelo1.jpg",
	"pelo2.jpg"]
	
	print($Skeleton/Pelo)
	if id_tone >= 0 and id_tone <= 2:
		$Skeleton/Pelo.get_surface_material(0).albedo_texture=load("res://personajes/Matilda2.0/materiales/"+hair_texture[id_tone])

func set_texture(id_texture):
	var texture=["base.jpg",
				 "base_diferencia.jpg",
				 "base_luz_suave.jpg"]
	# TODO: Add texutres
	if id_texture >= 0 and id_texture <= 2:
		$Skeleton/Cuerpo.get_surface_material(0).albedo_texture=load("res://personajes/Matilda2.0/materiales/"+texture[id_texture])

# set postion within the world
func set_position(position):
	translation = position
	
#-------------------------------------------------------------------------------
# #
#-------------------------------------------------------------------------------

# Attack timer
func _on_AttackTimer_timeout():
	
	if(GlobalVariables.target_enemy!=null):
		var enemy_ray_cast = get_node(str(GlobalVariables.target_enemy.get_path()) + "/RayCast")
		# While attack distance is not reached or there is not direct vision, keep moving...
		if translation.distance_to(GlobalVariables.target_enemy.translation) <= attackDist and enemy_ray_cast.get_collider() == self:
			if GlobalVariables.target_enemy.curHp > 0:
				print("Matilda: Toma!")
				# Instanciate and fire a bullet
				if curAp > 0:
					fire()
					curAp-=1;
					ammuntion_count.text = str(curAp)
					
			
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
			if correr:
				correr()
				move_speed = 5
			else:
				andar()
				move_speed = 2
					
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
						moving = false;							
					else:
						pararse()
						moving = false;	
										
		# Ha llegado a destino
		if path_ind == path.size() and !muerta:
			pararse()
			moving = false;
			
	else:
		# Only selected...
		pararse()	
		moving = false;	
				
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
	
	if curHp == 100:
		life_bar.set_texture(vida_100)
		life_count.text = str(curHp)
	elif curHp >= 80 and curHp < 100:
		life_bar.set_texture(vida_80)
		life_count.text = str(curHp)
	elif curHp >= 60 and curHp < 80:
		life_bar.set_texture(vida_60)
		life_count.text = str(curHp)	
	elif curHp >= 40 and curHp < 60:
		life_bar.set_texture(vida_40)
		life_count.text = str(curHp)
	elif curHp >= 20 and curHp < 40:
		life_bar.set_texture(vida_20)
		life_count.text = str(curHp)
	elif curHp < 20:
		life_bar.set_texture(null)
		life_count.text = str(curHp)
		if(curHp<0):
			life_count.text = '0'
	
	if curHp <= 0:
		morir();
		muerta = true;
				
func take_health(healthToTake):
	if curHp < maxHp:
		curHp += healthToTake
	print("Healthy Point: " + str(curHp))	
	
	# Update HUD
	if curHp >= 100:
		life_bar.set_texture(vida_100)
		life_count.text = str(curHp)
	elif curHp >= 80 and curHp < 100:
		life_bar.set_texture(vida_80)
		life_count.text = str(curHp)
	elif curHp >= 60 and curHp < 80:
		life_bar.set_texture(vida_60)
		life_count.text = str(curHp)	
	elif curHp >= 40 and curHp < 60:
		life_bar.set_texture(vida_40)
		life_count.text = str(curHp)
	elif curHp >= 20 and curHp < 40:
		life_bar.set_texture(vida_20)
		life_count.text = str(curHp)
	elif curHp < 20:
		life_bar.set_texture(null)
		life_count.text = str(curHp)

	
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
	
func correr():
	estado=ESTADOS.corriendo
	anim.play("corriendo")

func pararse():
	estado=ESTADOS.parado
	anim.play("default")


func draw_path(path_):
	for i in range(len(path_)):
		if i<len(path_)-1:
			LineDrawer.DrawLine(path_[i],path_[i+1],Color(1, 0, 0),5)
			
#Events
func _input(event):
#	if !moving:
#		# Walk
#		if event is InputEventMouseButton  and event.button_index == 1 and event.pressed and !event.doubleclick:
#			print("andar")
#			correr = false;
#			moving = true;
#		# Run
#		elif event is InputEventMouseButton and event.button_index == 1 and event.pressed  and  event.doubleclick :
#			print("correr")
#			correr = true;
#			moving = true;

	if event is InputEventMouseButton  and event.button_index == 1 and event.pressed and !event.doubleclick:
		if !moving:
			correr = false;
			moving = true;
	# Run
	elif event is InputEventMouseButton and event.button_index == 1 and event.pressed  and  event.doubleclick :
		correr = true;
		moving = true;		
