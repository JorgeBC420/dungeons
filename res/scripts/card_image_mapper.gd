# res://scripts/card_image_mapper.gd
extends Node
class_name CardImageMapper

"""
Este script enlaza automáticamente las cartas con sus imágenes en los assets.
Mapea cada card_id con su ruta de imagen correspondiente.
"""

static func get_image_path(card_id: String, faction: String) -> String:
	"""Retorna la ruta de la imagen basada en el ID de carta y facción"""
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
		return null
	
	var image_path = get_image_path(card_id, card_data.faction)
	
	if ResourceLoader.exists(image_path):
		return ResourceLoader.load(image_path)
	else:
		push_warning("Card portrait not found: %s" % image_path)
		return null

# Mapeo automático de cartas con sus imágenes
static var CARD_IMAGE_MAP = {
	# HUMANOS
	"paladin_alba": "res://assets/humans/paladin_alba.png",
	"medico_campo": "res://assets/humans/medico_campo.png",
	"caballero_real": "res://assets/humans/caballero_real.png",
	"inquisidor_hierro": "res://assets/humans/inquisidor_hierro.png",
	"arquero_muralla": "res://assets/humans/arquero_muralla.png",
	"herrero_imperial": "res://assets/humans/herrero_imperial.png",
	"hechicero_corte": "res://assets/humans/hechicero_corte.png",
	"escudero_novato": "res://assets/humans/escudero_novato.png",
	"general_valerius": "res://assets/humans/general_valerius.png",
	
	# ORCOS
	"berserker_feroz": "res://assets/orcs/berserker_feroz.png",
	"chaman_sangre": "res://assets/orcs/chaman_sangre.png",
	"jinete_lobo": "res://assets/orcs/jinete_lobo.png",
	"rompefilas": "res://assets/orcs/rompefilas.png",
	"lanzador_hachas": "res://assets/orcs/lanzador_hachas.png",
	"brujo_sombras": "res://assets/orcs/brujo_sombras.png",
	"capataz_esclavos": "res://assets/orcs/capataz_esclavos.png",
	"trasgo_saqueador": "res://assets/orcs/trasgo_saqueador.png",
	"gran_jefe_gromm": "res://assets/orcs/gran_jefe_gromm.png",
	
	# ELFOS
	"guardian_bosque": "res://assets/elf/guardian_bosque.png",
	"curandero_sagrado": "res://assets/elf/curandero_sagrado.png",
	"arquero_maestro": "res://assets/elf/arquero_maestro.png",
	"asesino_sombrio": "res://assets/elf/asesino_sombrio.png",
	"druida_formas": "res://assets/elf/druida_formas.png",
	"cantante_viento": "res://assets/elf/cantante_viento.png",
	"tejedora_hechizos": "res://assets/elf/tejedora_hechizos.png",
	"explorador_silvano": "res://assets/elf/explorador_silvano.png",
	"reina_estrellas": "res://assets/elf/reina_estrellas.png",
}
