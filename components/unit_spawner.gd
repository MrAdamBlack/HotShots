class_name UnitSpawner
extends Node

signal unit_spawned(unit: Unit)

const UNIT = preload("res://scenes/unit/unit.tscn")

@export var bench: PlayArea
@export var game_area: PlayArea
@onready var unit_mover: UnitMover = $"../UnitMover"


func _get_first_available_area() -> PlayArea:
	#if not bench.unit_grid.is_grid_full():
	#	return bench
	if not game_area.unit_grid.is_grid_full():
		return game_area
	
	return null

func spawn_unit_at_mouse(unit_stats: UnitStats) -> void:
	print("unit_spawner.gd: spawn_unit_at_mouse(unit_stats: UnitStats)")
	print("unit_spawner.gd: spawn_unit_at_mouse() called")
	print("unit_spawner.gd: call stack:\n", get_stack())
	var area := _get_first_available_area()
	var new_unit: Unit = UNIT.instantiate()
	new_unit.stats = unit_stats
	
	# Reparent to Arena (we assume this UnitSpawner is a child of Arena)
	get_parent().add_child(new_unit)
	print("unit_spawner.gd. Get Parent: " + str(get_parent()))
	new_unit.add_to_group("units")
	print("unit_spawn.gd, unit group: " + str(new_unit.get_groups()))

	
	# Set position to current mouse
	new_unit.global_position = get_viewport().get_mouse_position()
	
	# Setup unit and connect signals first
	await get_tree().process_frame
	unit_mover.setup_unit(new_unit)
	# Emit the unit spawned signal
	call_deferred("emit_unit_spawned", new_unit)
	await get_tree().process_frame
	
func emit_unit_spawned(unit: Unit) -> void:
	print("unit_spawner.gd: ->->-> unit_spawned.emit(unit)")
	unit_spawned.emit(unit)
