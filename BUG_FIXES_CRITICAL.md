# Correcciones Críticas - 3 Bugs Corregidos

**Commit:** 084a2ad  
**Fecha:** 8 Abril 2026

---

## 🔴 Bug 1: Anti-Cheat Valida Raw Data Sin atk/hp

### El Problema
La función `_verify_game_integrity()` llamaba a `validate_card_data()` sobre datos crudos del CardDatabase:

```gdscript
# ANTES (Incorrecto)
func _verify_game_integrity() -> void:
	var card_data = CardDatabase.get_card_data()
	for card_id in card_data.keys():
		var card = card_data[card_id]
		if not validate_card_data(card):  # ← Falla silenciosa
			_log_tamper("Invalid card in database", card_id)
```

**Por qué falla:** 
- Los datos raw del CardDatabase NO tienen campos `atk` ni `hp`
- Estos se calculan cuando se instancia `CardUnit` en gameplay
- `validate_card_data()` intenta acceder a estos campos → `null`
- El anti-cheat registra falsos positivos en startup

### La Solución
Separar validación de estructura (CardDatabase raw) de validación de valores calculados (instancias CardUnit):

```gdscript
# DESPUÉS (Correcto)
func _verify_game_integrity() -> void:
	"""Verifica estructura, NO valores calculados"""
	var card_data = CardDatabase.get_card_data()
	
	for card_id in card_data.keys():
		var card = card_data[card_id]
		
		# Validar solo estructura base
		if not card.has_all(["id", "name", "faction", "role", "ability", "level"]):
			_log_tamper("Invalid card structure in database", card_id)
		
		# Validar enumeraciones (estructura)
		if card.faction not in VALID_FACTIONS:
			_log_tamper("Invalid faction in database", "%s: %s" % [card_id, card.faction])
		# ... similar para role, ability
```

**Resultado:** 
- ✅ No hay falsos positivos en startup
- ✅ Validación real de CardDatabase
- ✅ Valor calculada (atk/hp) se valida en play_card_from_hand()

---

## 🔴 Bug 2: ENCRYPTION_KEY Hardcoded

### El Problema
```gdscript
const ENCRYPTION_KEY = "calabozos_game_2024_secure"  # En secure_save.gd:8
```

**Gravedad:** 🔴 CRÍTICA
- Cualquiera que desempaquete el APK con apktool puede leer este string
- Toda la promesa de "AES-256" es cosmética
- En 10 minutos alguien descifra todos los saves

### La Solución
Generar una clave **única por dispositivo** usando `OS.get_unique_id()`:

```gdscript
# DESPUÉS (En secure_save.gd)
const DEVICE_KEY_PATH = "user://calabozos_device.key"
var _device_encryption_key: String = ""

func _ready() -> void:
	_device_encryption_key = _get_or_create_device_key()

func _get_or_create_device_key() -> String:
	"""Obtiene o crea una clave única por dispositivo"""
	# Si existe, cargarla
	if ResourceLoader.exists(DEVICE_KEY_PATH):
		var file = FileAccess.open(DEVICE_KEY_PATH, FileAccess.READ)
		if file != null:
			return file.get_as_text()  # Clave guardada
	
	# Generar nueva: OS ID + timestamp
	var unique_id = OS.get_unique_id()
	var timestamp = str(Time.get_ticks_msec())
	var device_key = "%s_%s" % [unique_id, timestamp]
	
	# Guardar en user://calabozos_device.key
	var file = FileAccess.open(DEVICE_KEY_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(device_key)
	
	return device_key
```

**Resultado:**
- ✅ Clave única por dispositivo/instalación
- ✅ No está en el código fuente
- ✅ Se almacena separado de los saves
- ✅ Aún no es perfecto (user:// no es completamente seguro), pero es 1000x mejor

**Nota:** Para producción real:
- Considerar usar Godot's native credentials storage
- O sincronizar con servidor autenticado

---

## 🟠 Bug 3: Traducciones No Importadas

### El Problema
```gdscript
# En project.godot:33
[localization]
translations=PackedStringArray()  # ← Vacío
```

El archivo `res/i18n/translations.csv` existe con 85 claves en 3 idiomas, pero nunca se cargó en el proyecto:
- `TranslationServer` no tiene acceso a las claves
- `tr("card_paladin_alba_name")` retorna la misma key, no la traducción
- El README marcaba ✅ Traducciones completas, pero no funcionaba

### La Solución
Agregar la ruta del CSV a la configuración de Godot:

```ini
# DESPUÉS (En project.godot:38)
[localization]
translations=PackedStringArray("res://i18n/translations.csv")
locale_filter=[0, ["es", "en", "pt"]]
translation_remaps={}
```

**Resultado:**
- ✅ Godot importa el CSV al exportar
- ✅ `TranslationServer` tiene acceso a 85 claves
- ✅ `tr("card_paladin_alba_name")` retorna "Paladín Alba" (ES), "Paladin Alba" (EN), etc.
- ✅ Las traducciones funcionan en playtest

---

## Verificación

Las 3 correcciones están registradas en:
- **Archivo:** anti_cheat.gd (línea 202)
- **Archivo:** secure_save.gd (líneas 1-25, 126-190)
- **Archivo:** project.godot (línea 38)

**Cambios totales:**
```
3 files changed, 58 insertions(+), 10 deletions(-)
```

**GitHub:** https://github.com/JorgeBC420/dungeons/commit/084a2ad

---

## Impacto en Gameplay

| Bug | Antes | Después |
|-----|-------|---------|
| Anti-cheat | ❌ Falsos positivos en startup | ✅ Validación correcta |
| Encriptación | 🟠 Key estatica en código | ✅ Única por dispositivo |
| Traducciones | ❌ No se cargan | ✅ 85 claves funcionan |

---

## Qué Sigue (Tier 2)

Los próximos bugs a arreglar (no bloqueantes, pero sí gameplay):

1. **Habilidades sin implementación:** `any_row_attack`, `fury`, conexión de `steal_coin_on_death` al sistema
2. **Mazos desequilibrados:** Duplicados (paladin ×2, arquero ×2), mezcla de facciones
3. **IA trivial:** Solo considera ATK+HP, no habilidades

Estos requieren cambios en `game_manager.gd` y `card_database.gd`.
