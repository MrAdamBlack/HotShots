extends UnitState

const DRAG_MINIMUM_THRESHOLD := 0.05

@export var enabled: bool = true
@export var target: Area2D

var starting_position: Vector2
var offset := Vector2.ZERO
var dragging := false
var minimum_drag_time_elapsed := false


func _ready() -> void:
	pass

func enter() -> void:
	print("********** FSM: Entering DragState **********")
	
	for group in unit.get_groups():
		if group == "player1_unit":# or group == "player2_unit":
			start_dragging_from_script()
	
	minimum_drag_time_elapsed = false
	var threshold_timer := get_tree().create_timer(DRAG_MINIMUM_THRESHOLD, false)
	threshold_timer.timeout.connect(func(): minimum_drag_time_elapsed = true)

func _process(_delta: float) -> void:
	if dragging and target:
		target.global_position = target.get_global_mouse_position() + offset

func exit() -> void:
	SignalBus.dropped.emit()
	print("********** FSM: Exiting DragState **********")

func _input(event: InputEvent) -> void:
	if event.is_action_released("select"):
		_drop()

func _end_dragging() -> void:
	dragging = false
	unit.remove_from_group("dragging")
	unit.z_index = 0

func _cancel_dragging() -> void:
	_end_dragging()
	SignalBus.drag_canceled.emit(starting_position)

func _start_dragging() -> void:
	dragging = true
	starting_position = unit.global_position
	unit.add_to_group("dragging")
	unit.z_index = 99
	SignalBus.drag_started.emit()
	
func _drop() -> void:
	_end_dragging()	
	if unit_state_machine.current_state == self:
		unit_state_machine.request_transition(unit, unit_state_machine.current_state, UnitState.State.IDLE)

func start_dragging_from_script():
	_start_dragging()
