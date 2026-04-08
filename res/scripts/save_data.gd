# res://scripts/save_data.gd
extends Node
class_name SaveData

## Datos de progreso del jugador - MINIMALISTA
## Solo guarda cambios respecto a valores defaults para minimizar almacenamiento

# Defaults (no se guardan si son valores por defecto)
const DEFAULT_COINS = 300
const DEFAULT_CARD_LEVEL = 1
const DEFAULT_CARD_COPIES = 10

var inventory := {}  # Solo guarda cambios: {card_id: {level, copies}}
var coins := DEFAULT_COINS

func _ready() -> void:
	pass

## Inicializa con valores por defecto sin copiar a diccionario
## Esto minimiza memoria: solo cargamos lo guardado, no todo
func initialize_defaults() -> void:
	inventory.clear()
	coins = DEFAULT_COINS

## Obtiene el nivel de una carta (usa default si no existe)
func get_card_level(card_id: String) -> int:
	if not inventory.has(card_id):
		return DEFAULT_CARD_LEVEL
	return inventory[card_id].get("level", DEFAULT_CARD_LEVEL)

## Obtiene copias de una carta (usa default si no existe)
func get_card_copies(card_id: String) -> int:
	if not inventory.has(card_id):
		return DEFAULT_CARD_COPIES
	return inventory[card_id].get("copies", DEFAULT_CARD_COPIES)

## Actualiza el nivel de una carta - solo guarda si es diferente del default
func set_card_level(card_id: String, level: int) -> void:
	if level == DEFAULT_CARD_LEVEL:
		# No guardar valores default
		if inventory.has(card_id):
			inventory[card_id].erase("level")
	else:
		if not inventory.has(card_id):
			inventory[card_id] = {}
		inventory[card_id]["level"] = level

## Actualiza copias de una carta - solo guarda si es diferente del default
func set_card_copies(card_id: String, copies: int) -> void:
	if copies == DEFAULT_CARD_COPIES:
		if inventory.has(card_id):
			inventory[card_id].erase("copies")
	else:
		if not inventory.has(card_id):
			inventory[card_id] = {}
		inventory[card_id]["copies"] = copies

## Retorna el porcentaje de datos guardados vs estructura completa
## Útil para monitorear compresión
func get_compression_ratio() -> float:
	var total_cards = CardDatabase.get_card_data().size()
	var changed_cards = inventory.size()
	if total_cards == 0:
		return 0.0
	return float(changed_cards) / float(total_cards)
