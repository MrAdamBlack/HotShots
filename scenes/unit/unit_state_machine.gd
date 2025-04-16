class_name UnitStateMachine
extends Node

signal transition_requested(from: UnitState, to: UnitState.State)

@export var initial_state: UnitState
@onready var label: Label = %Label

var current_state: UnitState
var states := {}

func init(unit: Unit) -> void:
	print("Unit_state_machine.gd: Init()")
	
	for child: UnitState in get_children():
		
		
		
		if child:
			#print("Child: " + child.name)
			states[child.state] = child
			child.transition_requested.connect(_on_transition_requested)
			child.unit = unit
	
	if initial_state:
		initial_state.enter()
		current_state = initial_state


func on_input(event: InputEvent) -> void:
	#print("Unit State Machine on_input")
	if current_state:
		current_state.on_input(event)


func on_gui_input(event: InputEvent) -> void:
	#print("Unit State Machine on_gui_input")
	if current_state:
		current_state.on_gui_input(event)


func on_mouse_entered() -> void:
	#print("Unit State Machine on mouse ent")
	if current_state:
		current_state.on_mouse_entered()


func on_mouse_exited() -> void:
	#print("Unit State Machine on mouse exit")
	if current_state:
		current_state.on_mouse_exited()

func _on_transition_requested(from: UnitState, to: UnitState.State) -> void:
	print("Unit State Machine: Transition requested from %s to %s" % [from, to])

	if from != current_state:
		print("Rejected: not current state")
		return

	var new_state: UnitState = states.get(to)
	if not new_state:
		print("State not found: ", to)
		return

	if current_state:
		current_state.exit()

	new_state.enter()
	current_state = new_state

func request_transition(to: UnitState.State) -> void:
	if current_state:
		_on_transition_requested(current_state, to)
