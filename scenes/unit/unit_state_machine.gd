class_name UnitStateMachine
extends Node

@export var initial_state: UnitState
@onready var label: Label = %Label

var current_state: UnitState
var states := {}
var is_initialized = false
var unit: Unit = null
var enemy: Unit

#func remove_clone(clone: Unit) -> void:
	## Return the clone to the pool when it's no longer needed
	#if clone_pool.size() < MAX_CLONES_IN_POOL:
		#clone_pool.append(clone)
		#clone.queue_free()  # Optionally, remove clone from the scene
	#else:
		#clone.queue_free()  # If pool is full, just free the clone

func init(unit: Unit, initial_state_enum: UnitState.State = -1) -> void:
	self.unit = unit
	
	if is_initialized:
		return
	is_initialized = true

	SignalBus.global_transition_requested.connect(_on_global_transition_requested)
	#SignalBus.health_depleted.connect(_on_unit_death)
			
	for child in get_children():
		if child is UnitState:
			states[child.state] = child
			child.unit = unit
			child.fsm = self
			child.set_process(false)
			child.set_process_input(false)
			child.set_process_unhandled_input(false)
			child.set_process_unhandled_key_input(false)
	
	# Use override state if specified
	var start_state: UnitState
	if initial_state_enum >= 0 and states.has(initial_state_enum):
		start_state = states[initial_state_enum]
	else:
		start_state = initial_state
	
	if start_state:
		start_state.init(self, unit)  # Initialize only the active state
		start_state.enter()
		start_state.set_process(true)
		start_state.set_process_input(true)
		start_state.set_process_unhandled_input(true)
		start_state.set_process_unhandled_key_input(true)
		current_state = start_state

func on_input(event: InputEvent) -> void:
	if current_state:
		current_state.on_input(event)

func on_gui_input(event: InputEvent) -> void:
	if current_state:
		current_state.on_gui_input(event)

func on_mouse_entered() -> void:
	if current_state:
		current_state.on_mouse_entered()

func on_mouse_exited() -> void:
	if current_state:
		current_state.on_mouse_exited()

func _on_global_transition_requested(requester: Node, from: UnitState, to: UnitState.State, enemy: Unit = null) -> void:
		print("Global transition requested from %s to %s" % [from, to])
		_on_transition_requested(requester, current_state, to, enemy)

func _on_transition_requested(requester: Node, from: UnitState, to: UnitState.State, enemy: Unit = null) -> void:
	var new_state: UnitState = states.get(to)
	if not new_state:
		print("State not found: ", to)
		return
	
	if enemy and new_state.has_method("set_enemy"):
		new_state.set_enemy(enemy)

	if current_state:
		current_state.exit()
		current_state.set_process(false)
		current_state.set_process_input(false)
		current_state.set_process_unhandled_input(false)
		current_state.set_process_unhandled_key_input(false)

	new_state.init(self, requester, from, enemy)
	new_state.enter()
	new_state.set_process(true)
	new_state.set_process_input(true)
	new_state.set_process_unhandled_input(true)
	new_state.set_process_unhandled_key_input(true)
	current_state = new_state

func request_transition(requester: Node, 
						from: UnitState, 
						to: UnitState.State, 
						enemy: Unit = null) -> void:
	# Ensure enemy is passed correctly, if provided
	#if enemy:
		#print("Transitioning to state: " + str(to) + " with enemy: " + enemy.stats.name)
	#else:
		#print("Transitioning to state: " + str(to) + " without enemy.")
	if current_state:
		_on_transition_requested(requester, current_state, to, enemy)

func _on_area_of_interest_entered(area: Area2D) -> void:
	pass

func _on_range_of_attack_entered(area: Area2D) -> void:
	pass

func reset() -> void:
	# Clear the current state and reset initialization flag
	current_state = null
	is_initialized = false

	# Reset the states as needed (optional)
	for state in states.values():
		state.reset()  # If each state has a reset method, call it here
	# You can also reset other properties specific to the state machine
	# E.g., resetting signals or other variables

func _on_unit_death(dead_unit: Unit) -> void:
	if dead_unit != unit:
		return

	print("Unit died, handling state transition...")

	if not unit.alive:
		return  # Already handled

	unit.alive = false

	unit.unit_state_machine.request_transition(
		unit,
		unit.unit_state_machine.current_state,
		UnitState.State.IDLE,
		enemy
	)
