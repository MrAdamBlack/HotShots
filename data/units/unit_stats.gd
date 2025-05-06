class_name UnitStats
extends Resource

signal self_dead(stats: UnitStats)


@export var name: String

@export_category("Data")
#@export var rarity: Rarity 
@export var gold_cost := 1
@export_range(1, 3) var tier := 1 : set = _set_tier
@export var pool_count := 5
@export var traits: Array[Trait]
@export_range(1, 150) var area_of_interest := 150 : set = _set_area_of_interest
@export_range(1, 75) var range_of_attack := 50 : set = _set_range_of_attack
@export_range(1, 200) var march_speed: float = 100.0
@export_range(1, 200) var attack_speed: float = 10.0
@export_range(1, 200) var attack_damage: float = 10.0
@export_range(1, 200) var max_health: float = 100.0
@export_range(1, 200) var attack_power: float = 10.0
var health: float: set = set_health

@export_category("Visuals")
@export var skin_coordinates: Vector2i


func _init() -> void:
	health = max_health

func set_health(value: float) -> void:
	var old_health = health
	health = value
	#print("unit_stats: set_health")
	#print("\tOld Health: ", old_health)
	#print("\tHealth: ", health)
	if old_health > 0 and health <= 0:
		#print(">>>>> unit_stats.gd: set_health: emit_signal(\"self_dead\", self)")
		#print("\tDead Unit ", name)
		# Emit signal with UnitStats instance
		emit_signal("self_dead", self)  

func get_combined_unit_count() -> int:
	return 3 ** (tier-1)

func get_gold_value() -> int:
	return gold_cost * get_combined_unit_count()

func _set_area_of_interest(value: int) -> void:
	area_of_interest = value
	emit_changed()

func _set_range_of_attack(value: int) -> void:
	range_of_attack = value
	emit_changed()
	
func _set_tier(value: int) -> void:
	tier = value
	emit_changed()

func _to_string() -> String:
	return name
