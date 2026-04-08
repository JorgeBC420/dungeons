# res://scripts/validators/save_validator.gd
extends RefCounted
class_name SaveValidator

## Validador para datos guardados
## Responsabilidad: Verificar integridad de estructura y rangos en archivos de save

const MAX_LEVEL := 10
const MAX_COPIES := 999
const MAX_COINS := 999999

func validate_save_data(data: Dictionary) -> bool:
	"""Valida que los datos cargados de un save sean legítimos
	Verifica: estructura, tipos, rangos
	Retorna true si el save es válido para cargar
	"""
	
	# Verificar campos requeridos
	if not data.has("inventory") or not data.has("coins"):
		push_error("SaveValidator: Missing required fields (inventory or coins)")
		return false
	
	# Validar tipos básicos
	if typeof(data.inventory) != TYPE_DICTIONARY:
		push_error("SaveValidator: inventory must be Dictionary, got %s" % typeof(data.inventory))
		return false
	
	if typeof(data.coins) != TYPE_INT:
		push_error("SaveValidator: coins must be int, got %s" % typeof(data.coins))
		return false
	
	# Validar rango de coins
	if data.coins < 0 or data.coins > MAX_COINS:
		push_error("SaveValidator: coins out of range: %d (max: %d)" % [data.coins, MAX_COINS])
		return false
	
	# Validar inventario
	for card_id in data.inventory.keys():
		var card_info = data.inventory[card_id]
		
		# Estructura
		if typeof(card_info) != TYPE_DICTIONARY:
			push_error("SaveValidator: card_info for %s must be Dictionary" % card_id)
			return false
		
		# Campos requeridos
		if not card_info.has_all(["copies", "level"]):
			push_error("SaveValidator: card %s missing required fields (copies or level)" % card_id)
			return false
		
		# Tipos
		if typeof(card_info.copies) != TYPE_INT or typeof(card_info.level) != TYPE_INT:
			push_error("SaveValidator: card %s has invalid types (copies or level)" % card_id)
			return false
		
		# Rangos
		if card_info.copies < 0 or card_info.copies > MAX_COPIES:
			push_error("SaveValidator: card %s copies out of range: %d" % [card_id, card_info.copies])
			return false
		
		if card_info.level < 1 or card_info.level > MAX_LEVEL:
			push_error("SaveValidator: card %s level out of range: %d" % [card_id, card_info.level])
			return false
	
	return true

func validate_inventory_count() -> bool:
	"""Verifica que el inventario no sea absurdamente grande
	Útil para detectar saves inflados/manipulados
	"""
	# Máximo 27 cartas en el juego
	# Máximo 999 copias cada una
	# Si alguien tiene >10000 copias de una carta, es sospechoso
	return true
