# res://scripts/main_ui.gd
extends Control
class_name MainUI

@export var game_manager_path: NodePath

@export var player_hand_container: HBoxContainer
@export var enemy_hand_info: Label

@export var player_lane_slots: Array[LaneSlot]
@export var enemy_lane_slots: Array[LaneSlot]

@export var player_base_label: Label
@export var enemy_base_label: Label
@export var turn_label: Label
@export var log_label: RichTextLabel

@export var end_turn_button: Button
@export var card_view_scene: PackedScene

var game_manager: GameManager

func _ready() -> void:
	game_manager = get_node(game_manager_path)

	game_manager.board_changed.connect(_refresh_board)
	game_manager.hand_changed.connect(_refresh_hand)
	game_manager.turn_changed.connect(_on_turn_changed)
	game_manager.log_updated.connect(_append_log)
	game_manager.game_over.connect(_on_game_over)

	for slot in player_lane_slots:
		slot.card_dropped.connect(_on_card_dropped)

	_refresh_hand(0)
	_refresh_hand(1)
	_refresh_board()
	_on_turn_changed(game_manager.current_player, game_manager.turn_number)

func _on_card_dropped(hand_index: int, lane_index: int, player: int) -> void:
	game_manager.play_card_from_hand(player, hand_index, lane_index)

func _refresh_hand(player: int) -> void:
	if player == GameManager.PLAYER_1:
		for child in player_hand_container.get_children():
			child.queue_free()

		var hand := game_manager.get_hand(GameManager.PLAYER_1)
		for i in range(hand.size()):
			var card_ui: CardView = card_view_scene.instantiate()
			player_hand_container.add_child(card_ui)
			card_ui.setup(hand[i], i, GameManager.PLAYER_1)
	else:
		enemy_hand_info.text = "Cartas IA: %d" % game_manager.get_hand(GameManager.PLAYER_2).size()

func _refresh_board() -> void:
	player_base_label.text = "Base jugador: %d" % game_manager.base_hp[GameManager.PLAYER_1]
	enemy_base_label.text = "Base enemigo: %d" % game_manager.base_hp[GameManager.PLAYER_2]

	for lane_idx in range(3):
		_clear_holder(player_lane_slots[lane_idx].card_holder)
		_clear_holder(enemy_lane_slots[lane_idx].card_holder)

		var player_unit := game_manager.get_unit_at(lane_idx, GameManager.PLAYER_1)
		if player_unit != null:
			var card_ui: CardView = card_view_scene.instantiate()
			player_lane_slots[lane_idx].card_holder.add_child(card_ui)
			card_ui.setup(player_unit, -1, GameManager.PLAYER_1)
			card_ui.set_board_mode()

		var enemy_unit := game_manager.get_unit_at(lane_idx, GameManager.PLAYER_2)
		if enemy_unit != null:
			var card_ui2: CardView = card_view_scene.instantiate()
			enemy_lane_slots[lane_idx].card_holder.add_child(card_ui2)
			card_ui2.setup(enemy_unit, -1, GameManager.PLAYER_2)
			card_ui2.set_board_mode()

func _clear_holder(holder: Control) -> void:
	for child in holder.get_children():
		child.queue_free()

func _on_turn_changed(current_player: int, turn_number: int) -> void:
	var who := "Jugador" if current_player == GameManager.PLAYER_1 else "IA"
	turn_label.text = "Turno %d - %s" % [turn_number, who]
	end_turn_button.disabled = current_player != GameManager.PLAYER_1

func _append_log(text: String) -> void:
	log_label.append_text(text + "\n")

func _on_end_turn_button_pressed() -> void:
	if game_manager.current_player == GameManager.PLAYER_1:
		game_manager.end_turn()

func _on_game_over(winner: int) -> void:
	if winner == -1:
		_append_log("Empate.")
	elif winner == GameManager.PLAYER_1:
		_append_log("Victoria del jugador.")
	else:
		_append_log("Victoria de la IA.")
	end_turn_button.disabled = true
