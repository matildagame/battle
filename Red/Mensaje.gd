extends Node


const SP=" "
const DEL=":"
const DEL2=";"
const DEL3="#"

enum TIPO {invalidMessage,libraryConnectionRequest,libraryChatMessage,
	libraryConnectionReply,
	rpcSpawn,rpcUpdatePosition,rpcUpdateValue,
	serverConnectionReply, serverConnectionRequest,
	PLAYERS_LIST_UPDATE,START_MATCH,JOIN_REPLY,REGISTER_REQUEST, REGISTER_REPLY}
	
var tipo=TIPO.invalidMessage
var merror=0
var players_position=[]
var players_list=[]

var campos={}

func build_register_message(nombre,room,mesh,body_texture,hair_texture,direccion_servidor,puerto_servidor):
	campos["nombre"]=nombre
	campos["room"]=room
	campos["mesh"]=mesh
	campos["body_texture"]=body_texture
	campos["hair_texture"]=hair_texture
	campos["direccion_servidor"]=direccion_servidor
	campos["puerto_servidor"]=puerto_servidor
	
	tipo=TIPO.REGISTER_REQUEST
	
func _init():
	tipo=TIPO.invalidMessage
	
func parse(linea):
	var campo=linea.split(" ")
	var orden=campo[0]
	
	match orden:
#		"PLAYERS_LIST_UPDATE":
#			tipo=TIPO.PLAYERS_LIST_UPDATE;
#			players_list=parse_player_list_update(campos[1]);
#			emit_signal("players_list_updated",players_list)
#		"START_MATCH":
#			tipo=TIPO.START_MATCH
#			player_spawn_info=parse_start_match(campos[1]);
#			emit_signal("start_match",player_spawn_info)
		#"JOIN_REPLY":
		#	tipo=TIPO.JOIN_REPLY
		#	campo["player_ID"]=parse_join_reply(campo[1])

		"INIT_REQUEST":
			tipo=TIPO.serverConnectionRequest
		"REGISTER":
			# parse_register_message(campos[1])
			pass
		"REGISTER_REPLY":
			tipo=TIPO.REGISTER_REPLY
			parse_register_reply_message(campo)
		"PLAYER_LIST":
			tipo=TIPO.PLAYERS_LIST_UPDATE
			parse_players_list(campo[1])
		"START_MATCH":
			tipo=TIPO.START_MATCH
			parse_start_match(campo[1])
		_:
			print(">> "+linea+" << Unknown!")

func parse_start_match(campo):
	var error=0
	var positions_description=campo.split(DEL)
		
	for item in positions_description:
		var character_position=parse_player_position(item)
		players_position.append(character_position)
		
	return error
	
func parse_player_position(item):
	var description={}
	
	var values=item.split(DEL2)
	
	description["playerID"]=values[0]
	description["position"]=Vector3(int(values[1]),int(values[2]),int(values[3]))
	
	return description
	
func parse_players_list(campo):
	var error=0
	var players_description=campo.split(DEL)
	# var players_list
	
	for item in players_description:
		var character_description=parse_character_description(item)
		players_list.append(character_description)
	
	if error==0:
		tipo=TIPO.PLAYERS_LIST_UPDATE
		campos["players_list"]=players_list
	else:
		tipo=TIPO.invalidMessage
		
	return error
	
func parse_character_description(item):
	var description={}
	
	var values=item.split(DEL2)
	
	description["playerID"]=values[0]
	description["username"]=values[1]
	description["mesh"]=values[2]
	description["body_texture"]=values[3]
	description["hair_texture"]=values[4]

	return description

func parse_register_reply_message(campo):
	var error=0
	
	if campo[1]=="OK":
		campos["playerID"]=campo[2]
		
		tipo=TIPO.REGISTER_REPLY
	else:
		error=1
		tipo=TIPO.invalidMessage
		
	return error
	
func serialize():
	var line=""
	
	match(tipo):
		TIPO.REGISTER_REQUEST:
			line="REGISTER"+SP+campos["nombre"]+DEL+campos["room"]+DEL+campos["mesh"]+DEL+campos["body_texture"]+DEL+campos["hair_texture"]+DEL+campos["direccion_servidor"]+DEL+campos["puerto_servidor"]
		TIPO.REGISTER_REPLY:
			line="REGISTER_REPLY"+SP+"TODO"
			
	return line
