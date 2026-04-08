# res://scripts/security/anti_cheat.gd
extends Node
class_name AntiCheat

# Constantes de validación
const MIN_STAT_VALUE = 0
const MAX_STAT_VALUE = 500
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

var tamper_detected: bool = false
var tamper_log: Array = []

signal tamper_attempt(reason: String, details: String)

func _ready() -> void:
	# Verificar integridad al iniciar
	_verify_game_integrity()

func validate_card_data(card_data: Dictionary) -> bool:
	"""Valida que los datos de una carta sean legítimos"""
	
	if not card_data.has_all(["id", "name", "faction", "role", "ability", "level"]):
		_log_tamper("Invalid card structure", str(card_data))
		return false
	
	# Validar facción
	if card_data.faction not in VALID_FACTIONS:
		_log_tamper("Invalid faction", card_data.faction)
		return false
	
	# Validar rol
	if card_data.role not in VALID_ROLES:
		_log_tamper("Invalid role", card_data.role)
		return false
	
	# Validar habilidad
	if card_data.ability not in VALID_ABILITIES:
		_log_tamper("Invalid ability", card_data.ability)
		return false
	
	# Validar stats
	if not _validate_stats(card_data):
		_log_tamper("Invalid stats", "%s / %s" % [card_data.get("atk", "?"), card_data.get("hp", "?")])
		return false
	
	# Validar nivel
	if card_data.level < 1 or card_data.level > 10:
		_log_tamper("Invalid level", str(card_data.level))
		return false
	
	return true

func validate_game_state(game_manager: GameManager) -> bool:
	"""Valida el estado completo del juego"""
	
	# Validar HP base
	if game_manager.base_hp[0] < -100 or game_manager.base_hp[0] > 20:
		_log_tamper("Invalid player base HP", str(game_manager.base_hp[0]))
		return false
	
	if game_manager.base_hp[1] < -100 or game_manager.base_hp[1] > 20:
		_log_tamper("Invalid enemy base HP", str(game_manager.base_hp[1]))
		return false
	
	# Validar tablero
	for lane_idx in range(game_manager.LANE_COUNT):
		var player_unit = game_manager.get_unit_at(lane_idx, 0)
		var enemy_unit = game_manager.get_unit_at(lane_idx, 1)
		
		if player_unit != null:
			if not validate_card_data(player_unit.data):
				return false
		
		if enemy_unit != null:
			if not validate_card_data(enemy_unit.data):
				return false
	
	# Validar mano de jugador
	for card_unit in game_manager.get_hand(0):
		if not validate_card_data(card_unit.data):
			_log_tamper("Invalid card in player hand", card_unit.data.id)
			return false
	
	return true

func validate_card_play(
	card_unit: CardUnit,
	lane_index: int,
	player: int,
	game_manager: GameManager
) -> bool:
	"""Valida que un movimiento de carta sea legal"""
	
	# Validar índice de carril
	if lane_index < 0 or lane_index >= game_manager.LANE_COUNT:
		_log_tamper("Invalid lane index", str(lane_index))
		return false
	
	# Validar que la carta pertenece al jugador
	if card_unit.data.owner != player:
		_log_tamper("Card ownership mismatch", "Card owner: %d, Player: %d" % [card_unit.data.owner, player])
		return false
	
	# Validar que no hay carta ya en ese carril
	if game_manager.get_unit_at(lane_index, player) != null:
		_log_tamper("Lane already occupied", "Lane: %d" % lane_index)
		return false
	
	# Validar turno actual
	if player != game_manager.current_player:
		_log_tamper("Not player's turn", "Expected: %d, Got: %d" % [game_manager.current_player, player])
		return false
	
	return true

func protect_card_data(card_data: Dictionary) -> Dictionary:
	"""Crear una copia protegida de los datos de la carta"""
	var protected = card_data.duplicate(true)
	protected["_integrity_hash"] = _calculate_hash(protected)
	return protected

func verify_card_integrity(card_data: Dictionary) -> bool:
	"""Verifica que los datos no hayan sido modificados"""
	if not card_data.has("_integrity_hash"):
		return true  # Cartas antiguas sin hash
	
	var stored_hash = card_data["_integrity_hash"]
	var current_hash = _calculate_hash(card_data)
	
	if stored_hash != current_hash:
		_log_tamper("Card integrity check failed", card_data.id)
		return false
	
	return true

func detect_impossible_stats(card: CardUnit) -> bool:
	"""Detecta si los stats son imposibles para el nivel"""
	var stats = CardDatabase.get_stats_for_role(card.data.role, card.data.level)
	
	# Permitir buffos/debuffs razonables (+-5)
	var atk_diff = abs(card.data.atk - stats.atk)
	var hp_diff = abs(card.data.max_hp - stats.hp)
	
	if atk_diff > 50 or hp_diff > 50:
		_log_tamper("Impossible stats detected", "%s: ATK diff=%d, HP diff=%d" % [card.data.id, atk_diff, hp_diff])
		return true
	
	return false

# Métodos privados
func _validate_stats(card_data: Dictionary) -> bool:
	var atk = card_data.get("atk", -1)
	var hp = card_data.get("hp", -1)
	
	if not isinstance(atk, int) or not isinstance(hp, int):
		return false
	
	if atk < MIN_STAT_VALUE or atk > MAX_STAT_VALUE:
		return false
	
	if hp < MIN_STAT_VALUE or hp > MAX_STAT_VALUE:
		return false
	
	return true

func _calculate_hash(data: Dictionary) -> String:
	"""Calcula un hash de los datos para verificar integridad"""
	var hash_input = "%s_%s_%s_%s_%s" % [
		data.get("id", ""),
		data.get("faction", ""),
		data.get("role", ""),
		data.get("ability", ""),
		data.get("level", "")
	]
	return hash_input.sha256_text()

func _log_tamper(reason: String, details: String) -> void:
	"""Registra intentos de trampa"""
	tamper_detected = true
	
	var log_entry = {
		"timestamp": Time.get_ticks_msec(),
		"reason": reason,
		"details": details
	}
	
	tamper_log.append(log_entry)
	
	emit_signal("tamper_attempt", reason, details)
	
	push_error("ANTI-CHEAT: %s - %s" % [reason, details])

func _verify_game_integrity() -> void:
	"""Verifica que los datos del juego no hayan sido modificados
	Nota: Valida la estructura del CardDatabase, NO valores calculados (atk/hp)
	Los valores calculados se validan cuando se instancia CardUnit en play_card_from_hand()
	"""
	var card_data = CardDatabase.get_card_data()
	
	# Verificar que todas las cartas tengan estructura válida
	for card_id in card_data.keys():
		var card = card_data[card_id]
		
		# Validar estructura base (sin requerer atk/hp que se calculan al instanciar)
		if not card.has_all(["id", "name", "faction", "role", "ability", "level"]):
			_log_tamper("Invalid card structure in database", card_id)
			continue
		
		# Validar facción, rol, habilidad (estructura, no cálculos)
		if card.faction not in VALID_FACTIONS:
			_log_tamper("Invalid faction in database", "%s: %s" % [card_id, card.faction])
		
		if card.role not in VALID_ROLES:
			_log_tamper("Invalid role in database", "%s: %s" % [card_id, card.role])
		
		if card.ability not in VALID_ABILITIES:
			_log_tamper("Invalid ability in database", "%s: %s" % [card_id, card.ability])

func get_tamper_report() -> Dictionary:
	"""Obtiene un reporte de intentos de trampa"""
	return {
		"tamper_detected": tamper_detected,
		"total_attempts": tamper_log.size(),
		"log": tamper_log
	}

func clear_tamper_log() -> void:
	"""Limpia el registro de trampas (usar solo en nueva sesión)"""
	tamper_log.clear()
	tamper_detected = false
