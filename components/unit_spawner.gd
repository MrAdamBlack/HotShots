class_name UnitSpawner
extends Node

const UNIT = preload("res://scenes/unit/unit.tscn")
const TEST_UNIT_STATS = preload("res://data/units/pug.tres")
const ObjectPool = preload("res://scenes/unit/objectpool.gd")


@export var bench: PlayArea
@export var game_area: PlayArea
@onready var unit_mover: UnitMover = $"../UnitMover"
@onready var arena: Arena = get_parent()

# In your UnitSpawner.gd
const PlayerType = preload("res://data/player_types.gd")

# Then use like:
var player = PlayerType.Type.PLAYER1
var layer = PlayerType.get_collision_layer(player)
var group = PlayerType.get_group_name(player)

# Object pool for clone units (MARCHING state only)
var clone_pool: Array[Unit] = []
const MAX_CLONES_IN_POOL := 20  # Adjust for performance/memory trade-off
@onready var unit_pool: ObjectPool = ObjectPool.new()


func _ready() -> void:
	print("@ Unit_Spawner.gd: _ready")
	await get_tree().process_frame
	call_deferred("spawn_test_unit", PlayerType.Type.PLAYER2)
	SignalBus.connect("unit_bought", Callable(self, "_on_unit_bought"))
	add_child(unit_pool)

func _on_unit_bought(unit_stats: UnitStats) -> void:
	spawn_unit_at_mouse(unit_stats)

func get_area_for_player(player_type: int) -> PlayArea:
	match player_type:
		PlayerType.Type.PLAYER1: return game_area
		PlayerType.Type.PLAYER2: return bench
		_: return null

func spawn_unit_at_mouse(unit_stats: UnitStats) -> void:
	var new_unit = spawn_base_unit(PlayerType.Type.PLAYER1, unit_stats)
	new_unit.global_position = get_viewport().get_mouse_position()
	
	# Setup unit and connect signals
	await get_tree().process_frame
	unit_mover.setup_unit(new_unit)

	# Emit the unit spawned signal
	call_deferred("emit_unit_spawned", new_unit)

func spawn_marching_clone(unit: Unit) -> void:
	var player_type = PlayerType.Type.PLAYER1 if unit.is_in_group("player1_unit") else PlayerType.Type.PLAYER2
	var clone = spawn_clone(unit, player_type)
	call_deferred("_initialize_clone", clone, player_type)
	clone.unit_state_machine.init(clone, UnitState.State.MARCHING)
	
func _initialize_clone(clone: Unit, player_type: int) -> void:
	# Now proceed with your clone setup, e.g., collision layers, state machine, etc.
	clone.collision_layer = 0
	clone.collision_mask = 0
	match player_type:
		PlayerType.Type.PLAYER1:
			clone.add_to_group("player1_clone")
			clone.collision_layer = 1
			clone.collision_mask = 2
			clone.area_of_interest.collision_layer = 1
			clone.area_of_interest.collision_mask = 2
		PlayerType.Type.PLAYER2:
			clone.add_to_group("player2_clone")
			clone.collision_layer = 2
			clone.collision_mask = 1
			clone.area_of_interest.collision_layer = 2
			clone.area_of_interest.collision_mask = 1
			
	# Properly initialize the state machine
	if clone.has_node("UnitStateMachine"):
		var state_machine = clone.get_node("UnitStateMachine")
		state_machine.init(clone, UnitState.State.MARCHING)
	else:
		push_error("Clone missing UnitStateMachine node")
	clone.update_health_bar()

func spawn_base_unit(player_type: int, unit_stats: UnitStats = null) -> Unit:
	var new_unit: Unit = UNIT.instantiate()
	
	if unit_stats == null:
		unit_stats = TEST_UNIT_STATS
	if unit_stats:
		new_unit.stats = unit_stats
	
	# Set collision and groups based on player type
	setup_unit_player_properties(new_unit, player_type)
	
	# Add to scene
	get_parent().add_child(new_unit)
	
	# Defer the initialization to ensure the node is ready
	if player_type == PlayerType.Type.PLAYER1:
		call_deferred("_initialize_unit_state", new_unit, UnitState.State.DRAG)

	return new_unit
	
func _initialize_unit_state(unit: Unit, state: int) -> void:
	if unit.has_node("UnitStateMachine"):
		var state_machine = unit.get_node("UnitStateMachine")
		state_machine.init(unit, state)
	else:
		push_error("Unit is missing UnitStateMachine node")

func setup_unit_player_properties(unit: Unit, player_type: int) -> void:
	unit.collision_layer = 0
	unit.collision_mask = 0
	unit.add_to_group("player" + str(player_type + 1) + "_unit")

func spawn_clone(original_unit: Unit, player_type: int) -> Unit:
	var clone := unit_pool.get_clone(original_unit)
	# Manually copy the stats from the original unit to the clone
	clone.stats = original_unit.stats
	
	clone.global_position = original_unit.global_position

	# Reset clone data
	clone.collision_layer = 0
	clone.collision_mask = 0
	for group in clone.get_groups():
		if group.begins_with("player") or group == "dragging":
			clone.remove_from_group(group)

	# Add to scene
	get_parent().add_child(clone)

	# Init state machine if needed
	if not clone.unit_state_machine:
		print("unit_spawner.gd: Clone has no USM")
		call_deferred("_initialize_clone_state", clone, UnitState.State.MARCHING)

	return clone

func _initialize_clone_state(clone: Unit, state: int) -> void:
	if clone.has_node("UnitStateMachine"):
		var state_machine = clone.get_node("UnitStateMachine")
		state_machine.init(clone, state)
	else:
		push_error("Unit clone is missing UnitStateMachine node")

func spawn_test_unit(player_type: int) -> void:
	var target_area = get_area_for_player(player_type)
	var tile = target_area.unit_grid.get_first_empty_tile()
	
	if target_area.unit_grid.is_tile_occupied(tile):
		print("Tile occupied")
		return

	var unit = spawn_base_unit(player_type)
	unit.unit_state_machine.init(unit, UnitState.State.IDLE)
	await get_tree().process_frame
	target_area.unit_grid.add_unit(tile, unit)

	# Using manual pos below for testing/debug purposes.
	var pos = Vector2(950.0, 250.0)
	unit.global_position = pos
	#unit.global_position = target_area.get_global_from_tile(tile)

func emit_unit_spawned(unit: Unit) -> void:
	SignalBus.unit_spawned.emit(unit)
	
func return_clone_to_pool(clone: Unit) -> void:
	clone.queue_free()  # Replace with `hide()` and `remove_from_tree()` if you want more performance
	# Alternatively:
	# clone.visible = false
	# clone.set_process(false)
	# clone_pool.append(clone)
