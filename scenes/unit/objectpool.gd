# Objectpool.gd
extends Node

const MAX_POOL_SIZE = 50
const UNIT_SCENE = preload("res://scenes/unit/unit.tscn")

var clone_pool: Array[Unit] = []

func get_clone(original_unit: Unit) -> Unit:
	if clone_pool.size() > 0:
		var clone = clone_pool.pop_back()
		# Reset clone only when it is fetched from the pool (after being used before)
		clone.reset()
		return clone
	
	# For a fresh clone (newly instantiated), don't reset, just return it as is
	var clone: Unit = UNIT_SCENE.instantiate()
	return clone

# Return a clone to the pool
func return_clone(clone: Unit) -> void:
	if clone_pool.size() < MAX_POOL_SIZE:
		# Reset the clone before returning it to the pool
		clone.reset()
		clone_pool.append(clone)
