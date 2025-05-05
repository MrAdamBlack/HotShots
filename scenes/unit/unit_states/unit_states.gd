class_name UnitState
extends Node

enum State {
	DRAG,       # User control
	IDLE,       # No user control
	MARCHING,   # No user control
	PRE_BATTLE, # No user control
	BATTLE, # No user control
	POST_BATTLE  # No user control
}

@onready var arena: Arena = find_arena()
@export var state: State
var enemy: Unit

var unit: Unit
var fsm: UnitStateMachine
var unit_state_machine: UnitStateMachine  # Reference to the state machine

func init(state_machine: UnitStateMachine, unit_node: Node = null, 
				previous_state: UnitState = null, enemy: Unit = null) -> void:
	self.unit_state_machine = state_machine
	self.unit = unit_node if unit_node else state_machine.current_state.unit
	self.fsm = state_machine
	self.enemy = enemy

func find_arena() -> Arena:
	var current = get_parent()
	while current and not (current is Arena):
		current = current.get_parent()
	return current as Arena

func enter() -> void:
	pass
	
func exit() -> void:
	pass

func on_input(_event: InputEvent) -> void:
	pass
	
func on_gui_input(_event: InputEvent) -> void:
	pass
	
# Reset the state, clearing any properties that are specific to this state
func reset() -> void:
	unit = null
	fsm = null
	enemy = null
	# Any other properties specific to this state can also be reset here

func on_mouse_entered() -> void:
	pass
	
func on_mouse_exited() -> void:
	pass
