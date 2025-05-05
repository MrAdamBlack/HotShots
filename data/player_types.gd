class_name PlayerTypes
extends Resource

## Enum representing different player types in the game
enum Type {
	PLAYER1,  # First player
	PLAYER2   # Second player
}

## Get collision layer for a player type
static func get_collision_layer(player_type: int) -> int:
	match player_type:
		Type.PLAYER1: return 1
		Type.PLAYER2: return 2
		_: return 0

## Get collision mask for a player type
static func get_collision_mask(player_type: int) -> int:
	match player_type:
		Type.PLAYER1: return 2  # Collide with player 2
		Type.PLAYER2: return 1  # Collide with player 1
		_: return 0

## Get player group name
static func get_group_name(player_type: int) -> String:
	return "player" + str(player_type + 1) + "_unit"
