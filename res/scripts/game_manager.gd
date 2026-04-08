# res://scripts/game_manager.gd
extends Node
class_name GameManager

signal board_changed
signal hand_changed(player: int)
signal turn_changed(current_player: int, turn_number: int)
signal log_updated(text: String)
signal game_over(winner: int)

const PLAYER_1 := 0
const PLAYER_2 := 1
const LANE_COUNT := 3
const STARTING_HAND := 5
const BASE_HP := 20
const FACTION_BONUS := 3

var rng := RandomNumberGenerator.new()
var save_data: SaveData
var anti_cheat: AntiCheat
var secure_save: SecureSave
var game_mode: GameMode

var base_hp := [BASE_HP, BASE_HP]
var coins := [0, 0]
var board := []
var graveyards := [[], []]
var decks := [[], []]
var hands := [[], []]
var current_player := PLAYER_1
var turn_number := 1
var game_ended := false

func _ready() -> void:
	rng.randomize()
	
	# Inicializar sistema de modo de juego
	game_mode = GameMode.new()
	add_child(game_mode)
	game_mode.set_mode(GameMode.Mode.GUEST)  # Por defecto: Guest
	
	# Inicializar sistemas de seguridad
	anti_cheat = AntiCheat.new()
	add_child(anti_cheat)
	
	secure_save = SecureSave.new()
	add_child(secure_save)
	secure_save.game_mode = game_mode  # Conectar GameMode a SecureSave
	
	# Cargar datos guardados de forma segura
	save_data = secure_save.load_player_data()
	if save_data == null:
		save_data = SaveData.new()
		save_data.initialize_defaults()
	add_child(save_data)

	_initialize_board()
	_build_test_decks()
	_draw_starting_hands()

	emit_signal("board_changed")
	emit_signal("hand_changed", PLAYER_1)
	emit_signal("hand_changed", PLAYER_2)
	emit_signal("turn_changed", current_player, turn_number)
	_log("Comienza la partida.")

func _initialize_board() -> void:
	board.clear()
	for i in range(LANE_COUNT):
		board.append({
			PLAYER_1: null,
			PLAYER_2: null
		})

func _build_test_decks() -> void:
	# PLAYER_1: Solo humanos (9 cartas únicas, sin duplicados)
	decks[PLAYER_1] = [
		"paladin_alba", "medico_campo", "caballero_real", "inquisidor_hierro",
		"arquero_muralla", "herrero_imperial", "hechicero_corte", "escudero_novato",
		"general_valerius"
	]

	# PLAYER_2: Solo orcos (9 cartas únicas, sin duplicados)
	decks[PLAYER_2] = [
		"berserker_feroz", "chaman_sangre", "jinete_lobo", "rompefilas",
		"lanzador_hachas", "brujo_sombras", "capataz_esclavos", "trasgo_saqueador",
		"gran_jefe_gromm"
	]

	decks[PLAYER_1].shuffle()
	decks[PLAYER_2].shuffle()

func _draw_starting_hands() -> void:
	for p in [PLAYER_1, PLAYER_2]:
		for i in range(STARTING_HAND):
			draw_card(p)

func draw_card(player: int) -> void:
	if decks[player].is_empty():
		return

	var card_id: String = decks[player].pop_back()
	var level := save_data.get_card_level(card_id)
	var card_data := CardDatabase.create_card_instance(card_id, level)
	card_data.owner = player
	hands[player].append(CardUnit.new(card_data))
	emit_signal("hand_changed", player)

func get_hand(player: int) -> Array:
	return hands[player]

func get_unit_at(lane: int, player: int) -> CardUnit:
	return board[lane][player]

func play_card_from_hand(player: int, hand_index: int, lane_index: int) -> bool:
	if game_ended:
		return false
	if player != current_player:
		_log("No es el turno del jugador %d" % player)
		return false
	if lane_index < 0 or lane_index >= LANE_COUNT:
		return false
	if board[lane_index][player] != null:
		_log("Ese carril ya está ocupado.")
		return false
	if hand_index < 0 or hand_index >= hands[player].size():
		return false

	var unit: CardUnit = hands[player][hand_index]
	
	# VALIDACIÓN ANTI-CHEAT: Verificar que la carta es válida
	if not anti_cheat.validate_card_data(unit.data):
		_log("Error: Intento de jugar carta inválida detectado.")
		return false
	
	# VALIDACIÓN ANTI-CHEAT: Verificar movimiento legal
	if not anti_cheat.validate_card_play(unit, lane_index, player, self):
		_log("Error: Movimiento ilegal detectado.")
		return false
	
	unit.data.lane = lane_index
	board[lane_index][player] = unit
	hands[player].remove_at(hand_index)

	_apply_passive_flags(unit)
	_activate_on_play_ability(unit)
	_log("%s entra al carril %d." % [unit.data.name, lane_index + 1])

	if unit.data.ability == "immediate_attack" and unit.data.silenced_turns <= 0:
		resolve_lane_combat(lane_index, player)

	emit_signal("hand_changed", player)
	emit_signal("board_changed")

	_check_game_over()
	if not game_ended:
		end_turn()
	return true

func ai_take_turn() -> void:
	if game_ended:
		return
	if current_player != PLAYER_2:
		return

	var available_lanes := []
	for i in range(LANE_COUNT):
		if board[i][PLAYER_2] == null:
			available_lanes.append(i)

	if available_lanes.is_empty():
		_log("IA no tiene espacio. Pasa turno.")
		end_turn()
		return

	if hands[PLAYER_2].is_empty():
		_log("IA no tiene cartas. Pasa turno.")
		end_turn()
		return

	var chosen_lane := available_lanes[rng.randi_range(0, available_lanes.size() - 1)]

	var best_hand_index := 0
	var best_score := -99999
	for i in range(hands[PLAYER_2].size()):
		var c: CardUnit = hands[PLAYER_2][i]
		var score := c.data.atk + c.data.hp
		if board[chosen_lane][PLAYER_1] != null and has_faction_advantage(c.data.faction, board[chosen_lane][PLAYER_1].data.faction):
			score += 5
		if score > best_score:
			best_score = score
			best_hand_index = i

	play_card_from_hand(PLAYER_2, best_hand_index, chosen_lane)

func end_turn() -> void:
	_process_turn_start_for_player(1 - current_player)
	current_player = 1 - current_player
	turn_number += 1
	draw_card(current_player)

	emit_signal("board_changed")
	emit_signal("hand_changed", current_player)
	emit_signal("turn_changed", current_player, turn_number)

	if current_player == PLAYER_2 and not game_ended:
		call_deferred("ai_take_turn")

func _process_turn_start_for_player(player: int) -> void:
	for lane_index in range(LANE_COUNT):
		var unit: CardUnit = board[lane_index][player]
		if unit != null:
			unit.start_turn()
			if not unit.is_alive():
				_handle_death(unit, lane_index)

	for lane_index in range(LANE_COUNT):
		resolve_lane_combat(lane_index, player)

func _apply_passive_flags(unit: CardUnit) -> void:
	match unit.data.ability:
		"dodge_20":
			unit.data.dodge_chance = 0.20
		"taunt":
			unit.data.taunt = true
		"reflect_30":
			unit.data.reflect_ratio = 0.30
		"stealth_first_turn":
			unit.data.stealth_turns = 1
		"bodyguard":
			unit.data.bodyguard_for_paladin = true

func _activate_on_play_ability(unit: CardUnit) -> void:
	if unit.data.silenced_turns > 0:
		return

	match unit.data.ability:
		"heal_adjacent":
			_heal_adjacent(unit, 2)

		"silence":
			var enemy := _find_strongest_enemy(unit.data.owner)
			if enemy != null:
				enemy.data.silenced_turns = 1
				_log("%s silencia a %s." % [unit.data.name, enemy.data.name])

		"buff_ally":
			var ally := _find_best_ally_except(unit.data.owner, unit)
			if ally != null:
				ally.data.atk += 2
				_log("%s refuerza a %s." % [unit.data.name, ally.data.name])

		"small_aoe":
			_damage_all_enemies(unit.data.owner, 2)

		"life_drain_transfer":
			var enemy2 := _find_strongest_enemy(unit.data.owner)
			var ally2 := _find_weakest_ally(unit.data.owner)
			if enemy2 != null and ally2 != null:
				var drained := min(2, enemy2.data.hp)
				enemy2.receive_damage(drained)
				ally2.heal(drained)

		"curse_half":
			var enemy3 := _find_strongest_enemy(unit.data.owner)
			if enemy3 != null:
				enemy3.data.atk = maxi(1, int(enemy3.data.atk / 2))

		"sacrifice_extra_attack":
			var victim := _find_weakest_ally(unit.data.owner, unit)
			if victim != null:
				var lane_victim := victim.data.lane
				victim.receive_damage(999)
				_handle_death(victim, lane_victim)
				resolve_lane_combat(unit.data.lane, unit.data.owner)

		"revive_low_level":
			_revive_low_level(unit.data.owner)

		"triple_shot":
			_random_damage_to_enemies(unit.data.owner, 3, 2)

		"transform_bear":
			unit.data.role = CardDatabase.ROLE_TANK
			unit.data.atk += 2
			unit.data.max_hp += 4
			unit.data.hp += 4

		"double_skill":
			var ally3 := _find_best_ally_except(unit.data.owner, unit)
			if ally3 != null:
				ally3.data.extra_skill_uses += 1

		"freeze":
			var target := _find_strongest_enemy(unit.data.owner)
			if target != null:
				target.data.frozen_turns = 1

		"scout":
			var next_card := _peek_next_card(1 - unit.data.owner)
			if next_card != "":
				_log("%s ve la próxima carta rival: %s" % [unit.data.name, next_card])

		"kill_strongest":
			var strongest := _find_strongest_enemy(unit.data.owner)
			if strongest != null:
				var lane := strongest.data.lane
				strongest.receive_damage(999)
				_handle_death(strongest, lane)

		"human_global_buff":
			_buff_all_humans(unit.data.owner, 1)

		"fury":
			# Fury es pasivo: suma (max_hp - hp) al ataque
			# Ya está implementado en get_effective_attack() → get_attack_bonus_from_missing_hp()
			_log("%s entra en furia (ATK +%d por HP perdido)." % [unit.data.name, unit.get_attack_bonus_from_missing_hp()])

		"any_row_attack":
			# Arquero de Muralla: ataca diferentes carriles
			var target_lane = _find_best_target_lane_for_archer(unit.data.owner, unit.data.lane)
			if target_lane >= 0:
				resolve_lane_combat_custom(target_lane, unit.data.owner, unit)

func resolve_lane_combat(lane_index: int, attacking_player: int) -> void:
	var attacker: CardUnit = board[lane_index][attacking_player]
	var defender: CardUnit = board[lane_index][1 - attacking_player]

	if attacker == null or not attacker.is_alive():
		return
	if not attacker.can_act():
		return
	if attacker.data.has_attacked_this_turn:
		return

	if defender == null:
		base_hp[1 - attacking_player] -= attacker.get_effective_attack()
		attacker.data.has_attacked_this_turn = true
		_log("%s golpea la base enemiga por %d." % [attacker.data.name, attacker.get_effective_attack()])
		_check_game_over()
		return

	if defender.data.ability == "stealth_first_turn" and defender.data.stealth_turns > 0 and defender.data.silenced_turns <= 0:
		base_hp[1 - attacking_player] -= attacker.get_effective_attack()
		attacker.data.has_attacked_this_turn = true
		_log("%s evita ser objetivo por sigilo. %s daña base." % [defender.data.name, attacker.data.name])
		_check_game_over()
		return

	var redirected := _try_redirect_from_squire(defender)
	if redirected != null:
		defender = redirected

	var attack_value := _calculate_attack_power(attacker, defender)

	if attacker.data.ability == "first_strike_bonus" and attacker.data.silenced_turns <= 0:
		attack_value = int(round(attack_value * 1.5))

	if defender.data.dodge_chance > 0.0 and rng.randf() <= defender.data.dodge_chance:
		attacker.data.has_attacked_this_turn = true
		_log("%s esquiva el ataque de %s." % [defender.data.name, attacker.data.name])
		return

	var damage_done := defender.receive_damage(attack_value)
	_log("%s ataca a %s por %d." % [attacker.data.name, defender.data.name, damage_done])

	if defender.data.reflect_ratio > 0.0 and defender.data.silenced_turns <= 0:
		var reflected := int(round(damage_done * defender.data.reflect_ratio))
		attacker.receive_damage(reflected)
		_log("%s refleja %d de daño." % [defender.data.name, reflected])

	if attacker.data.ability == "bleed" and attacker.data.silenced_turns <= 0 and defender.is_alive():
		defender.data.bleed_turns = 2
		defender.data.bleed_damage = 1

	if not defender.is_alive():
		_handle_death(defender, lane_index)

	if not attacker.is_alive():
		_handle_death(attacker, lane_index)

	attacker.data.has_attacked_this_turn = true
	_check_game_over()

func _calculate_attack_power(attacker: CardUnit, defender: CardUnit) -> int:
	var value := attacker.get_effective_attack()
	if has_faction_advantage(attacker.data.faction, defender.data.faction):
		value += FACTION_BONUS
	return value

func has_faction_advantage(attacker_faction: String, defender_faction: String) -> bool:
	return (
		(attacker_faction == CardDatabase.FACTION_HUMAN and defender_faction == CardDatabase.FACTION_ORC) or
		(attacker_faction == CardDatabase.FACTION_ORC and defender_faction == CardDatabase.FACTION_ELF) or
		(attacker_faction == CardDatabase.FACTION_ELF and defender_faction == CardDatabase.FACTION_HUMAN)
	)

func _handle_death(unit: CardUnit, lane_index: int) -> void:
	if unit == null:
		return

	var owner := unit.data.owner
	graveyards[owner].append(unit)

	if unit.data.ability == "steal_coin_on_death" and unit.data.silenced_turns <= 0:
		var enemy := 1 - owner
		coins[enemy] = maxi(0, coins[enemy] - 1)
		coins[owner] += 1

	if board[lane_index][owner] == unit:
		board[lane_index][owner] = null

	_log("%s ha caído." % unit.data.name)
	emit_signal("board_changed")

func _heal_adjacent(unit: CardUnit, amount: int) -> void:
	var lane := unit.data.lane
	var owner := unit.data.owner
	for other_lane in [lane - 1, lane + 1]:
		if other_lane >= 0 and other_lane < LANE_COUNT:
			var ally: CardUnit = board[other_lane][owner]
			if ally != null:
				ally.heal(amount)

func _damage_all_enemies(owner: int, amount: int) -> void:
	var enemy := 1 - owner
	for lane_index in range(LANE_COUNT):
		var target: CardUnit = board[lane_index][enemy]
		if target != null:
			target.receive_damage(amount)
			if not target.is_alive():
				_handle_death(target, lane_index)

func _find_strongest_enemy(owner: int) -> CardUnit:
	var enemy := 1 - owner
	var best: CardUnit = null
	var best_power := -99999
	for lane_index in range(LANE_COUNT):
		var u: CardUnit = board[lane_index][enemy]
		if u != null and u.is_alive():
			var power := u.get_effective_attack() + u.data.hp
			if power > best_power:
				best_power = power
				best = u
	return best

func _find_best_ally_except(owner: int, excluded: CardUnit) -> CardUnit:
	var best: CardUnit = null
	var best_score := -99999
	for lane_index in range(LANE_COUNT):
		var u: CardUnit = board[lane_index][owner]
		if u != null and u != excluded and u.is_alive():
			var score := u.get_effective_attack() + u.data.hp
			if score > best_score:
				best_score = score
				best = u
	return best

func _find_weakest_ally(owner: int, excluded: CardUnit = null) -> CardUnit:
	var weakest: CardUnit = null
	var weakest_hp := 99999
	for lane_index in range(LANE_COUNT):
		var u: CardUnit = board[lane_index][owner]
		if u != null and u != excluded and u.is_alive():
			if u.data.hp < weakest_hp:
				weakest_hp = u.data.hp
				weakest = u
	return weakest

func _revive_low_level(owner: int) -> void:
	if graveyards[owner].is_empty():
		return

	for dead in graveyards[owner]:
		if dead.data.level <= 2:
			for lane_index in range(LANE_COUNT):
				if board[lane_index][owner] == null:
					dead.data.hp = max(1, int(dead.data.max_hp / 2))
					dead.data.lane = lane_index
					board[lane_index][owner] = dead
					graveyards[owner].erase(dead)
					_log("%s revive a %s." % ["Curandero Sagrado", dead.data.name])
					return

func _random_damage_to_enemies(owner: int, shots: int, damage: int) -> void:
	var enemy := 1 - owner
	var enemy_units := []
	for lane_index in range(LANE_COUNT):
		var u: CardUnit = board[lane_index][enemy]
		if u != null and u.is_alive():
			enemy_units.append(u)

	if enemy_units.is_empty():
		return

	for i in range(shots):
		if enemy_units.is_empty():
			return
		var target: CardUnit = enemy_units[rng.randi_range(0, enemy_units.size() - 1)]
		target.receive_damage(damage)
		if not target.is_alive():
			_handle_death(target, target.data.lane)
			enemy_units.erase(target)

func _peek_next_card(player: int) -> String:
	if decks[player].is_empty():
		return ""
	return decks[player][-1]

func _buff_all_humans(owner: int, amount: int) -> void:
	for lane_index in range(LANE_COUNT):
		var u: CardUnit = board[lane_index][owner]
		if u != null and u.data.faction == CardDatabase.FACTION_HUMAN:
			u.data.atk += amount

func _try_redirect_from_squire(target: CardUnit) -> CardUnit:
	if target.data.id != "paladin_alba":
		return null

	var owner := target.data.owner
	for lane_index in range(LANE_COUNT):
		var ally: CardUnit = board[lane_index][owner]
		if ally != null and ally.is_alive() and ally.data.id == "escudero_novato" and ally.data.silenced_turns <= 0:
			return ally
	return null

func _check_game_over() -> void:
	if base_hp[PLAYER_1] <= 0 and base_hp[PLAYER_2] <= 0:
		game_ended = true
		emit_signal("game_over", -1)
		_auto_save_progress()
	elif base_hp[PLAYER_1] <= 0:
		game_ended = true
		emit_signal("game_over", PLAYER_2)
		_auto_save_progress()
	elif base_hp[PLAYER_2] <= 0:
		game_ended = true
		emit_signal("game_over", PLAYER_1)
		_auto_save_progress()

## SISTEMA DE GUARDADO Y SINCRONIZACIÓN

## Guarda el progreso de forma automática
## - Guest mode: Guarda localmente sin sincronización
## - Account mode con Google Play: Guarda localmente Y sincroniza a la nube
func _auto_save_progress() -> void:
	"""Guarda automáticamente después de eventos importantes (fin de partida)"""
	if secure_save.save_player_data(save_data):
		secure_save.sync_to_cloud(save_data)

## Establece el modo de juego
func set_game_mode(mode: GameMode.Mode, email: String = "") -> void:
	"""Cambia el modo de juego (Guest/Account)"""
	if game_mode:
		game_mode.set_mode(mode, email)
		if mode == GameMode.Mode.GUEST:
			_log("Modo Guest: Progreso guardado localmente (no sincronizado)")
		elif mode == GameMode.Mode.ACCOUNT:
			if email != "":
				_log("Modo Account: Sincronización con Google Play activada")
			else:
				_log("Modo Account: Progreso guardado localmente (sin sincronización)")

## Obtiene el estado actual de sincronización
func get_sync_status() -> Dictionary:
	"""Retorna información sobre el estado de sincronización"""
	return secure_save.get_sync_status()

## Vincula una cuenta de Google Play
func link_google_play_account(email: String) -> bool:
	"""Vincula la actual sesión a una cuenta de Google Play para sincronización"""
	if not game_mode:
		return false
	
	game_mode.set_mode(GameMode.Mode.ACCOUNT, email)
	_log("Cuenta de Google Play vinculada: %s" % email)
	
	# Sincronizar datos actuales
	return secure_save.sync_to_cloud(save_data)

## Desvincula la cuenta de Google Play
func unlink_google_play_account() -> void:
	"""Desvincula la cuenta de Google Play (vuelve a guardar solo localmente)"""
	if not game_mode:
		return
	
	secure_save.clear_cloud_sync()
	game_mode.set_mode(GameMode.Mode.GUEST)
	_log("Cuenta de Google Play desvinculada")

## FUNCIONES AUXILIARES PARA any_row_attack

func _find_best_target_lane_for_archer(archer_player: int, archer_lane: int) -> int:
	"""Encuentra el mejor carril diferente al del arquero para atacar"""
	var best_lane = -1
	var best_score = -999
	
	for lane_idx in range(LANE_COUNT):
		# No atacar el mismo carril donde está
		if lane_idx == archer_lane:
			continue
		
		var defender = board[lane_idx][1 - archer_player]
		
		# Priorizar carriles con enemigos
		if defender != null:
			var score = defender.get_effective_attack() + defender.data.hp
			if score > best_score:
				best_score = score
				best_lane = lane_idx
	
	# Si no hay enemigos en otros carriles, atacar base (carril -1 es base)
	if best_lane < 0:
		best_lane = 0  # Carril vacío por defecto
	
	return best_lane

func resolve_lane_combat_custom(lane_index: int, attacking_player: int, attacker: CardUnit) -> void:
	"""Resuelve combate en un carril específico con un atacante definido
	Usado por any_row_attack para atacar desde un carril diferente"""
	var defender: CardUnit = board[lane_index][1 - attacking_player]

	if not attacker.is_alive() or not attacker.can_act():
		return
	
	if attacker.data.has_attacked_this_turn:
		return

	if defender == null:
		base_hp[1 - attacking_player] -= attacker.get_effective_attack()
		attacker.data.has_attacked_this_turn = true
		_log("%s (arquero) golpea la base enemiga desde carril distante por %d." % [attacker.data.name, attacker.get_effective_attack()])
		_check_game_over()
		return

	var attack_value := _calculate_attack_power(attacker, defender)

	if attacker.data.ability == "first_strike_bonus" and attacker.data.silenced_turns <= 0:
		attack_value = int(round(attack_value * 1.5))

	if defender.data.dodge_chance > 0.0 and rng.randf() <= defender.data.dodge_chance:
		attacker.data.has_attacked_this_turn = true
		_log("%s esquiva el ataque a distancia de %s." % [defender.data.name, attacker.data.name])
		return

	var damage_done := defender.receive_damage(attack_value)
	_log("%s (arquero) ataca a distancia a %s por %d." % [attacker.data.name, defender.data.name, damage_done])

	if defender.data.reflect_ratio > 0.0 and defender.data.silenced_turns <= 0:
		var reflected := int(round(damage_done * defender.data.reflect_ratio))
		attacker.receive_damage(reflected)
		_log("%s refleja %d de daño." % [defender.data.name, reflected])

	if not defender.is_alive():
		_handle_death(defender, lane_index)

	if not attacker.is_alive():
		_handle_death(attacker, attacker.data.lane)

	attacker.data.has_attacked_this_turn = true
	_check_game_over()

func _log(text: String) -> void:
	emit_signal("log_updated", text)
