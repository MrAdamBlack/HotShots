extends UnitState

const DRAG_MINIMUM_THRESHOLD := 0.05

signal drag_canceled(starting_position: Vector2)
signal drag_started
signal dropped(starting_position: Vector2)

@export var enabled: bool = true
@export var target: Area2D

var starting_position: Vector2
var offset := Vector2.ZERO
var dragging := false
var minimum_drag_time_elapsed := false


func _ready() -> void:
	assert(target, "No target set for DragAndDrop Component!")
	target.input_event.connect(_on_target_input_event.unbind(1))


func enter() -> void:
	print("**********")
	print("FSM: Entering DragState")
	print("**********")
	#print("unit is of type: ", unit)
	#print("unit class_name: ", unit.get_class())
	start_dragging_from_script()
	
	#var ui_layer := get_tree().get_first_node_in_group("ui_layer")
	#if ui_layer:
		#unit.reparent(ui_layer)
	
	#unit.panel.set("theme_override_styles/panel", unit.DRAG_STYLEBOX)
	#Events.card_drag_started.emit(unit)
	
	minimum_drag_time_elapsed = false
	var threshold_timer := get_tree().create_timer(DRAG_MINIMUM_THRESHOLD, false)
	threshold_timer.timeout.connect(func(): minimum_drag_time_elapsed = true)

func _process(_delta: float) -> void:
	if dragging and target:
		target.global_position = target.get_global_mouse_position() + offset

func exit() -> void:
	print("FSM: Exiting DragState")
	#Events.card_drag_ended.emit(unit)

func _input(event: InputEvent) -> void:
	var mouse_motion := event is InputEventMouseMotion
	var confirm = (event.is_action_released("left_mouse") 
					or event.is_action_pressed("left_mouse"))
	
	if event.is_action_pressed("cancel_drag"):
		print("unit_drag_state.gd: Drag & Right Click")
		_cancel_dragging()
	elif event.is_action_released("select"):
		print("unit_drag_state.gd: Drag & Left Click")
		_drop()
		transition_requested.emit(self, UnitState.State.DROP)
	
	if mouse_motion:
		unit.global_position = get_viewport().get_mouse_position()
	#if minimum_drag_time_elapsed and confirm:
		#print("unit_drag_state.gd: Left Mouse Clicked")
		#get_viewport().set_input_as_handled()
		#transition_requested.emit(self, UnitState.State.DROP)

func _end_dragging() -> void:
	dragging = false
	target.remove_from_group("dragging")
	target.z_index = 0


func _cancel_dragging() -> void:
	_end_dragging()
	drag_canceled.emit(starting_position)


func _start_dragging() -> void:
	dragging = true
	starting_position = target.global_position
	target.add_to_group("dragging")
	target.z_index = 99
	#offset = target.global_position - target.get_global_mouse_position()
	print("->->-> unit_drag_state.gd: drag_started.emit()")
	drag_started.emit()
	
func _drop() -> void:
	_end_dragging()
	dropped.emit(starting_position)
	

func _on_target_input_event(_viewport: Node, event: InputEvent) -> void:
	if not enabled:
		return

	var dragging_object := get_tree().get_first_node_in_group("dragging")
	
	if not dragging and dragging_object:
		return
	
	if not dragging and event.is_action_pressed("select"):
		_start_dragging()
	
func start_dragging_from_script():
	_start_dragging()
