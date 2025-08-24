# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CardMonsterHunterBattler is a Godot 4.3 card-based monster hunting game with turn-based tactical combat. The game features a world map progression system, card collection and forging mechanics, and strategic monster battles.

## Development Commands

This is a Godot project - no build commands are available. The project runs directly in the Godot Editor:

- **Run Game**: Open project in Godot Editor and press F5 or click Play button
- **Debug**: Use Godot's built-in debugger and profiler tools
- **Export**: Use Godot's Export dialog to build for target platforms

## Architecture Overview

### Core Systems

**Singleton Controllers** (Autoloaded in project.godot):
- `GameController`: Manages overall game state, day counter, and boss encounters
- `BattleController`: Handles battle state, player/monster references, and turn management
- `PlayerController`: Tracks campaign progression, deck management, and player stats
- `CardResourcesController`/`CardModuleController`: Manage card data and modular card components

**Signal System**:
- `BattleSignals`: Battle-specific events (turn changes, card plays, combat outcomes)  
- `BattlemapSignals`: Grid-based interactions (movement, targeting, tile effects)

### Card System Architecture

**CardResourceV2**: Core card data structure containing:
- Basic info (title, description, stamina cost, rarity)
- `play_actions`: Array of CardEffect objects that execute when played
- `play_conditions`: Requirements that must be met to play the card
- `special_effects`: Passive or triggered abilities

**Card Effects**: Modular system where each card can have multiple effects:
- `AttackCardEffect`: Damage dealing
- `MoveCardEffect`: Movement abilities  
- `StatusChangeCardEffect`: Healing, buffs, debuffs
- `PowerCardEffect`: Temporary combat modifiers
- `TileEffectCardEffect`: Grid-based environmental effects

### Battle System

**Turn Structure**:
1. Player selects and plays cards (spending stamina)
2. Monster AI executes state-based behaviors
3. Grid effects and status effects process
4. Turn counter increments

**Grid-Based Combat**:
- Hex/square grid battlefield with tile-based positioning
- Area-of-effect targeting (LINE, RADIUS, CROSS, SHOTGUN patterns)
- Environmental effects (spider webs, blood tiles)

### World Progression

**World Nodes**:
- `MonsterHuntWorldNode`: Combat encounters
- `TreasureWorldNode`: Loot collection
- `VillageWorldNode`: Safe rest areas
- `DeforgeCardWorldNode`: Card modification/removal

**Card Forging System**: Players can create custom cards by combining CardModule components with base card templates.

## Key File Locations

**Core Scripts**:
- `/scripts/utils/constants.gd`: Enums and global constants
- `/singletons/controllers/`: Main game controller singletons
- `/resources/card/card_resource_v2/`: Card system implementation

**Scenes**:
- `/scenes/battle_scenes/`: Combat encounter scenes
- `/scenes/monsters/`: Monster definitions and behaviors  
- `/ui/screens/`: Game screen interfaces
- `/scenes/game_objects/cards/`: Card visual components

**Resources**:
- `/resources/card/card_resource_v2/_card_resources_v2/`: Pre-built card definitions
- `/resources/player_deck/decks/`: Starting deck configurations
- `/resources/player/player_class/`: Character class definitions

## Development Notes

- The game uses a modular card effect system - new card abilities are created by extending CardEffect base classes
- Monster behaviors are implemented using state machines with condition-based transitions
- All game state is persistent through the File singleton save system
- Grid positioning uses a custom movement utility system in `/scripts/utils/battlemap_utils/`
- UI screens extend a common base class pattern for consistent behavior

## Scene Structure

Main entry point: `ui/screens/title_menu_screen/title_scene.tscn`

Key scenes are loaded dynamically through Constants singleton scene references rather than hardcoded paths.