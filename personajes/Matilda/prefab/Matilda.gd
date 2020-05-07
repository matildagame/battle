extends KinematicBody

var LineDrawer = preload("res://Personajes/Matilda/prefab/DrawLine3D.gd").new()

# Health points
export var maxHp : int = 3
var curHp : int = maxHp
# Energy points
export var maxEp : int = 3
var curEp : int = maxEp
# Ammunition points
export var maxAp : int = 3
var curAp : int = maxAp

var path = []
var path_ind = 0
const move_speed = 2
onready var nav = get_parent()

# Get components
onready var anim = get_node("AnimationPlayer")

# Auxiliary vbles
var muerta=false;
# Estados Animaciones
enum ESTADOS {parado,andando,muriendo,bailando,rotando_derecha,rotando_izquierda}
# Estado Inicial
var estado=ESTADOS.parado

func _ready():
	add_to_group("units")
	add_child(LineDrawer)
			
func _physics_process(delta):
	
	# Esta yendo
	if path_ind < path.size():
		var move_vec = (path[path_ind] - global_transform.origin)
		
		if move_vec.length() < 0.1:
			path_ind += 1
				
		else:
			# Face the path
			look_at(path[path_ind],Vector3(0,1,0))
			rotation_degrees.y += 180 # Por algun motivo hay que rotarlo 180º
			# Moth through the path
			move_and_slide(move_vec.normalized() * move_speed, Vector3(0, 1, 0))
			
			
	# Ha llegado a destino
	if path_ind == path.size() and !muerta:
		pararse()
#		
func move_to(target_pos):
	path = nav.get_simple_path(global_transform.origin, target_pos,true)
	path_ind = 0
	andar()	
	
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
		curEp =+ energyToTake

func take_ammunition(ammunitionToTake):
	if curAp < maxAp:
		curAp =+ ammunitionToTake				


# Funciones de Animacion
func morir():
	print("Matilda: Me muero :(")
	estado=ESTADOS.muriendo
	anim.play("morir-espaldas")
	muerta=true;
 
func andar():
#	$Temporizador.start(andar_temporizador)
	estado=ESTADOS.andando
	anim.play("andando")

func pararse():
#	$Temporizador.start(andar_temporizador)
	estado=ESTADOS.parado
	anim.play("default")


func draw_path(path):
	for i in range(len(path)):
		if i<len(path)-1:
			LineDrawer.DrawLine(path[i],path[i+1],Color(1, 0, 0),5)
	
