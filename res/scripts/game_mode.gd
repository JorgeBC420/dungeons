# res://scripts/game_mode.gd
extends Node
class_name GameMode

## Sistema de modo juego: Guest (sin guardar) o Account (con persistencia)

enum Mode { GUEST, ACCOUNT }

var current_mode: Mode = Mode.GUEST
var player_email: String = ""  # Para futura integración con Google Play

signal mode_changed(new_mode: Mode)
signal account_linked(email: String)

func _ready() -> void:
	pass

## Cambia el modo de juego
func set_mode(mode: Mode, email: String = "") -> void:
	if current_mode == mode:
		return
	
	current_mode = mode
	if mode == Mode.ACCOUNT:
		player_email = email
		account_linked.emit(email)
	else:
		player_email = ""
	
	mode_changed.emit(current_mode)
	var mode_names = {Mode.GUEST: "GUEST", Mode.ACCOUNT: "ACCOUNT"}
	print("Game mode changed to: %s" % mode_names.get(current_mode, "UNKNOWN"))

## Retorna true si está en modo guest
func is_guest_mode() -> bool:
	return current_mode == Mode.GUEST

## Retorna true si está en modo account
func is_account_mode() -> bool:
	return current_mode == Mode.ACCOUNT

## Obtiene el modo actual como string
func get_mode_string() -> String:
	var mode_names = {Mode.GUEST: "guest", Mode.ACCOUNT: "account"}
	return mode_names.get(current_mode, "unknown")
