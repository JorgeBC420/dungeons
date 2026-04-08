# res://scripts/card_database.gd
extends Node
class_name CardDatabase

const FACTION_HUMAN := "human"
const FACTION_ORC := "orc"
const FACTION_ELF := "elf"

const ROLE_TANK := "tank"
const ROLE_DAMAGE := "damage"
const ROLE_SUPPORT := "support"
const ROLE_MAGIC := "magic"
const ROLE_CANNON := "cannon"
const ROLE_CONTROL := "control"
const ROLE_LEGENDARY := "legendary"

const BASE_STATS := {
	ROLE_TANK: {"atk": 3, "hp": 10},
	ROLE_DAMAGE: {"atk": 7, "hp": 4},
	ROLE_SUPPORT: {"atk": 4, "hp": 6},
	ROLE_MAGIC: {"atk": 4, "hp": 6},
	ROLE_CANNON: {"atk": 4, "hp": 5},
	ROLE_CONTROL: {"atk": 4, "hp": 6},
	ROLE_LEGENDARY: {"atk": 6, "hp": 8},
}

static func get_stats_for_role(role: String, level: int) -> Dictionary:
	var base := BASE_STATS.get(role, {"atk": 4, "hp": 6})
	return {
		"atk": base.atk + (level - 1),
		"hp": base.hp + ((level - 1) * 2)
	}

static func get_card_data() -> Dictionary:
	return {
		# HUMANOS
		"paladin_alba": {
			"id": "paladin_alba", "name": "Paladín del Alba", "faction": FACTION_HUMAN,
			"role": ROLE_TANK, "ability": "ignore_first_hit", "rarity": "common",
			"portrait": "res://assets/humans/paladin_alba.png"
		},
		"medico_campo": {
			"id": "medico_campo", "name": "Médico de Campo", "faction": FACTION_HUMAN,
			"role": ROLE_SUPPORT, "ability": "heal_adjacent", "rarity": "common"
		},
		"caballero_real": {
			"id": "caballero_real", "name": "Caballero Real", "faction": FACTION_HUMAN,
			"role": ROLE_DAMAGE, "ability": "first_strike_bonus", "rarity": "rare"
		},
		"inquisidor_hierro": {
			"id": "inquisidor_hierro", "name": "Inquisidor de Hierro", "faction": FACTION_HUMAN,
			"role": ROLE_CONTROL, "ability": "silence", "rarity": "rare"
		},
		"arquero_muralla": {
			"id": "arquero_muralla", "name": "Arquero de Muralla", "faction": FACTION_HUMAN,
			"role": ROLE_DAMAGE, "ability": "any_row_attack", "rarity": "common"
		},
		"herrero_imperial": {
			"id": "herrero_imperial", "name": "Herrero Imperial", "faction": FACTION_HUMAN,
			"role": ROLE_SUPPORT, "ability": "buff_ally", "rarity": "common"
		},
		"hechicero_corte": {
			"id": "hechicero_corte", "name": "Hechicero de la Corte", "faction": FACTION_HUMAN,
			"role": ROLE_MAGIC, "ability": "small_aoe", "rarity": "rare"
		},
		"escudero_novato": {
			"id": "escudero_novato", "name": "Escudero Novato", "faction": FACTION_HUMAN,
			"role": ROLE_CANNON, "ability": "bodyguard", "rarity": "common"
		},
		"general_valerius": {
			"id": "general_valerius", "name": "General Valerius", "faction": FACTION_HUMAN,
			"role": ROLE_LEGENDARY, "ability": "human_global_buff", "rarity": "legendary"
		},

		# ORCOS
		"berserker_feroz": {
			"id": "berserker_feroz", "name": "Berserker Feroz", "faction": FACTION_ORC,
			"role": ROLE_DAMAGE, "ability": "fury", "rarity": "common"
		},
		"chaman_sangre": {
			"id": "chaman_sangre", "name": "Chamán de Sangre", "faction": FACTION_ORC,
			"role": ROLE_SUPPORT, "ability": "life_drain_transfer", "rarity": "rare"
		},
		"jinete_lobo": {
			"id": "jinete_lobo", "name": "Jinete de Lobo", "faction": FACTION_ORC,
			"role": ROLE_DAMAGE, "ability": "dodge_20", "rarity": "common"
		},
		"rompefilas": {
			"id": "rompefilas", "name": "Rompefilas", "faction": FACTION_ORC,
			"role": ROLE_TANK, "ability": "taunt", "rarity": "common"
		},
		"lanzador_hachas": {
			"id": "lanzador_hachas", "name": "Lanzador de Hachas", "faction": FACTION_ORC,
			"role": ROLE_DAMAGE, "ability": "bleed", "rarity": "common"
		},
		"brujo_sombras": {
			"id": "brujo_sombras", "name": "Brujo de las Sombras", "faction": FACTION_ORC,
			"role": ROLE_MAGIC, "ability": "curse_half", "rarity": "rare"
		},
		"capataz_esclavos": {
			"id": "capataz_esclavos", "name": "Capataz de Esclavos", "faction": FACTION_ORC,
			"role": ROLE_SUPPORT, "ability": "sacrifice_extra_attack", "rarity": "rare"
		},
		"trasgo_saqueador": {
			"id": "trasgo_saqueador", "name": "Trasgo Saqueador", "faction": FACTION_ORC,
			"role": ROLE_CANNON, "ability": "steal_coin_on_death", "rarity": "common"
		},
		"gran_jefe_gromm": {
			"id": "gran_jefe_gromm", "name": "Gran Jefe Gromm", "faction": FACTION_ORC,
			"role": ROLE_LEGENDARY, "ability": "immediate_attack", "rarity": "legendary"
		},

		# ELFOS
		"guardian_bosque": {
			"id": "guardian_bosque", "name": "Guardián del Bosque", "faction": FACTION_ELF,
			"role": ROLE_TANK, "ability": "reflect_30", "rarity": "common"
		},
		"curandero_sagrado": {
			"id": "curandero_sagrado", "name": "Curandero Sagrado", "faction": FACTION_ELF,
			"role": ROLE_SUPPORT, "ability": "revive_low_level", "rarity": "rare"
		},
		"arquero_maestro": {
			"id": "arquero_maestro", "name": "Arquero Maestro", "faction": FACTION_ELF,
			"role": ROLE_DAMAGE, "ability": "triple_shot", "rarity": "rare"
		},
		"asesino_sombrio": {
			"id": "asesino_sombrio", "name": "Asesino Sombrío", "faction": FACTION_ELF,
			"role": ROLE_DAMAGE, "ability": "stealth_first_turn", "rarity": "rare"
		},
		"druida_formas": {
			"id": "druida_formas", "name": "Druida de Formas", "faction": FACTION_ELF,
			"role": ROLE_MAGIC, "ability": "transform_bear", "rarity": "rare"
		},
		"cantante_viento": {
			"id": "cantante_viento", "name": "Cantante de Viento", "faction": FACTION_ELF,
			"role": ROLE_SUPPORT, "ability": "double_skill", "rarity": "rare"
		},
		"tejedora_hechizos": {
			"id": "tejedora_hechizos", "name": "Tejedora de Hechizos", "faction": FACTION_ELF,
			"role": ROLE_MAGIC, "ability": "freeze", "rarity": "rare"
		},
		"explorador_silvano": {
			"id": "explorador_silvano", "name": "Explorador Silvano", "faction": FACTION_ELF,
			"role": ROLE_CANNON, "ability": "scout", "rarity": "common"
		},
		"reina_estrellas": {
			"id": "reina_estrellas", "name": "Reina de las Estrellas", "faction": FACTION_ELF,
			"role": ROLE_LEGENDARY, "ability": "kill_strongest", "rarity": "legendary"
		},
	}

static func create_card_instance(card_id: String, level: int = 1) -> Dictionary:
	var data := get_card_data().get(card_id, {})
	if data.is_empty():
		push_error("Carta no encontrada: %s" % card_id)
		return {}

	var stats := get_stats_for_role(data.role, level)

	return {
		"id": data.id,
		"name": data.name,
		"faction": data.faction,
		"role": data.role,
		"ability": data.ability,
		"rarity": data.rarity,
		"level": level,
		"atk": stats.atk,
		"max_hp": stats.hp,
		"hp": stats.hp,
		"silenced_turns": 0,
		"frozen_turns": 0,
		"bleed_turns": 0,
		"bleed_damage": 0,
		"ignored_first_hit": false,
		"stealth_turns": 0,
		"taunt": false,
		"dodge_chance": 0.0,
		"reflect_ratio": 0.0,
		"first_turn_played": true,
		"owner": 0,
		"lane": -1,
		"has_attacked_this_turn": false,
		"extra_skill_uses": 0,
		"bodyguard_for_paladin": false
	}
