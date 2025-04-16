class_name UnitState
extends Node

enum State {DRAG, DROP, # User control
			IDLE, MARCHING, # No user control
			BATTLE_PREP, BATTLE, BATTLE_END} # No user control

signal transition_requested(from: UnitStats, to: State)

@export var state: State

var unit: Unit

func enter() -> void:
	pass
	
func exit() -> void:
	pass

func on_input(_event: InputEvent) -> void:
	pass
	
func on_gui_input(_event: InputEvent) -> void:
	pass

func on_mouse_entered() -> void:
	pass
	
func on_mouse_exited() -> void:
	pass
