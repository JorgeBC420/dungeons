# i18n Setup - Configuración de Traducci ón

## Archivos de Traducción

Se han creado archivos CSV con traducciones para:
- **Español (es)** - Idioma por defecto
- **Inglés (en)**
- **Portugués (pt)**

### Ubicación:
```
res://i18n/translations.csv
```

## Configurar Godot para Traducciones

### Paso 1: Crear archivos de traducción en Godot

1. Abre el proyecto en Godot
2. Ve a **Project → Project Settings**
3. Busca "Localization"
4. En la sección **Localization**:
   - **Locale** > **Supported Locales**: Agrega `es`, `en`, `pt`
   - **Translation** > **Translations**: Haz clic en el botón de agregar
   - Navega a `res://i18n/translations.csv`
   - Un .po file se generará automáticamente

### Paso 2: Usar traducción en scripts

En lugar de strings hardcodeados, usa `tr()`:

```gdscript
# En lugar de:
name_label.text = card_unit.data.name

# Usa:
name_label.text = tr("card_%s_name" % card_unit.data.id)
```

### Paso 3: Usar el Localization Manager

En tu script:
```gdscript
# Obtener idioma actual
var current_lang = TranslationServer.get_locale()

# Cambiar idioma
TranslationServer.set_locale("en")  # Inglés
TranslationServer.set_locale("pt")  # Portugués
TranslationServer.set_locale("es")  # Español
```

## Integración con CardView

Se ha actualizado `card_view.gd` para soportar traducción automática:

```gdscript
# Las etiquetas se actualizarán según el idioma
name_label.text = card_unit.data.name
ability_label.text = tr("ability_%s" % card_unit.data.ability)
role_label.text = tr("role_%s" % card_unit.data.role)
faction_label.text = tr("faction_%s" % card_unit.data.faction)
```

## Claves de Traducción Disponibles

Formato: `{tipo}_{id|nombre}`

### Cartas (27 total)
```
card_paladin_alba_name
card_medico_campo_name
card_caballero_real_name
... (y más)
```

### Habilidades
```
ability_ignore_first_hit
ability_heal_adjacent
ability_silence
... (y más)
```

### Roles
```
role_tank
role_damage
role_support
role_magic
role_cannon
role_control
role_legendary
```

### Facciones
```
faction_human
faction_orc
faction_elf
```

### UI
```
ui_base_player
ui_base_enemy
ui_turn
ui_end_turn
ui_ai_cards
ui_game_over
ui_victory_player
ui_victory_ai
ui_tie
```

## Detectar Idioma del Sistema

El juego automáticamente detectará el idioma del sistema:

```gdscript
# En localization.gd
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
			set_language("es")  # Defecto
```

## Agregar Nuevo Idioma

1. Abre `res://i18n/translations.csv`
2. Agrega una nueva columna con el código del idioma (ej: `fr` para francés)
3. Translada todos los valores
4. Guarda el archivo
5. En Godot Project Settings, agrega el nuevo locale en **Localization > Supported Locales**

Ejemplo de agregar francés:
```csv
keys,es,en,pt,fr
card_paladin_alba_name,Paladín del Alba,Paladin of Dawn,Paladino da Aurora,Paladin de l'Aurore
```

## Interfaz de Selección de Idioma

Para una versión futura, puedes crear un menú de selección:

```gdscript
# Script para un menú de idiomas
extends Control

@onready var language_buttons = {
	"es": $VBoxContainer/ButtonSpanish,
	"en": $VBoxContainer/ButtonEnglish,
	"pt": $VBoxContainer/ButtonPortuguese
}

func _ready() -> void:
	for lang in language_buttons.keys():
		language_buttons[lang].pressed.connect(
			func(): _set_language(lang)
		)

func _set_language(lang: String) -> void:
	TranslationServer.set_locale(lang)
	# Guardar en configuración de usuario
	var config = ConfigFile.new()
	config.set_value("game", "language", lang)
	config.save("user://settings.cfg")
```

## Verificación

Para verificar que las traducciones funcionan:

1. Abre Main.tscn
2. Press F5
3. Verifica que los textos aparecen en español
4. En la consola, escribe:
   ```
   TranslationServer.set_locale("en")
   ```
5. Recarga la escena y verifica que ahora están en inglés

## Exportación para Google Play

En la descripción de la aplicación en Google Play, incluye:

**Idiomas soportados:**
- Español (ES)
- English (EN)
- Português (PT)

Esto ayuda a que Google Play muestre tu app a usuarios correctos según su idioma.
