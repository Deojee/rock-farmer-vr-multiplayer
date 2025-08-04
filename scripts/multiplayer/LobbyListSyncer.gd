extends Node

"""
An object that syncs itself with the lobby server to update data 
on joining that lobby.

each host can only have one lobby list entry.
clients have 0.
"""
#class_name LobbyListSyncer

signal lobbies_updated(lobbies : Array)

var lobby_id #this is for the lobby tracking server, not us.
var myEntry = LobbyListEntry.new({})
var HEARTBEAT_INTERVAL = 5.0

var heartbeat_request : HTTPRequest
var fetch_request : HTTPRequest
var myTimer : Timer

var shouldBeat = false

const LOBBY_ID_KEY = "lobbyID"
const INFO_KEY = "info"

func _ready():
	# === Heartbeat setup ===
	heartbeat_request = HTTPRequest.new()
	add_child(heartbeat_request)
	heartbeat_request.connect("request_completed", _on_heartbeat_response)

	lobby_id = generate_unique_lobby_id()

	myTimer = Timer.new()
	add_child(myTimer)
	myTimer.wait_time = HEARTBEAT_INTERVAL
	myTimer.connect("timeout", _send_heartbeat)
	

	# === Fetch setup ===
	fetch_request = HTTPRequest.new()
	add_child(fetch_request)
	fetch_request.connect("request_completed", _on_lobbies_response)

# === Heartbeat ===

func begin_beating():
	shouldBeat = true
	_send_heartbeat()
	myTimer.start()

func cease_beating():
	shouldBeat = false
	myTimer.stop()

func _send_heartbeat():
	
	if !shouldBeat: #we don't have a server open right now so obs don't beat
		return
	
	var json_data = JSON.stringify({
		LOBBY_ID_KEY : lobby_id,
		INFO_KEY: myEntry.getLobbyInfo()
	}, "", false)
	pass
	var headers = ["Content-Type: application/json"]

	if heartbeat_request.get_http_client_status() == HTTPClient.STATUS_DISCONNECTED:
		heartbeat_request.request(
			"https://multiplayer-lobby-handler.onrender.com/heartbeat",
			headers,
			HTTPClient.METHOD_POST,
			json_data
		)
	else:
		print("Skipped heartbeat: request still in progress")

func _on_heartbeat_response(result, response_code, headers, body):
	if response_code == 200:
		print("Heartbeat sent successfully")
		pass
	else:
		print("Heartbeat failed with code:", response_code)

# === Fetch Lobbies ===

func fetch_lobbies():
	if fetch_request.get_http_client_status() == HTTPClient.STATUS_DISCONNECTED:
		fetch_request.request("https://multiplayer-lobby-handler.onrender.com/lobbies")
	else:
		print("Skipped fetch: request still in progress")

func _on_lobbies_response(result, response_code, headers, body):
	if response_code != 200:
		print("Failed to fetch lobbies. Code:", response_code)
		return
	
	var jsonParser = JSON.new()
	var error = jsonParser.parse(body.get_string_from_utf8(),true)
	
	if error != OK:
		print("Failed to parse lobby JSON")
		return

	var raw_list = jsonParser.data
	var parsed_lobbies := []

	for entry in raw_list:
		if typeof(entry) == TYPE_DICTIONARY:
			var lobby = LobbyListEntry.new(entry)
			parsed_lobbies.append(lobby)
	
	print(parsed_lobbies)
	emit_signal("lobbies_updated", parsed_lobbies)

# === Lobby ID Generation ===

func generate_unique_lobby_id() -> String:
	var timestamp = str(Time.get_unix_time_from_system())
	var random_part = str(randi() % 10000000)
	return "lobby_" + timestamp + "_" + random_part + "_" + OS.get_unique_id()


# === LobbyListEntry class ===

class LobbyListEntry:
	var lobbyName = "unnamed lobby"
	var address = ""
	var port := 8010
	var mode = "normal"
	var currentPlayers = 1
	var maxPlayers = 16

	func _init(data : Dictionary) -> void:
		for key in data:
			if key == LOBBY_ID_KEY: #lists get combined so its in here.
				continue
			assert(key in self, "LobbyListEntry: bad data key '" + str(key) + "'")
			set(key, data[key])

	func getLobbyInfo():
		return {
			"lobbyName": lobbyName,
			"address": address,
			"port":port,
			"mode": mode,
			"currentPlayers": currentPlayers,
			"maxPlayers": maxPlayers
		}
