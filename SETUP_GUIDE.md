# Calabozos: Guerra de Facciones - Setup Guide

## Project Structure Created
✅ res/scripts/
  - card_database.gd
  - card_unit.gd
  - save_data.gd
  - game_manager.gd
  - card_view.gd
  - lane_slot.gd
  - main_ui.gd

✅ res/scenes/
  - CardView.tscn
  - LaneSlot.tscn
  - Main.tscn

## Next Steps in Godot Editor

### 1. Open Main.tscn
This is your main scene. You need to configure exports on the MainUI script.

### 2. Configure Main.tscn Exports
Select the "Main" node, find MainUI script inspector, set these exports:

- **game_manager_path**: `./GameManager`
- **player_hand_container**: Drag `VBoxContainer/HBoxContainer_PlayerHandArea/ScrollContainer/player_hand_container` from the scene tree
- **enemy_hand_info**: Drag `VBoxContainer/Label_EnemyHandInfo` from the scene tree
- **player_lane_slots**: Add 3 items and assign:
  - Index 0: `VBoxContainer/HBoxContainer_PlayerLanes/LaneSlot_Player1`
  - Index 1: `VBoxContainer/HBoxContainer_PlayerLanes/LaneSlot_Player2`
  - Index 2: `VBoxContainer/HBoxContainer_PlayerLanes/LaneSlot_Player3`
- **enemy_lane_slots**: Add 3 items and assign:
  - Index 0: `VBoxContainer/HBoxContainer_EnemyLanes/LaneSlot_Enemy1`
  - Index 1: `VBoxContainer/HBoxContainer_EnemyLanes/LaneSlot_Enemy2`
  - Index 2: `VBoxContainer/HBoxContainer_EnemyLanes/LaneSlot_Enemy3`
- **player_base_label**: Drag `VBoxContainer/HBoxContainer_TopBar/player_base_label`
- **enemy_base_label**: Drag `VBoxContainer/HBoxContainer_TopBar/enemy_base_label`
- **turn_label**: Drag `VBoxContainer/HBoxContainer_TopBar/turn_label`
- **log_label**: Drag `VBoxContainer/RichTextLabel_Log`
- **end_turn_button**: Drag `VBoxContainer/HBoxContainer_PlayerHandArea/Button_EndTurn`
- **card_view_scene**: Drag `res://scenes/CardView.tscn`

### 3. Configure LaneSlot.tscn Exports
For each LaneSlot instance:
- **title_label**: Drag the `VBoxContainer/title_label` from within that scene
- **card_holder**: Drag the `VBoxContainer/CenterContainer/card_holder` from within that scene

### 4. Configure CardView.tscn Exports
Select the "CardView" node and assign:
- **portrait**: Drag `VBoxContainer/portrait`
- **name_label**: Drag `VBoxContainer/name_label`
- **stats_label**: Drag `VBoxContainer/stats_label`
- **faction_label**: Drag `VBoxContainer/faction_label`
- **role_label**: Drag `VBoxContainer/role_label`
- **ability_label**: Drag `VBoxContainer/ability_label`
- **rarity_label**: Drag `VBoxContainer/rarity_label`

### 5. Create project.godot
If you don't have one already, Godot will auto-create it when you open the project in Godot 4.

## Game Features

### Factions
- Humans (Blue) - Balanced warriors
- Orcs (Green) - Aggressive with bleeding/fury mechanics
- Elves (Purple) - Support and special abilities

### Roles
- Tank: High HP, low ATK
- Damage: High ATK, low HP
- Support: Medium stats with healing/buffs
- Magic: Balanced with AoE abilities
- Cannon: Medium stats for quick plays
- Control: Silencing and debuff cards
- Legendary: Powerful faction leaders

### Game Mechanics
- 3 lanes per side
- Faction advantage bonus (+3 ATK)
- Special abilities on play
- Drag-and-drop card placement
- AI opponent
- Turn-based combat
- Base health = 20 (first to reach 0 loses)

## Running the Game
1. Press F5 in Godot or click Run
2. Select Main.tscn as the main scene
3. Play!
