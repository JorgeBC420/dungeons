# res://scripts/card_image_mapper.gd
extends Node
class_name CardImageMapper

"""
Sistema de mapeo automático de cartas con sus imágenes.
Fuente de verdad: convención de nombres en directorio (faction/card_id.png)
No requiere mantenimiento manual de mapeo.
"""

static func get_image_path(card_id: String, faction: String) -> String:
	"""Retorna la ruta de la imagen basada en el ID de carta y facción
	Patrón: res://assets/[faction]/[card_id].png
	Ejemplo: res://assets/humans/paladin_alba.png
	"""
	return "res://assets/%s/%s.png" % [_get_faction_folder(faction), card_id]

static func _get_faction_folder(faction: String) -> String:
	"""Obtiene la carpeta correcta para cada facción"""
	match faction:
		CardDatabase.FACTION_HUMAN:
			return "humans"
		CardDatabase.FACTION_ORC:
			return "orcs"
		CardDatabase.FACTION_ELF:
			return "elf"
		_:
			return "humans"

static func get_card_portrait(card_id: String) -> Texture2D:
	"""Obtiene la textura de la imagen de la carta"""
	var card_data = CardDatabase.get_card_data().get(card_id)
	
	if card_data == null:
		push_warning("Card data not found: %s" % card_id)
		return null
	
	var image_path = get_image_path(card_id, card_data.faction)
	
	if ResourceLoader.exists(image_path):
		return ResourceLoader.load(image_path)
	else:
		push_warning("Card portrait not found: %s" % image_path)
		return null
