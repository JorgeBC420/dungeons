# res://scripts/ads/ads_manager.gd
extends Node
class_name AdsManager

## Sistema de recompensas por publicidad
## Integración futura: Google Mobile Ads SDK

enum RewardType { COINS, COMMON_CHEST, RARE_CHEST, CARDS }

const REWARD_AMOUNTS = {
	RewardType.COINS: 50,  # Monedas por ver anuncio
	RewardType.COMMON_CHEST: 1,  # 1 cofre común
	RewardType.RARE_CHEST: 1    # 1 cofre raro
}

signal ad_reward_granted(reward_type: RewardType, amount: int)
signal ad_skipped()
signal ad_error(error_code: int)

var is_ad_showing: bool = false
var pending_reward: RewardType = RewardType.COINS

# TODO: Integración real con Google Mobile Ads
# var ads_service: GoogleMobileAds = null

func _ready() -> void:
	# En producción, inicializar Google Mobile Ads aquí
	# ads_service = GoogleMobileAds.new()
	# ads_service.initialize("ID_APLICACION")
	pass

## Muestra un anuncio recompensado
func show_rewarded_ad(reward_type: RewardType) -> bool:
	"""
	Muestra un anuncio recompensado. Retorna true si se puede mostrar.
	En desarrollo, esto es inmediato. En producción, espera carga del SDK.
	"""
	if is_ad_showing:
		push_warning("Ad already showing")
		return false
	
	pending_reward = reward_type
	is_ad_showing = true
	
	# Simulación: en producción sería ads_service.show_rewarded_ad()
	_simulate_ad_watch()
	
	return true

## Simula ver un anuncio completo
func _simulate_ad_watch() -> void:
	"""Para testing: simula que el usuario vio el anuncio completo"""
	await get_tree().create_timer(2.0).timeout  # Esperar 2 segundos
	_grant_reward()

## Llamado cuando el usuario ve el anuncio completo
func _grant_reward() -> void:
	"""Otorga la recompensa al jugador"""
	if not is_ad_showing:
		return
	
	is_ad_showing = false
	
	var reward_amount = REWARD_AMOUNTS.get(pending_reward, 0)
	
	# Emitir señal de recompensa
	ad_reward_granted.emit(pending_reward, reward_amount)
	
	var reward_type_names = {RewardType.COINS: "COINS", RewardType.CARDS: "CARDS"}
	var reward_name = reward_type_names.get(pending_reward, "UNKNOWN")
	print("AD REWARD: %s x%d" % [reward_name, reward_amount])

## Llamado si el usuario salta/cierra el anuncio
func _on_ad_skipped() -> void:
	"""Si el usuario salta el ad, no recibe recompensa"""
	is_ad_showing = false
	ad_skipped.emit()
	print("Ad skipped - no reward granted")

## Llamado si hay error cargando el ad
func _on_ad_error(error_code: int) -> void:
	"""Si falla cargar el anuncio"""
	is_ad_showing = false
	ad_error.emit(error_code)
	push_error("Ad error: %d" % error_code)

## Retorna true si un ad está disponible para mostrar
func is_ad_available(reward_type: RewardType) -> bool:
	"""En producción, verifica si Google Mobile Ads tiene un ad listo"""
	# TODO: ads_service.is_rewarded_ad_loaded()
	return true  # Por ahora siempre disponible para testing

## Muestra ad de recompensa por monedas
func show_ad_for_coins() -> bool:
	return show_rewarded_ad(RewardType.COINS)

## Muestra ad para desbloquear cofre común
func show_ad_for_common_chest() -> bool:
	return show_rewarded_ad(RewardType.COMMON_CHEST)

## Muestra ad para desbloquear cofre raro
func show_ad_for_rare_chest() -> bool:
	return show_rewarded_ad(RewardType.RARE_CHEST)

## Retorna texto legible del tipo de recompensa
func get_reward_text(reward_type: RewardType) -> String:
	match reward_type:
		RewardType.COINS:
			return tr("reward_coins") % REWARD_AMOUNTS[reward_type]
		RewardType.COMMON_CHEST:
			return tr("reward_common_chest")
		RewardType.RARE_CHEST:
			return tr("reward_rare_chest")
	return "Unknown reward"
