extends Node

# Game name... maybe this should be set up in other script?
export var nombre_juego="Battlev0.1"

# for our protocol, we should keep the state of its FSM:
enum ESTADOS {sin_conexion, conectado, esperando_conexion, 
	esperando_conexion_servidor, conectado_servidor_juego}
var estado=ESTADOS.sin_conexion

# Default address and port of the MatiLib companion proxy
export var lib_servidor="localhost"
export var lib_puerto=9998

# Game Server data:
export var servidor="localhost"
export var puerto=9090

# Let's Define the error causes:
enum ERROR {no_error, opening_port, establish_library_connection, socket_error}

# Let's use a socket to communicate to the proxy
var client_socket : StreamPeerTCP

# Our protocolo will be line-oriented. 
var buffer=""
var received_messages=[]

# Called when the node enters the scene tree for the first time.
func _ready():
	init_matlib_connection(lib_servidor,lib_puerto)
	
	# This shouldn't be here... maybe some part would need to make up something
	# beforehand...
	init_server_connection(servidor,puerto)
	
	# received_messages.resize(20)

# initialize the network part:
func init_matlib_connection(lib_servidor,lib_puerto):
	var error=conectar_biblioteca(lib_servidor,lib_puerto)
	if error==ERROR.establish_library_connection:
		pass
	elif error==ERROR.no_error:
		pass
	return error

# Just establish a connection to the proxy:
func conectar_biblioteca(host,puerto):
	var error=ERROR.no_error
		
	# var pid=OS.execute(JAVA_PATH,["-jar", "MatildaLib.jar"],false)
	# print(pid)
	client_socket=StreamPeerTCP.new()
	
	error=client_socket.connect_to_host(host,puerto)	
	
	if error==OK:
		error=enviar_mensaje_saludo(nombre_juego)
	else:
		error=ERROR.no_error
	return error
	
## todo...
#func read_line(socket):
#	var linea=""
#
#	return linea
	
func enviar_mensaje_saludo(nombre_juego):
	var error=ERROR.no_error
	if client_socket!=null:
		# We should define better this protocol...
		client_socket.put_data(PoolByteArray(("HI::"+nombre_juego+"\n").to_ascii()))
		estado=ESTADOS.esperando_conexion
	else:
		error=ERROR.socket_error
		
func init_server_connection(servidor_,puerto_):
	var error=ERROR.no_error
	if client_socket!=null: # and estado==ESTADOS.conectado:
		# We should define better this protocol...
		client_socket.put_data(PoolByteArray(("CONNECT:"+servidor_+":"+str(puerto_)+"\n").to_ascii()))
		estado=ESTADOS.esperando_conexion_servidor
	else:
		error=ERROR.socket_error
		
# Just receive messages from the proxy, and shows them at the console..
# This should be split into a function which queues each parsed message, 
# (maybe in a thread: https://docs.godotengine.org/en/stable/tutorials/threads/using_multiple_threads.html)?
# Then, process should execute each of the messages. 
func _process(delta):
	if client_socket!= null:
		if !client_socket.is_connected_to_host(): # maybe not connected anymore?
			print("Client disconnected "+str(client_socket.get_status()))
		else:
			var n= client_socket.get_available_bytes()
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
					
					process_message(message)
					
					buffer=buffer.right(salto+1)
					salto=buffer.find("\n")
					if salto<=-1:
						break

func process_message(mensaje):
	
	match estado:
		ESTADOS.esperando_conexion:
			match mensaje.tipo:
				Message.TIPO.libraryConnectionReply:
					estado=ESTADOS.conectado
				_:
					print("Error, mensaje no esperado!!!!")
		ESTADOS.sin_conexion:
			pass
		ESTADOS.conectado:
			pass
		ESTADOS.esperando_conexion_servidor:
			match mensaje.tipo:
				Message.TIPO.serverConnectionReply:
					if mensaje.merror!=0:
						print("No se pudo conectar al servidor del juego!")
					else:
						print("Conectado al servidor del juego :)")
						estado=ESTADOS.conectado_servidor_juego
				_:
					print("Error, mensaje no esperado!!!!")
			pass

# Let's split a String into several fields
func parse_raw_message(linea):
	var message=Message.new(linea)
	
	return message
	
# Message Class... Maybe it should be extracted to its own file script...
# However, it is only used in this script, at the moment.
class Message:
	
	enum TIPO {invalidMessage,libraryConnectionRequest,libraryChatMessage,
	libraryConnectionReply,
	rpcSpawn,rpcUpdatePosition,rpcUpdateValue,
	serverConnectionReply, serverConnectionRequest}
	
	var tipo=TIPO.invalidMessage
	var merror=0
	
	func _init(linea):
		var campos=linea.split(":")
		var orden=campos[0]
		
		match orden:
			"Hi":
				tipo=TIPO.libraryConnectionReply
			"Spawn":
				tipo=TIPO.rpcSpawn
			"CONNECT":
				tipo=TIPO.serverConnectionReply
				if campos[1]=="Ok":
					merror=0
				else:
					merror=int(campos[1])
	

func enviar_mensaje_crear(object_, name_):
	var error=ERROR.no_error
	if client_socket!=null:
		# We should define better this protocol...
		client_socket.put_data(PoolByteArray(("Spawn::"+name_+"\n").to_ascii()))
	else:
		error=ERROR.socket_error

# Game events, which are communicated to the server:
func _on_Matilda_created(object_, name_):
	enviar_mensaje_crear(object_, name_)
