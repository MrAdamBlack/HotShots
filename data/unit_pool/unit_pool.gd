class_name UnitPool
extends Resource

@export var available_units: Array[UnitStats]

var unit_pool: Array[UnitStats]

func generate_unit_pool() -> void:
	unit_pool = []
	
	for unit: UnitStats in available_units:
		for i in unit.pool_count:
			unit_pool.append(unit)
			
func get_next_unit() -> UnitStats:
	if unit_pool.is_empty():
		return null

	var picked_unit: UnitStats = unit_pool[0]
	unit_pool.remove_at(0)
	return picked_unit

func add_unit(unit: UnitStats) -> void:
	var combined_count := unit.get_combined_unit_count()
	unit = unit.duplicate()
	unit.tier = 1
	
	for i in combined_count:
		unit_pool.append(unit)
