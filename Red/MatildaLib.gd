extends Node

# Game name... maybe this should be set up in other script?
export var nombre_juego="Battlev0.1"

# Default address and port of the MatiLib companion proxy
var lib_servidor="localhost"
var lib_puerto=9998

# Let's Define the error causes:
enum ERROR {no_error, opening_port, establish_library_connection, socket_error}

# Let's use a socket to communicate to the proxy
var client_socket : StreamPeerTCP

# Our protocolo will be line-oriented. 
var buffer=""

# Called when the node enters the scene tree for the first time.
func _ready():
	init_matlib_connection(lib_servidor,lib_puerto)

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
	
	
func enviar_mensaje_saludo(nombre_juego):
	var error=ERROR.no_error
	if client_socket!=null:
		# We should define better this protocol...
		client_socket.put_data(PoolByteArray(("HI::"+nombre_juego+"\n").to_ascii()))
	else:
		error=ERROR.socket_error
		
# Just receive messages from the proxy, and shows them at the console..
# This should be split into a function which queues each parsed message, (maybe in a thread: https://docs.godotengine.org/en/stable/tutorials/threads/using_multiple_threads.html)?
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
					print("recv message (to process): "+linea)
					buffer=buffer.right(salto+1)
					salto=buffer.find("\n")
					if salto<=-1:
						break
