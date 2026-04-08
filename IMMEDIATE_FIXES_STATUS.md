# Status: Immediate Fixes & Next Steps

**Commit:** bbc5712  
**Fecha:** 8 Abril 2026

---

## ✅ Immediate (Bloqueantes) - COMPLETADO

### 1. any_row_attack & fury Implementadas
**Commit:** bbc5712

**Implementación:**
- `fury` (Berserker Feroz): 
  - Pasivo: suma `(max_hp - hp)` al ataque en cada combate
  - Ya estaba en `get_effective_attack()` → `get_attack_bonus_from_missing_hp()`
  - Agregado log en `_activate_on_play_ability()` para visibilidad

- `any_row_attack` (Arquero de Muralla):
  - Nuevo: `_find_best_target_lane_for_archer()` busca el mejor carril enemigo
  - Nuevo: `resolve_lane_combat_custom()` para atacar desde carril diferente
  - Agregado a `_activate_on_play_ability()` con lógica de selección inteligente

**Test:**
```gdscript
# Fury funciona automáticamente en combate:
# Berserker Feroz: 5 ATK base + 7 HP perdido = 12 ATK total

# Any Row Attack se activa al jugarse:
# Arquero de Muralla prefiere atacar carril con enemigo más fuerte
```

**Status:** ✅ FUNCIONAL

---

### 2. Mazos de Prueba Corregidos
**Commit:** bbc5712

**Antes (Problemático):**
```
PLAYER_1 (Jugador):
- Duplicados: paladin_alba ×2, arquero_muralla ×2, herrero_imperial ×2
- Total: 12 cartas con 6 únicas
- Resultado: Poca variedad, ventaja inconsistente

PLAYER_2 (IA):
- Mezcla de facciones: Orcos + Elfos (guardian_bosque, arquero_maestro, reina_estrellas)
- Total: 12 cartas sin coherencia de facción
- Resultado: Sistema de ventaja triangular roto
```

**Después (Correcto):**
```
PLAYER_1 (Humanos puros - 9 cartas):
paladin_alba, medico_campo, caballero_real, inquisidor_hierro,
arquero_muralla, herrero_imperial, hechicero_corte, escudero_novato,
general_valerius

PLAYER_2 (Orcos puros - 9 cartas):
berserker_feroz, chaman_sangre, jinete_lobo, rompefilas,
lanzador_hachas, brujo_sombras, capataz_esclavos, trasgo_saqueador,
gran_jefe_gromm
```

**Beneficios:**
- ✅ Ventaja triangular: Humanos > Orcos > Elfos se puede balancear
- ✅ Sin duplicados: Fuerza el uso de diferentes estrategias
- ✅ Monofacción: Claridad en el flujo de juego

**Status:** ✅ FUNCIONAL

---

### 3. immediate_attack Ya Está Implementado
**Status:** ✅ YA FUNCIONA (No requería fix)

```gdscript
# En play_card_from_hand() línea 149:
if unit.data.ability == "immediate_attack" and unit.data.silenced_turns <= 0:
    resolve_lane_combat(lane_index, player)
```

Gran Jefe Gromm (Orcos) ataca automáticamente al jugarse.

---

## 🟠 Before Google Play Publish - PENDIENTE

### 4. Conectar Traducciones a UI

**Estado Actual:**
- ✅ CSV importado en project.godot (commit 084a2ad)
- ✅ 85 claves en 3 idiomas (ES/EN/PT)
- ❌ UI aún usa strings directos hardcoded

**Cambios Necesarios:**

#### 4.1 localization.gd
```gdscript
# Ya existe, solo necesita ser invocado en _ready()
# Revisar que TranslationServer esté inicializado:
func _ready() -> void:
    _detect_system_language()  # Detecta idioma del SO
    set_language("es")  # Default a español
```

#### 4.2 card_view.gd
**Cambiar:**
```gdscript
# ANTES:
label_name.text = card_unit.data.name

# DESPUÉS:
label_name.text = tr("card_%s_name" % card_unit.data.id)
```

**Cambios necesarios:**
- `_update_ui()`: Traducir nombre, rol, habilidad, facción
- Todas las labels de texto visible

#### 4.3 main_ui.gd
**Cambiar todos los strings:**
```gdscript
# ANTES:
button_end_turn.text = "Fin de Turno"

# DESPUÉS:
button_end_turn.text = tr("ui_end_turn")
```

**Claves disponibles para UI:**
- `ui_base_player`, `ui_turn`, `ui_end_turn`, `ui_base_enemy`, `ui_game_over`, etc.

**Status:** 🟠 BLOQUEANTE ANTES DE PUBLICAR (1-2 horas de trabajo)

---

## 🟡 Medium Term - OPTIMIZACIÓN

### 5. Mejorar IA

**Cambio Minimal Recomendado:**
```gdscript
# En ai_take_turn():

# ANTES:
var chosen_lane := available_lanes[rng.randi_range(0, available_lanes.size() - 1)]

# DESPUÉS:
var chosen_lane = _choose_best_lane_for_ai(available_lanes)

func _choose_best_lane_for_ai(available_lanes: Array) -> int:
    """Elige carril considerando ventaja de facción"""
    var best_lane = -1
    var best_score = -999
    
    for lane in available_lanes:
        var player_unit = board[lane][PLAYER_1]
        var score = 0
        
        # Priorizar si tienes ventaja de facción
        if player_unit != null:
            # IA es Orcos, jugador es Humanos
            if has_faction_advantage("orc", player_unit.data.faction):
                score += 10  # Bonus por ventaja
        
        if score > best_score:
            best_score = score
            best_lane = lane
    
    # Fallback: carril aleatorio si no hay criterio claro
    return best_lane if best_lane >= 0 else available_lanes[rng.randi_range(0, available_lanes.size() - 1)]
```

**Resultado:**
- IA elige carriles donde tiene ventaja de facción
- Sigue siendo beatable, pero con más coherencia

**Status:** 🟡 OPTIMIZACIÓN (No bloqueante, mejora gameplay)

---

## Checklist para Publicación

- [x] Anti-cheat valida correctamente
- [x] Encriptación por dispositivo
- [x] Traducciones en CSV importadas
- [ ] Traducciones en UI conectadas (localization.gd + card_view.gd + main_ui.gd)
- [ ] Guest/Account modes funcionando
- [ ] any_row_attack y fury funcionando
- [ ] Mazos balanceados (sin duplicados)
- [ ] IA mejorada (opcional, puede esperar)
- [ ] Testing en Android device
- [ ] APK firmado con keystore

---

## Archivos Modificados

| Archivo | Cambios |
|---------|---------|
| game_manager.gd | any_row_attack, fury, mazos, 2 funciones nuevas |
| BUG_FIXES_CRITICAL.md | Documentación de los 3 fixes críticos |

**Total líneas agregadas: +272**

---

## Siguiente: UI Translations

Cuando estés listo, los pasos son:
1. Abrir localization.gd y asegurar que carga el idioma del sistema
2. Editar card_view.gd: reemplazar `card_unit.data.name` con `tr("card_%s_name" % card_unit.data.id)`
3. Editar main_ui.gd: reemplazar todos los strings de botones/labels con claves tr()
4. Probar en editor (F5) para verificar que las traducción funcionan

¿Empezamos con las traducciones en UI?
