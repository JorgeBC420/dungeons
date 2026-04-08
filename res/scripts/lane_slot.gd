# res://scripts/lane_slot.gd
extends PanelContainer
class_name LaneSlot

signal card_dropped(hand_index: int, lane_index: int, player: int)

@export var lane_index: int = 0
@export var player_side: int = 0
@export var title_label: Label
@export var card_holder: Control

func _ready() -> void:
	_update_title()

func _update_title() -> void:
	var side_name := "Jugador" if player_side == 0 else "Enemigo"
	title_label.text = "%s - Carril %d" % [side_name, lane_index + 1]

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if typeof(data) != TYPE_DICTIONARY:
		return false
	if not data.has("type"):
		return false
	if data.type != "card_from_hand":
		return false
	if data.card_owner != player_side:
		return false
	return true

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	emit_signal("card_dropped", data.hand_index, lane_index, data.card_owner)
