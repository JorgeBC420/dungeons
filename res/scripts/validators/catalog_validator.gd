# res://scripts/validators/catalog_validator.gd
extends RefCounted
class_name CatalogValidator

## Validador para el catálogo de cartas (CardDatabase)
## Responsabilidad: Verificar que CardDatabase tenga estructura sana
## Se ejecuta UNA SOLA VEZ al iniciar el juego

const VALID_ROLES = ["tank", "damage", "support", "magic", "cannon", "control", "legendary"]
const VALID_FACTIONS = ["human", "orc", "elf"]
const VALID_ABILITIES = [
	"ignore_first_hit", "heal_adjacent", "first_strike_bonus", "silence",
	"any_row_attack", "buff_ally", "small_aoe", "bodyguard", "human_global_buff",
	"fury", "life_drain_transfer", "dodge_20", "taunt", "bleed", "curse_half",
	"sacrifice_extra_attack", "revive_low_level", "triple_shot", "transform_bear",
	"double_skill", "freeze", "scout", "kill_strongest", "reflect_30",
	"stealth_first_turn", "steal_coin_on_death", "immediate_attack"
]

func validate_card_definition(card_data: Dictionary) -> bool:
	"""Valida que una definición de carta en CardDatabase sea válida
	Verifica: campos requeridos, tipos, valores en listas blancas
	
	Esta función NO valida atk/hp/level/owner/lane
	(esos son datos de instancia, no de definición)
	"""
	
	# Campos requeridos en definición
	if not card_data.has_all(["id", "name", "faction", "role", "ability", "rarity"]):
		push_error("CatalogValidator: Card missing required fields")
		return false
	
	# Validar tipos
	if typeof(card_data.id) != TYPE_STRING:
		push_error("CatalogValidator: Card id must be string")
		return false
	
	if typeof(card_data.name) != TYPE_STRING:
		push_error("CatalogValidator: Card name must be string")
		return false
	
	if typeof(card_data.faction) != TYPE_STRING:
		push_error("CatalogValidator: Card faction must be string")
		return false
	
	if typeof(card_data.role) != TYPE_STRING:
		push_error("CatalogValidator: Card role must be string")
		return false
	
	if typeof(card_data.ability) != TYPE_STRING:
		push_error("CatalogValidator: Card ability must be string")
		return false
	
	# Validar valores en listas blancas
	if card_data.faction not in VALID_FACTIONS:
		push_error("CatalogValidator: Invalid faction '%s' for card %s" % [card_data.faction, card_data.id])
		return false
	
	if card_data.role not in VALID_ROLES:
		push_error("CatalogValidator: Invalid role '%s' for card %s" % [card_data.role, card_data.id])
		return false
	
	if card_data.ability not in VALID_ABILITIES:
		push_error("CatalogValidator: Invalid ability '%s' for card %s" % [card_data.ability, card_data.id])
		return false
	
	return true

func validate_entire_catalog(card_data: Dictionary) -> bool:
	"""Valida todo el CardDatabase
	Se ejecuta una sola vez al iniciar
	Retorna false si hay errores → aborta el juego
	"""
	
	if typeof(card_data) != TYPE_DICTIONARY:
		push_error("CatalogValidator: CardDatabase must be Dictionary")
		return false
	
	if card_data.size() == 0:
		push_error("CatalogValidator: CardDatabase is empty")
		return false
	
	var error_count = 0
	for card_id in card_data.keys():
		if not validate_card_definition(card_data[card_id]):
			error_count += 1
	
	if error_count > 0:
		push_error("CatalogValidator: %d cards failed validation" % error_count)
		return false
	
	print("CatalogValidator: ✓ All %d cards valid" % card_data.size())
	return true
