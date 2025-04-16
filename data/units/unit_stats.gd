class_name UnitStats
extends Resource

enum Rarity {COMMON, UNCOMMON, RARE, LEGENDARY}

const RARITY_COLORS := {
	Rarity.COMMON: Color("124a2e"),
	Rarity.UNCOMMON: Color("1c527c"),
	Rarity.RARE: Color("ab0979"),
	Rarity.LEGENDARY: Color("ea940b"),
}

@export var name: String

@export_category("Data")
@export var rarity: Rarity 
@export var gold_cost := 1
@export_range(1, 3) var tier := 1 : set = _set_tier
@export var pool_count := 5
@export var traits: Array[Trait]
@export_range(1, 100) var range_of_attack := 1 : set = _set_range_of_attack

@export_category("Visuals")
@export var skin_coordinates: Vector2i

var area_of_interest := 150


func get_combined_unit_count() -> int:
	return 3 ** (tier-1)


func get_gold_value() -> int:
	return gold_cost * get_combined_unit_count()


func _set_range_of_attack(value: int) -> void:
	range_of_attack = value
	emit_changed()
	
func _set_tier(value: int) -> void:
	tier = value
	emit_changed()


func _to_string() -> String:
	return name
