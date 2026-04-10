# res://scripts/ui/rewards_panel.gd
extends PanelContainer
class_name RewardsPanel

## Panel de UI para ver anuncios y abrir cofres

@export var ads_manager_path: NodePath
@export var save_data_path: NodePath

# Botones
@export var btn_watch_ad_coins: Button
@export var btn_open_common_chest: Button
@export var btn_open_rare_chest: Button
@export var btn_open_epic_chest: Button

@export var coins_label: Label
@export var reward_log: RichTextLabel

var ads_manager: AdsManager
var chest_system: ChestSystem
var save_data: SaveData

func _ready() -> void:
	if ads_manager_path:
		ads_manager = get_node(ads_manager_path)
		ads_manager.ad_reward_granted.connect(_on_ad_reward_granted)
		ads_manager.ad_skipped.connect(_on_ad_skipped)
		ads_manager.ad_error.connect(_on_ad_error)
	
	if save_data_path:
		save_data = get_node(save_data_path)
	
	# Crear sistema de cofres si no existe
	chest_system = ChestSystem.new()
	add_child(chest_system)
	chest_system.chest_opened.connect(_on_chest_opened)
	
	# Conectar botones
	if btn_watch_ad_coins:
		btn_watch_ad_coins.pressed.connect(_on_watch_ad_coins_pressed)
	
	if btn_open_common_chest:
		btn_open_common_chest.pressed.connect(_on_open_common_chest_pressed)
	
	if btn_open_rare_chest:
		btn_open_rare_chest.pressed.connect(_on_open_rare_chest_pressed)
	
	if btn_open_epic_chest:
		btn_open_epic_chest.pressed.connect(_on_open_epic_chest_pressed)
	
	_update_ui()

func _update_ui() -> void:
	"""Actualiza la UI con el valor actual de monedas"""
	if save_data and coins_label:
		coins_label.text = tr("ui_coins") + ": %d" % save_data.coins

## BOTONES DE ANUNCIOS

func _on_watch_ad_coins_pressed() -> void:
	"""Ver anuncio para ganar monedas"""
	if not ads_manager:
		_log_reward("Error: AdsManager not found")
		return
	
	if ads_manager.show_ad_for_coins():
		_log_reward("Viendo anuncio para ganar monedas...")
		btn_watch_ad_coins.disabled = true
	else:
		_log_reward("No available ads")

## BOTONES DE COFRES

func _on_open_common_chest_pressed() -> void:
	"""Abre un cofre común por anuncio"""
	if not ads_manager:
		_log_reward("Error: AdsManager not found")
		return
	
	if ads_manager.show_ad_for_common_chest():
		_log_reward("Viendo anuncio para desbloquear cofre común...")
		btn_open_common_chest.disabled = true

func _on_open_rare_chest_pressed() -> void:
	"""Abre un cofre raro por anuncio"""
	if not ads_manager:
		_log_reward("Error: AdsManager not found")
		return
	
	if ads_manager.show_ad_for_rare_chest():
		_log_reward("Viendo anuncio para desbloquear cofre raro...")
		btn_open_rare_chest.disabled = true

func _on_open_epic_chest_pressed() -> void:
	"""Abre un cofre épico por anuncio"""
	if not ads_manager:
		_log_reward("Error: AdsManager not found")
		return
	
	if ads_manager.show_ad_for_rare_chest():  # Épico también usa el mismo tipo por ahora
		_log_reward("Viendo anuncio para desbloquear cofre épico...")
		btn_open_epic_chest.disabled = true

## CALLBACKS DE ADS

func _on_ad_reward_granted(reward_type: AdsManager.RewardType, amount: int) -> void:
	"""Llamado cuando se otorga la recompensa del anuncio"""
	
	match reward_type:
		AdsManager.RewardType.COINS:
			_grant_coins_reward(amount)
		AdsManager.RewardType.COMMON_CHEST:
			_open_chest_from_ad(ChestSystem.ChestType.COMMON)
		AdsManager.RewardType.RARE_CHEST:
			_open_chest_from_ad(ChestSystem.ChestType.RARE)
	
	_update_ui()
	btn_watch_ad_coins.disabled = false
	btn_open_common_chest.disabled = false
	btn_open_rare_chest.disabled = false
	btn_open_epic_chest.disabled = false

func _on_ad_skipped() -> void:
	"""Llamado cuando el usuario salta el anuncio"""
	_log_reward("❌ Anuncio saltado - sin recompensa")
	btn_watch_ad_coins.disabled = false
	btn_open_common_chest.disabled = false
	btn_open_rare_chest.disabled = false

func _on_ad_error(error_code: int) -> void:
	"""Llamado cuando hay error con el anuncio"""
	_log_reward("⚠️ Error cargando anuncio: %d" % error_code)
	btn_watch_ad_coins.disabled = false
	btn_open_common_chest.disabled = false
	btn_open_rare_chest.disabled = false

## RECOMPENSAS

func _grant_coins_reward(amount: int) -> void:
	"""Otorga monedas al jugador"""
	if not save_data:
		_log_reward("Error: SaveData not found")
		return
	
	save_data.coins += amount
	_log_reward("✅ +%d monedas" % amount)

func _open_chest_from_ad(chest_type: ChestSystem.ChestType) -> void:
	"""Abre un cofre y otorga su contenido"""
	var reward = chest_system.open_chest(chest_type)
	
	if reward.is_empty():
		_log_reward("Error opening chest")
		return
	
	if save_data:
		save_data.coins += reward.get("coins", 0)
		var cards_count = reward.get("cards", 0)
		_log_reward("✅ Chest opened: +%d coins, +%d cards" % [reward.get("coins", 0), cards_count])
	else:
		_log_reward("Error: SaveData not found")

## CALLBACK DE COFRES

func _on_chest_opened(chest_type: ChestSystem.ChestType, coins: int, cards: int) -> void:
	"""Llamado cuando se abre un cofre"""
	_log_reward("📦 %s chest opened: +%d coins, +%d cards" % [chest_type, coins, cards])

## LOG

func _log_reward(text: String) -> void:
	"""Añade texto al log de recompensas"""
	if reward_log:
		reward_log.append_text("\n" + text)
	
	# Otorgar monedas
	save_data.coins += reward.coins
	
	# Otorgar cartas (agregar al inventario)
	for card_id in reward.card_ids:
		var copies = save_data.get_card_copies(card_id)
		save_data.set_card_copies(card_id, copies + 1)
	
	_log_reward("✨ %s abierto - +%d monedas, +%d cartas" % [
		chest_system.get_chest_name(chest_type),
		reward.coins,
		reward.cards
	])

## LOGGING

func _log_reward(message: String) -> void:
	"""Agrega mensaje al log de recompensas"""
	if reward_log:
		reward_log.append_text(message + "\n")
	else:
		print("REWARD: " + message)
