class_name UnitMover
extends Node

@export var play_areas: Array[PlayArea]
@export var unit_place_sound: AudioStream
@export var grid: UnitGrid
@onready var shop: Shop = %Shop


func setup_unit(unit: Unit) -> void:
	print("unit_mover.gd: _ready()")

func _set_highlighters(enabled: bool) -> void:
	for play_area: PlayArea in play_areas:
		play_area.tile_highlighter.enabled = enabled

func _get_play_area_for_position(global: Vector2) -> int:
	var dropped_area_index := -1
	
	for i in play_areas.size():
		var tile := play_areas[i].get_tile_from_global(global)
		if play_areas[i].is_tile_in_bounds(tile):
			dropped_area_index = i
	
	return dropped_area_index

func _reset_unit_to_starting_position(starting_position: Vector2, unit: Unit) -> void:
	var i := _get_play_area_for_position(starting_position)
	var tile := play_areas[i].get_tile_from_global(starting_position)
	
	unit.reset_after_dragging(starting_position)
	play_areas[i].unit_grid.add_unit(tile, unit)
	SFXPlayer.play(unit_place_sound)

func _move_unit(unit: Unit, play_area: PlayArea, tile: Vector2i) -> void:
	play_area.unit_grid.add_unit(tile, unit)
	unit.global_position = play_area.get_global_from_tile(tile) - Arena.HALF_CELL_SIZE
	unit.reparent(play_area.unit_grid)

func _on_unit_drag_started(unit: Unit) -> void:
	unit.z_index = 99
	_set_highlighters(true)
	
	var i := _get_play_area_for_position(unit.global_position)
	if i > -1:
		var tile := play_areas[i].get_tile_from_global(unit.global_position)
		play_areas[i].unit_grid.remove_unit(tile)

func _on_unit_drag_canceled(starting_position: Vector2, unit: Unit) -> void:
	_set_highlighters(false)
	_reset_unit_to_starting_position(starting_position, unit)

func _on_unit_dropped(unit: Unit) -> void:
	_set_highlighters(false)
	
	# Get the current global position of the unit (where it's dropped)
	var drop_position = unit.get_global_mouse_position()
	
	# Find the play area where the unit is being dropped
	var drop_area_index := _get_play_area_for_position(drop_position)
	
	if drop_area_index == -1:
		# If no valid drop area, reset the unit to the starting position
		_reset_unit_to_starting_position(drop_position, unit)
		return

	# Get the new play area and the corresponding tile for the drop
	var new_area := play_areas[drop_area_index]
	var new_tile := new_area.get_hovered_tile()

	# Check if the tile is occupied
	if new_area.unit_grid.is_tile_occupied(new_tile):
		_reset_unit_to_starting_position(drop_position, unit)
		return
	
	# Move the unit to the new tile
	_move_unit(unit, new_area, new_tile)
	SFXPlayer.play(unit_place_sound)
	unit.z_index = 0
	SignalBus.global_transition_requested.emit(self, unit.unit_state_machine.current_state, UnitState.State.PRE_BATTLE)
