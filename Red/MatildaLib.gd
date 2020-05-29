extends Node

signal register_reply(playerID)
signal players_list_update(player_list)
signal start_match(players_position)

# Default address and port of the MatiLib companion proxy
export var lib_servidor="localhost"
export var lib_puerto=9998

export var jar_path="c:\\tmp\\MatildaLib3-1.0-SNAPSHOT.jar"
export var matilda_class="es.ugr.tstc.matilda.matildalib.MatildaLibClientLauncher"

# Our protocolo will be line-oriented. 
var buffer=""

# Let's Define the error causes:
enum ERROR {no_error, opening_port, establish_library_connection, socket_error}

# for our protocol, we should keep the state of its FSM:
enum ESTADOS {sin_conexion, conectado, esperando_register_reply, esperando_conexion, 
	esperando_conexion_servidor, conectado_servidor_juego}
var estado=ESTADOS.sin_conexion

var Message

# Let's use a socket to communicate to the proxy
var client_socket : StreamPeerTCP =null

func _ready():
	pass


func init():
	# Lanzamos la parte java de MatildaLib, en un puerto aleatorio:
#	var rng = RandomNumberGenerator.new()
#	rng.randomize()
#	lib_puerto = 9900+rng.randi_range(0, 1000)	
#	var pid = OS.execute("java.exe", ["-cp", jar_path, matilda_class], false)
	
	Message=load("res://Red/Mensaje.gd")
		
	# Esperamos unos segundos para que se active el servidor de matilda:
	# yield(get_tree().create_timer(5),"timeout")

	# Initializate TCP connection with matildaLib.java and send a first message (GameVersion)
	init_matlib_connection(lib_servidor,lib_puerto)
	
# initialize the network part:
func init_matlib_connection(lib_servidor,lib_puerto):
	var error=conectar_biblioteca(lib_servidor,lib_puerto)
	if error==ERROR.establish_library_connection:
		pass
	elif error==ERROR.no_error:
		estado=ESTADOS.conectado
	return error

# Just establish a connection to the proxy:
func conectar_biblioteca(host,puerto):
	var error=ERROR.no_error
		
	# var pid=OS.execute(JAVA_PATH,["-jar", "MatildaLib.jar"],false)
	# print(pid)
	client_socket=StreamPeerTCP.new()
	
	error=client_socket.connect_to_host(host,puerto)	
	
#	if error==OK:
#		error=enviar_mensaje_saludo(nombre_juego)
#	else:
#		error=ERROR.no_error
#	return error

# Just receive messages from the proxy, and shows them at the console..
# This should be split into a function which queues each parsed message, 
# (maybe in a thread: https://docs.godotengine.org/en/stable/tutorials/threads/using_multiple_threads.html)?
# Then, process should execute each of the messages. 
func _process(delta):
	if client_socket!= null:
		if !client_socket.is_connected_to_host(): # maybe not connected anymore?
			print("Client disconnected "+str(client_socket.get_status()))
		else:
			var n = client_socket.get_available_bytes()
			if n>0:
				var datos=client_socket.get_data(n)
				var pool=PoolByteArray(datos[1])	
				#print(str(n)+" \""+pool.get_string_from_ascii()+"\""+str(pool.hex_encode()))
				buffer=buffer+pool.get_string_from_ascii();
				
				var salto=buffer.find("\n")
				while [salto>0]:
					var linea=buffer.left(salto)
					##### instead of displaying it to the stdout, we should:
					# parse the message
					# execute it, in case of spawn, update, etc.
					#### print("recv message (to process): "+linea)
					
					# Whena a full message is received, we must process it
					# (or maybe queue it for later?)
					var message=parse_raw_message(linea)
					print("Received: "+linea)
					
					process_message(message)
					
					buffer=buffer.right(salto+1)
					salto=buffer.find("\n")
					if salto<=-1:
						break
						
						
func process_message(mensaje):
	
	match estado:
	
		ESTADOS.sin_conexion:
			pass
		ESTADOS.conectado:
			match mensaje.tipo:
				Message.TIPO.PLAYERS_LIST_UPDATE:
					emit_signal("players_list_update",mensaje.players_list)

				Message.TIPO.START_MATCH:
					emit_signal("start_match",mensaje.players_position)

					
		ESTADOS.esperando_register_reply:
			match mensaje.tipo:
				Message.TIPO.REGISTER_REPLY:
					emit_signal("register_reply",mensaje.campos["playerID"])
					estado=ESTADOS.conectado
#			pass
#		ESTADOS.esperando_conexion_servidor:
#			match mensaje.tipo:
#				Message.TIPO.serverConnectionReply:
#					if mensaje.merror!=0:
#						print("No se pudo conectar al servidor del juego!")
#					else:
#						print("Conectado al servidor del juego :)")
#						estado=ESTADOS.conectado_servidor_juego
#				_:
#					print("Error, mensaje no esperado!!!!")
#			pass

# Let's split a String into several fields
func parse_raw_message(linea):
	var message=Message.new()
	message.parse(linea)
	return message
	
func register(nombre,room,mesh,body_texture,hair_texture,direccion_servidor,puerto_servidor):
	var message=Message.new()
	message.build_register_message(nombre,room,mesh,body_texture,hair_texture,direccion_servidor,puerto_servidor)
	
	estado=ESTADOS.esperando_register_reply
	
	return enviar_mensaje(message.serialize())
		
func enviar_mensaje(mensaje):
	var error=ERROR.no_error
	if client_socket!=null:
		# We should define better this protocol...
		client_socket.put_data(PoolByteArray((mensaje+"\n").to_ascii()))
		
	else:
		error=ERROR.socket_error
