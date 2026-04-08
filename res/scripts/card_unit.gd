# res://scripts/card_unit.gd
extends RefCounted
class_name CardUnit

var data: Dictionary

func _init(card_data: Dictionary):
	data = card_data.duplicate(true)

func is_alive() -> bool:
	return data.hp > 0

func can_act() -> bool:
	return is_alive() and data.frozen_turns <= 0

func receive_damage(amount: int) -> int:
	if amount <= 0:
		return 0

	if data.ability == "ignore_first_hit" and not data.ignored_first_hit and data.silenced_turns <= 0:
		data.ignored_first_hit = true
		return 0

	data.hp -= amount
	if data.hp < 0:
		data.hp = 0
	return amount

func heal(amount: int) -> void:
	data.hp = min(data.max_hp, data.hp + amount)

func start_turn() -> void:
	data.has_attacked_this_turn = false
	data.first_turn_played = false

	if data.silenced_turns > 0:
		data.silenced_turns -= 1

	if data.frozen_turns > 0:
		data.frozen_turns -= 1

	if data.bleed_turns > 0:
		data.hp -= data.bleed_damage
		data.bleed_turns -= 1
		if data.hp < 0:
			data.hp = 0

func get_attack_bonus_from_missing_hp() -> int:
	if data.ability == "fury" and data.silenced_turns <= 0:
		return data.max_hp - data.hp
	return 0

func get_effective_attack() -> int:
	return data.atk + get_attack_bonus_from_missing_hp()
