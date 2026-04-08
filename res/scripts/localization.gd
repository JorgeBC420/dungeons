# res://scripts/localization.gd
extends Node
class_name Localization

signal language_changed(language: String)

const SUPPORTED_LANGUAGES = ["es", "en", "pt"]
const DEFAULT_LANGUAGE = "es"

var current_language: String = DEFAULT_LANGUAGE
var translations: Dictionary = {}

func _ready() -> void:
	_load_translations()
	_detect_system_language()

func _detect_system_language() -> void:
	var system_lang = OS.get_locale_language()
	
	match system_lang:
		"pt":
			set_language("pt")
		"en":
			set_language("en")
		"es":
			set_language("es")
		_:
			set_language(DEFAULT_LANGUAGE)

func set_language(lang: String) -> void:
	if lang not in SUPPORTED_LANGUAGES:
		push_warning("Lenguaje no soportado: %s" % lang)
		return
	
	current_language = lang
	
	# Usa el sistema de traducción de Godot
	TranslationServer.set_locale(lang)
	
	emit_signal("language_changed", lang)

func get_language() -> String:
	return current_language

func _load_translations() -> void:
	# En Godot 4, las traducciones se cargan desde archivos .po o son automáticas
	# Si configuraste los archivos de traducción en Project Settings > Localization
	pass

# Funciones de traducción
func tr_card_name(card_id: String) -> String:
	return _get_translation("card_%s_name" % card_id)

func tr_card_ability(ability: String) -> String:
	return _get_translation("ability_%s" % ability)

func tr_role(role: String) -> String:
	return _get_translation("role_%s" % role)

func tr_faction(faction: String) -> String:
	return _get_translation("faction_%s" % faction)

func tr_ui(key: String) -> String:
	return _get_translation("ui_%s" % key)

func _get_translation(key: String) -> String:
	# Usa el sistema de traducción de Godot
	var translated = tr(key)
	return translated if translated != key else key
