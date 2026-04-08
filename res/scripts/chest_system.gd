# res://scripts/chest_system.gd
extends Node
class_name ChestSystem

## Sistema de cofres desbloqueables por publicidad

enum ChestType { COMMON, RARE, EPIC }

const CHEST_REWARDS = {
	ChestType.COMMON: {
		"coins_min": 10,
		"coins_max": 30,
		"cards": 1
	},
	ChestType.RARE: {
		"coins_min": 50,
		"coins_max": 100,
		"cards": 2
	},
	ChestType.EPIC: {
		"coins_min": 150,
		"coins_max": 300,
		"cards": 3
	}
}

signal chest_opened(chest_type: ChestType, coins: int, cards_count: int)

var rng = RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()

## Abre un cofre y otorga recompensas
func open_chest(chest_type: ChestType) -> Dictionary:
	"""Abre un cofre y retorna la recompensa"""
	
	var reward_data = CHEST_REWARDS.get(chest_type)
	if reward_data == null:
		push_error("Unknown chest type: %s" % chest_type)
		return {}
	
	var coins = rng.randi_range(reward_data.coins_min, reward_data.coins_max)
	var cards_count = reward_data.cards
	
	var reward = {
		"type": chest_type,
		"coins": coins,
		"cards": cards_count,
		"card_ids": _generate_random_cards(cards_count)
	}
	
	chest_opened.emit(chest_type, coins, cards_count)
	
	var chest_type_names = {ChestType.COMMON: "COMMON", ChestType.RARE: "RARE", ChestType.EPIC: "EPIC", ChestType.LEGENDARY: "LEGENDARY"}
	var chest_name = chest_type_names.get(chest_type, "UNKNOWN")
	print("CHEST OPENED: %s - Coins: %d, Cards: %d" % [chest_name, coins, cards_count])
	
	return reward

## Genera IDs aleatorios de cartas para el cofre
func _generate_random_cards(count: int) -> Array:
	"""Retorna array de IDs de cartas aleatorias"""
	var all_cards = CardDatabase.get_card_data().keys()
	var selected_cards = []
	
	for i in range(count):
		var random_card = all_cards[rng.randi() % all_cards.size()]
		selected_cards.append(random_card)
	
	return selected_cards

## Retorna el nombre del cofre
func get_chest_name(chest_type: ChestType) -> String:
	match chest_type:
		ChestType.COMMON:
			return tr("chest_common")
		ChestType.RARE:
			return tr("chest_rare")
		ChestType.EPIC:
			return tr("chest_epic")
	return "Unknown"

## Retorna descripción del cofre
func get_chest_description(chest_type: ChestType) -> String:
	var rewards = CHEST_REWARDS[chest_type]
	return "%s--%d: %d-%d %s" % [
		get_chest_name(chest_type),
		rewards.cards,
		rewards.coins_min,
		rewards.coins_max,
		tr("ui_coins")
	]
