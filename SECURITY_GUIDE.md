# Security & Anti-Cheat Guide

## Sistemas de Seguridad Implementados

### 1. Anti-Cheat System (`res://scripts/security/anti_cheat.gd`)

Valida automáticamente:
- **Card Data**: Verifica que todas las cartas sean válidas
- **Game State**: Valida HP, carriles y mano del jugador
- **Card Play**: Valida que movimientos sean legales
- **Stats Impossible**: Detecta stats imposibles para el nivel
- **Card Integrity**: Verifica que los datos no fueron modificados

#### Características:
```gdscript
# Validar datos de carta
if not anti_cheat.validate_card_data(card_data):
	print("Carta inválida detectada")

# Validar estado del juego
if not anti_cheat.validate_game_state(game_manager):
	print("Trampa detectada")

# Validar movimiento
if not anti_cheat.validate_card_play(card, lane, player, game_manager):
	print("Movimiento ilegal")

# Obtener reporte de intentos
var report = anti_cheat.get_tamper_report()
```

#### Señales:
```gdscript
# Se emite cuando se detecta intento de trampa
anti_cheat.tamper_attempt.connect(
	func(reason, details):
		print("Trampa: %s - %s" % [reason, details])
)
```

### 2. Secure Saves (`res://scripts/security/secure_save.gd`)

Protege los datos guardados del jugador:

#### Características:
- **Encriptación AES-256-GCM**: Encripta todos los datos
- **Checksums**: Verifica que no fueron modificados
- **Backup automático**: Crea backup antes de guardar
- **Recuperación**: Si algo falla, carga desde backup

#### Uso:
```gdscript
var secure_save = SecureSave.new()

# Guardar datos
if secure_save.save_player_data(save_data):
	print("Datos guardados con éxito")

# Cargar datos
var loaded_data = secure_save.load_player_data()

# Eliminar datos
secure_save.delete_save_data()
```

#### Sistema de Backup:
```
Ubicación: user://
- calabozos_save.encrypted    (archivo principal)
- calabozos_save.backup       (backup automático)
```

### 3. Validación de Cartas Prohibidas

El sistema detecta y rechaza:
- ❌ IDs de carta inválidos
- ❌ Facciones no reconocidas
- ❌ Roles no existentes
- ❌ Habilidades no permitidas
- ❌ Stats imposibles para el nivel
- ❌ Intentos de modificar HP base
- ❌ Niveles fuera de rango (1-10)

### 4. Detección de Modificación de Memoria

El juego detecta cambios sospechosos:
```gdscript
# Antes de cada acción
if anti_cheat.detect_impossible_stats(card):
	print("Stats imposibles detectados!")
	player.kick_from_game()
```

### 5. Encriptación de Datos

Datos guardados con AES-256-GCM:
```
ENCRYPT(plaintext) = IV + CIPHERTEXT
DECRYPT(encrypted) = plaintext si es válido
```

**Clave de encriptación**: SHA256(ENCRYPTION_KEY)

## Protección Contra Modificación de Archivos

### Cheats Comunes Prevenidos

| Cheat | Prevención |
|-------|-----------|
| Editar save game | Encriptación + checksum |
| Inyectar cartas | Validación de card IDs |
| Aumentar stats | Detección de stats imposibles |
| Infinite coins | Validación de rango |
| Pasar turnos | Validación de current_player |
| Duplicar cartas | Validación de mano |
| Modificar base HP | Rango validado (0-20) |
| Hacks de memoria | Context validation |

## Protección Contra Mods

### 1. Game Scripts Protegida
- Los scripts GDScript están compilados en la versión final
- Los .gd scripts no se incluyen en la exportación
- Imposible modificar gameplay sin acceso a fuente

### 2. Verificación de Integridad de Datos
```gdscript
# Calcula hash de datos
var original_hash = _calculate_hash(card_data)

# En siguiente sesión, verifica
if calculate_hash(card_data) != original_hash:
	print("Datos fueron modificados!")
```

### 3. Detección de Modificación de Variables

```gdscript
# Valores sospechosos son bloqueados
if base_hp > BaseHP.MAX or base_hp < BaseHP.MIN:
	# Error: intentó modificar HP base
	anti_cheat._log_tamper("Invalid base HP", str(base_hp))
```

## Reporte de Cheats

El sistema mantiene un reporte de intentos:

```gdscript
var report = anti_cheat.get_tamper_report()

# Resultado:
{
	"tamper_detected": true,
	"total_attempts": 5,
	"log": [
		{
			"timestamp": 1234567890,
			"reason": "Invalid card in database",
			"details": "Card ID mismatch"
		},
		# ... más intentos
	]
}
```

### Enviar Reporte al Servidor (Futuro)

```gdscript
func send_tamper_report_to_server() -> void:
	var report = anti_cheat.get_tamper_report()
	if report.total_attempts > 0:
		# Enviar a servidor para investigación
		var http = HTTPRequest.new()
		add_child(http)
		http.request(
			"https://api.calabozos.com/report-cheat",
			["Content-Type: application/json"],
			HTTPClient.METHOD_POST,
			JSON.stringify(report)
		)
```

## Mejores Prácticas

### Para Desarrolladores

1. **Nunca confiés en cliente**: Valida todo en servidor (cuando lo tengas)
2. **Encripta datos sensibles**: Siempre usa AES-256 o mejor
3. **Verifica integridad**: Usa checksums o firmas
4. **Log de eventos**: Guarda intentos de trampa
5. **Actualiza regularmente**: Parchos de seguridad

### Para el Juego

1. ✅ Validar cada movimento de carta
2. ✅ Verificar datos antes de guardar
3. ✅ Mantener backup automático
4. ✅ Detectar stats imposibles
5. ✅ Log de intentos sospechosos

## Configuración de Seguridad

### En `project.godot`:

```ini
[application/security]

# Proteger datos
file_extensions=PackedStringArray("encrypted")

# Validar scripts
check_scripts=true

# Encriptación para recursos
encrypt_resources=true
```

### En Code:

```gdscript
# Siempre:
1. Crear AntiCheat instance
2. Ejecutar validación antes de cada acción crítica
3. Guardar con SecureSave
4. Log de intentos
5. Bloquear player si se detecta trampa obvia
```

## Monitoreo en Google Play

Google Play incluye tools para detectar:
- ❌ Modificación de APK/AAB
- ❌ Rooting no autorizado
- ❌ Modificación de archivos
- ❌ Uso de emuladores
- ❌ Ubicación GPS falsificada

### Integración con Play Integrity API (Futuro)

```gdscript
# Godot 4.2+
func check_play_integrity() -> void:
	var integrity = PlayIntegrity.check_integrity()
	if not integrity.is_valid:
		print("Modded device detected!")
		get_tree().quit()
```

## Testing de Seguridad

### Prueba 1: Intentar editar save file
```bash
# Intenta editar calabozos_save.encrypted
# El sistema debe detectar checksum mismatch
```

### Prueba 2: Inyectar carta inválida
```gdscript
var fake_card = {
	"id": "fake_card",
	"faction": "invalid",
	"role": "unknown"
}
# anti_cheat.validate_card_data(fake_card) → false
```

### Prueba 3: Modificar stats en memoria
```gdscript
card.data.atk = 999
card.data.hp = 999
# anti_cheat.detect_impossible_stats(card) → true
```

## Roadmap de Seguridad

- [ ] Integración con Play Integrity API
- [ ] Server-side validation (cuando se agregue multiplayer)
- [ ] Two-factor authentication
- [ ] Rate limiting
- [ ] IP whitelisting
- [ ] Geographic validation
- [ ] Device fingerprinting

## Contacting Support

Si encuentras un exploit o vulnerability:
1. ⚠️ NO lo hagas público
2. 📧 Email a: security@calabozos.com
3. 📋 Describe los pasos exactos para reproducir
4. 🎁 Bug bounty disponible para reportes válidos

---

**Last Updated**: 2024
**Security Level**: MEDIUM (single-player game)
**Recommendation**: Implementar server-side validation para multiplayer futuro
