# 🔴 Habilidades Parcialmente Implementadas - Reporte Detallado

**Status**: 4 de 6 habilidades complejas necesitan completar su implementación

---

## 🔴 Bug #1: taunt - No Fuerza Targeting

### Situación Actual
```gdscript
# game_manager.gd línea 224-225
"taunt":
    unit.data.taunt = true
```

**Problema**: Solo marca la bandera, pero **nada en el sistema valida esta bandera**.

El enemigo puede:
- ✅ Ver que `unit.data.taunt = true`
- ❌ BUT tiene libertad de atacar cualquier otro lane
- ❌ No hay validación en `validate_card_play()` que fuerce atacar primero a taunted

### Impacto
```
Esperado: "Taunt fuerza al enemigo a atacar esta unidad"
Real: "Taunt es solo una bandera inerte"
```

### Fix Requerido

```gdscript
# En game_manager.gd -> validate_card_play() o en resolve_lane_combat()

func _has_taunted_unit_in_lane(lane: int, player: int) -> CardUnit:
    """Retorna unidad taunted en el lane enemigo si existe"""
    var enemy_lane = board[lane][1 - player]
    if enemy_lane != null and enemy_lane.data.taunt:
        return enemy_lane
    return null

# En validate_card_play():
if lane_index != defender_lane and _has_taunted_unit_in_lane(defender_lane, 1-player):
    _log_tamper("Taunt active: targeting wrong lane")
    return false  # Forzar targeting al lane taunted
```

---

## 🔴 Bug #2: double_skill - No Se Ejecuta Doble

### Situación Actual
```gdscript
# game_manager.gd línea 289-291
"double_skill":
    var ally3 := _find_best_ally_except(unit.data.owner, unit)
    if ally3 != null:
        ally3.data.extra_skill_uses += 1
```

**Problema**:
1. Incrementa `extra_skill_uses` en aliado
2. Pero **`extra_skill_uses` nunca se consulta o usa**
3. No hay mecanismo para ejecutar la habilidad nuevamente

### Impacto
```
Esperado: "Aliado ejecuta su habilidad 2 veces este turno"
Real: "Se incrementa un contador que nadie lee"
```

### Fix Requerido

```gdscript
# 1. En _activate_on_play_ability() después de jugar una carta:

func _activate_on_play_ability(unit: CardUnit) -> void:
    # ... existing code ...
    
    match unit.data.ability:
        # ... existing cases ...
        
        "double_skill":
            var ally3 := _find_best_ally_except(unit.data.owner, unit)
            if ally3 != null:
                # Marcar para doble ejecución
                ally3.data.extra_skill_uses += 1
                _log("%s gana skill extra." % ally3.data.name)
                
                # ✅ AQUÍ: ejecutar skill de ally inmediatamente OTRA VEZ
                _activate_on_play_ability(ally3)  # Ejecutar su habilidad segunda vez
```

---

## 🟡 Bug #3: any_row_attack - Comportamiento Inconsistente

### Situación Actual
```gdscript
# game_manager.gd línea 319-323
"any_row_attack":
    var target_lane = _find_best_target_lane_for_archer(unit.data.owner, unit.data.lane)
    if target_lane >= 0:
        resolve_lane_combat_custom(target_lane, unit.data.owner, unit)
```

**Status**: Parcialmente funcional, necesita validación

**Problemas Identificados**:
1. `_find_best_target_lane_for_archer()` puede retornar -1 (no hay enemigos detectados)
2. No hay fallback → si no encuentra enemigo, no ataca nada
3. Podría atacar vacío si enemy muere antes de su turno

### Fix Requerido

```gdscript
"any_row_attack":
    var target_lane = _find_best_target_lane_for_archer(unit.data.owner, unit.data.lane)
    
    # Fallback: si no encuentra mejor target, usa su lane
    if target_lane < 0:
        target_lane = unit.data.lane
    
    # Validar que hay enemigo donde atacar
    var target = board[target_lane][1 - unit.data.owner]
    if target != null and target.is_alive():
        resolve_lane_combat_custom(target_lane, unit.data.owner, unit)
        _log("%s ataca en carril %d." % [unit.data.name, target_lane])
    else:
        _log("Any-row-attack: No valid target in lane %d" % target_lane)
```

---

## 🟡 Bug #4: fury - No Visible en UI

### Situación Actual
```gdscript
# game_manager.gd línea 314-316
"fury":
    # Fury es pasivo: suma (max_hp - hp) al ataque
    # Ya está implementado en get_effective_attack() → get_attack_bonus_from_missing_hp()
    _log("%s entra en furia (ATK +%d por HP perdido)." % [unit.data.name, unit.get_attack_bonus_from_missing_hp()])
```

**Status**: Lógica implementada (está en CardUnit.get_effective_attack()), pero:

**Problemas**:
1. ✅ Bonus aplicado correctamente en combate
2. ❌ UI nunca muestra el bonus
3. ❌ Jugador no ve: "ATK +5 por HP perdido"
4. ❌ No hay indicador visual cuando está en furia

### Fix Requerido

En **card_view.gd** o **main_ui.gd**:

```gdscript
# En _update_ui() o similar
if card_unit.data.ability == "fury" and card_unit.data.hp < card_unit.data.max_hp:
    var fury_bonus = card_unit.get_attack_bonus_from_missing_hp()
    atk_label.text = "ATK: %d (+%d)" % [card_unit.data.atk, fury_bonus]
    atk_label.add_theme_color_override("font_color", Color.RED)  # Resaltar bonus
```

O en **game_manager.gd** antes de combate:

```gdscript
func resolve_lane_combat(lane_index: int, attacking_player: int) -> void:
    var attacker: CardUnit = board[lane_index][attacking_player]
    
    # Mostrar bonus de fury si aplica
    if attacker != null and attacker.data.ability == "fury":
        var bonus = attacker.get_attack_bonus_from_missing_hp()
        if bonus > 0:
            _log("[FURY] %s: ATK +%d (por %d HP perdido)" % [
                attacker.data.name,
                bonus,
                attacker.data.max_hp - attacker.data.hp
            ])
```

---

## 📊 Matriz de Completitud

| Habilidad | Lógica | Ejecución | UI/Feedback | Testeable | Status |
|-----------|--------|-----------|-----------|-----------|--------|
| **taunt** | ❌ | ❌ | ✅ | ❌ | BLOCEADO |
| **double_skill** | ⚠️ | ❌ | ⚠️ | ❌ | INCOMPLETO |
| **any_row_attack** | ✅ | ⚠️ | ✅ | ⚠️ | FRÁGIL |
| **fury** | ✅ | ✅ | ❌ | ⚠️ | INVISIBLE |

---

## 🎯 Prioridad de Fixes

1. **P1 - BLOQUEANTE**: taunt (invalidaría rock-paper-scissors strategy)
2. **P2 - CRÍTICO**: double_skill (habilidad costosa, inutilizable ahora)
3. **P3 - IMPORTANTE**: fury visibility (silenciosamente da bonus)
4. **P4 - ENHANCEMENT**: any_row_attack stability (funcional pero frágil)

---

## ⚠️ Riesgo de No Arreglarlo

Jugadores descubrirán:
- "Taunt no funciona, es inútil"
- "Double skill hace nada, es scam"
- "Berserker bonus es invisible"
- "Arquero ataca random"

→ Gameplay percibido como **buggy y sin pulir**

---

## Commits Necesarios

| #Commit | Descripción |
|---------|-------------|
| Fix #1 | "Implement taunt targeting enforcement" |
| Fix #2 | "Complete double_skill: execute ally ability twice" |
| Fix #3 | "Stabilize any_row_attack with fallback logic" |
| Fix #4 | "Add fury bonus visibility to UI/logs" |

---

**Status**: 🔴 BLOQUEANTE para gameplay

Sin estos fixes, el balance del juego es inconsistente y confuso para jugadores.
