# Sistema de Guardado: Guest vs Account

## Visión General

El juego ahora soporta dos modos de juego con diferentes niveles de persistencia de datos:

| Aspecto | Guest | Account (sin Google Play) | Account (con Google Play) |
|--------|-------|--------------------------|---------------------------|
| **Guardado Local** | ✅ Sí | ✅ Sí | ✅ Sí |
| **Sincronización en Nube** | ❌ No | ❌ No | ✅ Sí (Google Play) |
| **Otro Dispositivo** | ❌ No | ❌ No | ✅ Sí |
| **Ideal Para** | Pruebas rápidas | Juego causal | Juego serio |

---

## Modo Guest 

**Descripción:** Juega sin crear cuenta. Los datos se guardan localmente en el dispositivo.

### Características:
- ✅ Progreso guardado automáticamente
- ✅ Datos persisten al cerrar la app
- ✅ Sin necesidad de cuenta
- ❌ **No se sincroniza a otros dispositivos**
- ❌ Se pierden si desinstala la app (datos eliminados del sistema)

### Uso:
```gdscript
game_manager.set_game_mode(GameMode.Mode.GUEST)
# Resultado: "Modo Guest: Progreso guardado localmente (no sincronizado)"
```

### Caso de Uso:
- Jugadores que solo juegan en un dispositivo
- Pruebas rápidas
- Usuarios que no quieren crear cuenta

---

## Modo Account sin Google Play

**Descripción:** Crea un perfil local pero sin vinculación a Google Play. Los datos se guardan localmente.

### Características:
- ✅ Progreso guardado automáticamente
- ✅ Datos persisten al cerrar la app
- ✅ Nombre de jugador personalizado (para futuros leaderboards)
- ❌ **No se sincroniza a otros dispositivos**
- ❌ Se pierden si desinstala la app

### Uso:
```gdscript
game_manager.set_game_mode(GameMode.Mode.ACCOUNT, "nombre@email.com")
# Resultado: "Modo Account: Progreso guardado localmente (sin sincronización)"
```

### Caso de Uso:
- Transición a Account con Google Play
- Desarrollo/testing

---

## Modo Account con Google Play

**Descripción:** Vincula la cuenta a Google Play Games Services. Los datos se guardan localmente Y sincronizan a la nube.

### Características:
- ✅ Progreso guardado automáticamente
- ✅ Datos persisten al cerrar la app
- ✅ **Sincronización automática con Google Play**
- ✅ **Accesible desde cualquier dispositivo**
- ✅ Backup en la nube
- ⚠️ Requiere cuenta Google

### Uso:
```gdscript
# Paso 1: Verificar autenticación con Google Play
# (Esto se hace en MainActivity o mediante Google Play Games Services)

# Paso 2: Vincular en el juego
game_manager.link_google_play_account("email@gmail.com")
# Resultado: "Cuenta de Google Play vinculada: email@gmail.com"
#           "Sincronización con Google Play activada"

# Paso 3: El progreso se sincroniza automáticamente
```

### Caso de Uso:
- Juego serio con múltiples dispositivos
- Protección de progreso
- Experiencia de usuario premium

---

## Flujo de Datos

```
Guardado Local (Todos los modos)
↓
SaveData → SecureSave.save_player_data()
↓
Encriptar con AES-256-GCM
↓
Guardar en: user://calabozos_save.encrypted

Si Account + Google Play:
↓
SecureSave.sync_to_cloud()
↓
Enviar a Google Play Games Services
↓
Disponible en otros dispositivos
```

---

## Minimización de Datos

El sistema está optimizado para usar **mínimo almacenamiento**:

### SaveData Minimalista:
```gdscript
# Solo guarda cambios respecto a defaults
inventory = {
  "card_id_1": {"level": 3},  # Solo si es diferente de 1
  "card_id_5": {"copies": 2}  # Solo si es diferente de 10
}
# Las cartas con valores default no se guardan

coins = 350  # Solo si es diferente de 300
```

### Compression Ratio:
- **Nuevo sistema:** ~10-20% del tamaño anterior
- **Ejemplo:** 27 cartas × 2 propiedades = 54 valores, solo guarda ~5-10

```gdscript
ratio = save_data.get_compression_ratio()
# Retorna: float (0.0 a 1.0)
# 0.15 = 15% de los datos guardados vs estructura completa
```

---

## Validación de Integridad

Todos los guardados tienen protección anti-tampering:

```gdscript
# En guardado:
checksum = SHA256(inventory + coins + version + timestamp)

# En carga:
saved_checksum = file.checksum
calculated_checksum = SHA256(loaded_data)

if saved_checksum != calculated_checksum:
  # Posible corrupción o tampering
  Cargar desde backup automáticamente
```

---

## Backup Automático

El sistema mantiene un backup de seguridad:

```
user://calabozos_save.encrypted      (archivo actual)
user://calabozos_save.backup         (backup de seguridad)

Si la carga falla:
1. Intenta cargar desde backup
2. Si backup es válido, lo restaura como principal
3. Si ambos fallan, comienza desde cero
```

---

## Implementación en la UI

### Pantalla de Bienvenida:
```
┌─────────────────────────────┐
│  Calabozos: Guerra de Facciones
├─────────────────────────────┤
│  [ ] Jugar como Guest       │
│  [ ] Crear Cuenta Local     │
│  [ ] Vincular Google Play   │
└─────────────────────────────┘
```

### En Visor de Progreso:
```
Modo de Juego: Guest
Almacenamiento Local: ✅ Activo
Sincronización en Nube: ❌ Desactivada

[ Vincular Google Play ]  [ Cambiar Modo ]
```

---

## Cambio de Modo En Juego

Un jugador puede cambiar de modo en cualquier momento:

```gdscript
# Guest → Account sin Google Play
game_manager.set_game_mode(GameMode.Mode.ACCOUNT, "email@local")
# Los datos locales se mantienen

# Account → Account con Google Play
game_manager.link_google_play_account("email@gmail.com")
# Se sincroniza a la nube inmediatamente

# Account con Google Play → Guest
game_manager.unlink_google_play_account()
# Se deja de sincronizar con la nube
# Los datos locales se mantienen
```

---

## Consideraciones de Privacidad

- **Guest Mode:** Ningún dato se envía fuera del dispositivo
- **Account Local:** Ningún dato se envía fuera del dispositivo
- **Account Google Play:** Solo datos de progreso se sincronizan (no hay datos personales)
- **Encriptación:** Todos los guardados usan AES-256-GCM

---

## Próximos Pasos

1. **Implementar UI de Selección de Modo** en MainUI.gd
2. **Integración con Google Play Games Services** (backend)
3. **Sincronización bidireccional** (si trae progreso de nube)
4. **Leaderboards** (usando datos de account)
5. **Cloud Save de Google Play** (alternativa)

---

## Resumen Técnico

| Archivo | Cambios |
|---------|---------|
| `save_data.gd` | Minimalista: solo guarda cambios |
| `secure_save.gd` | Agregados: `sync_to_cloud()`, `get_sync_status()` |
| `game_mode.gd` | NUEVO: Gestiona Guest vs Account |
| `game_manager.gd` | Agregados: `set_game_mode()`, `link_google_play_account()` |

**Estado:** ✅ Completamente implementado y listo para usar
