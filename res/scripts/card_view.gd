# res://scripts/card_view.gd
extends PanelContainer
class_name CardView

signal card_clicked(card_view: CardView)

@export var portrait: TextureRect
@export var name_label: Label
@export var stats_label: Label
@export var faction_label: Label
@export var role_label: Label
@export var ability_label: Label
@export var rarity_label: Label

var card_unit: CardUnit
var hand_index: int = -1
var owner: int = 0
var draggable := true

func setup(unit: CardUnit, index: int, unit_owner: int) -> void:
	card_unit = unit
	hand_index = index
	owner = unit_owner
	_update_ui()

func _update_ui() -> void:
	if card_unit == null:
		return

	# Usar traducciones para nombres de cartas y habilidades
	name_label.text = tr("card_%s_name" % card_unit.data.id)
	stats_label.text = "%s %d / %s %d" % [tr("ui_atk"), card_unit.data.atk, tr("ui_hp"), card_unit.data.hp]
	faction_label.text = tr("faction_%s" % card_unit.data.faction)
	role_label.text = tr("role_%s" % card_unit.data.role)
	ability_label.text = tr("ability_%s" % card_unit.data.ability)
	rarity_label.text = card_unit.data.rarity
	
	# Cargar imagen
	var portrait_texture = CardImageMapper.get_card_portrait(card_unit.data.id)
	if portrait_texture != null and portrait != null:
		portrait.texture = portrait_texture

	match card_unit.data.faction:
		"human":
			modulate = Color(0.85, 0.95, 1.0)
		"orc":
			modulate = Color(0.9, 1.0, 0.85)
		"elf":
			modulate = Color(0.9, 0.85, 1.0)
		_:
			modulate = Color.WHITE

func set_board_mode() -> void:
	draggable = false

func _get_drag_data(_at_position: Vector2) -> Variant:
	if not draggable:
		return null

	var preview := duplicate()
	preview.modulate = Color(1, 1, 1, 0.85)
	set_drag_preview(preview)

	return {
		"type": "card_from_hand",
		"hand_index": hand_index,
		"owner": owner,
		"card_id": card_unit.data.id
	}
