# Tactical Strategy Sandbox
a generic turn-based engine for D&D-esque strategy games.

features:
 - `TileMapLayer` terrain sets with automatic map generation with the [Gaea addon](https://github.com/BenjaTK/Gaea).
 - randomizes order for all actors on map and iterates through their turns.
 - each actor gets a move limit and one attack. Attacks automatically end the turn.
 - 0.0 to 1.0 chance of hitting target, modified by attackers `weapon_skill` and `vantage` bonus, based on targets `armor_skill`.
 - ramp tiles that consumes additional movement to climb
