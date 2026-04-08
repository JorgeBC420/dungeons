# res://scripts/validators/runtime_guard.gd
extends RefCounted
class_name RuntimeGuard

## Validador para instancias de cartas en runtime (durante la partida)
## Responsabilidad: Detectar estados imposibles durante el juego
## No valida el catálogo base, solo instancias activas

const LANE_COUNT := 3
const MAX_LEVEL := 10
const MAX_STAT_VALUE := 500

func validate_card_instance(card: Dictionary) -> bool:
	"""Valida que una instancia de carta en juego tenga estado válido
	Se llama cuando: juega una carta, recibe daño, etc.
	
	Verifica invariantes que nunca deberían romperse
	"""
	
	# Campos requeridos en instancia
	if not card.has_all(["id", "level", "atk", "max_hp", "hp", "owner", "lane"]):
		push_error("RuntimeGuard: Card instance missing required fields: %s" % str(card.keys()))
		return false
	
	# Validar tipos
	if typeof(card.level) != TYPE_INT:
		push_error("RuntimeGuard: Card level must be int, got %s" % typeof(card.level))
		return false
	
	if typeof(card.atk) != TYPE_INT:
		push_error("RuntimeGuard: Card atk must be int, got %s" % typeof(card.atk))
		return false
	
	if typeof(card.max_hp) != TYPE_INT:
		push_error("RuntimeGuard: Card max_hp must be int, got %s" % typeof(card.max_hp))
		return false
	
	if typeof(card.hp) != TYPE_INT:
		push_error("RuntimeGuard: Card hp must be int, got %s" % typeof(card.hp))
		return false
	
	if typeof(card.owner) != TYPE_INT:
		push_error("RuntimeGuard: Card owner must be int, got %s" % typeof(card.owner))
		return false
	
	if typeof(card.lane) != TYPE_INT:
		push_error("RuntimeGuard: Card lane must be int, got %s" % typeof(card.lane))
		return false
	
	# Validar rangos y invariantes
	
	# Level
	if card.level < 1 or card.level > MAX_LEVEL:
		push_error("RuntimeGuard: Card level out of range: %d (1-%d)" % [card.level, MAX_LEVEL])
		return false
	
	# Attack
	if card.atk < 0 or card.atk > MAX_STAT_VALUE:
		push_error("RuntimeGuard: Card atk out of range: %d" % card.atk)
		return false
	
	# HP invariants
	if card.max_hp <= 0:
		push_error("RuntimeGuard: Card max_hp must be > 0, got %d" % card.max_hp)
		return false
	
	if card.max_hp > MAX_STAT_VALUE:
		push_error("RuntimeGuard: Card max_hp out of range: %d" % card.max_hp)
		return false
	
	if card.hp < 0 or card.hp > card.max_hp:
		push_error("RuntimeGuard: Card hp (%d) out of range (0-%d)" % [card.hp, card.max_hp])
		return false
	
	# Owner
	if card.owner not in [0, 1]:
		push_error("RuntimeGuard: Card owner must be 0 or 1, got %d" % card.owner)
		return false
	
	# Lane
	if card.lane < -1 or card.lane >= LANE_COUNT:
		push_error("RuntimeGuard: Card lane out of range: %d (must be -1 to %d)" % [card.lane, LANE_COUNT - 1])
		return false
	
	return true

func validate_combat_values(attacker: Dictionary, defender: Dictionary) -> bool:
	"""Valida que ambas cartas están en estado válido para combate
	Se llama antes de ejecutar resolve_lane_combat()
	"""
	
	if not validate_card_instance(attacker):
		return false
	
	if not validate_card_instance(defender):
		return false
	
	# Ambas deben estar vivas
	if attacker.hp <= 0:
		push_error("RuntimeGuard: Attacker is dead (hp=%d)" % attacker.hp)
		return false
	
	if defender.hp <= 0:
		push_error("RuntimeGuard: Defender is dead (hp=%d)" % defender.hp)
		return false
	
	return true

func detect_impossible_stats(card: Dictionary, original_stats: Dictionary) -> bool:
	"""Detecta si los stats cambiaron de forma imposible entre turnos
	Útil para detectar manipulación de valores en memoria
	
	Ejemplo: si atk bajó mysteriosamente sin efecto especial, es sospechoso
	"""
	
	if not original_stats.has("atk") or not original_stats.has("max_hp"):
		return false  # No hay baseline, no puedo comparar
	
	# Permitir cambios razonables pero detectar extremos
	var atk_delta = abs(card.atk - original_stats.atk)
	var hp_delta = abs(card.max_hp - original_stats.max_hp)
	
	# Cambios normales: buff (+5), debuff (-5)
	# Cambios imposibles: stat se duplicó o se redujo a 0 sin razón
	if atk_delta > 100 or hp_delta > 100:
		push_warning("RuntimeGuard: Impossible stat delta detected - atk_delta=%d, hp_delta=%d" % [atk_delta, hp_delta])
		return true  # Retorna true = "SÍ encontré manipulación"
	
	return false  # No encontré nada sospechoso
