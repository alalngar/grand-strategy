extends Control

@onready var game_scene := load("res://default.tscn")

@onready var menu_panel := $Panel
@onready var menu_host := $Panel/VB/Button
@onready var menu_ip := $Panel/VB/TextEdit
@onready var menu_join := $Panel/VB/Button2
@onready var menu_exit := $Panel/VB/Button3

@onready var lobby_panel := $Lobby
@onready var lobby_list := $Lobby/SC/VB
@onready var lobby_button := $Lobby/Button
@onready var lobby_country := $Lobby/Country

@onready var dev_button := $Panel/VB/Button4
var dev_mode := false
func _ready():
	for id in Data.countries:
		lobby_country.add_item(tr(id))
	
	menu_host.pressed.connect(_host_game)
	menu_join.pressed.connect(_join_game)
	menu_exit.pressed.connect(_exit)
	lobby_button.pressed.connect(_start_game)
	dev_button.pressed.connect(_dev_mode)
	
	multiplayer.connected_to_server.connect(_connected_to_server)
	multiplayer.peer_connected.connect(_peer_connected)

func _dev_mode():
	if dev_mode == true:
		dev_mode = false
		dev_button.text = "Dev mode: Off"
	elif dev_mode == false:
		dev_mode = true
		dev_button.text = "Dev mode: On"

func _connected_to_server():
	_add_label(str(multiplayer.get_unique_id()))
	menu_panel.visible = false
	lobby_panel.visible = true

func _peer_connected(id):
	_add_label(str(id))

func _host_game():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(Data.MULTIPLAYER_PORT)
	multiplayer.multiplayer_peer = peer
	
	_add_label(str(multiplayer.get_unique_id()))
	menu_panel.visible = false
	lobby_panel.visible = true

func _join_game():
	var ip = menu_ip.text
	if not ip.is_valid_ip_address(): return
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, Data.MULTIPLAYER_PORT)
	multiplayer.multiplayer_peer = peer
	lobby_button.visible = false

func _exit():
	get_tree().quit()

func _add_label(str):
	var label = Label.new()
	label.text = str
	lobby_list.add_child(label)

func _start_game():
	_peer_start_game.rpc()

@rpc(call_local)
func _peer_start_game():
	var country = Data.countries.values()[lobby_country.selected]
	Game.country = country
	Data.has_started = true
	Data.dev_mode_state = dev_mode
	Game.start()
	get_tree().change_scene_to_packed(game_scene)
