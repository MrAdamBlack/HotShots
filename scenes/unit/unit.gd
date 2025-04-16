#@tool
class_name Unit
extends Area2D

signal quick_sell_pressed

@export var stats: UnitStats : set = set_stats


@onready var skin: Sprite2D = $Visuals/Skin
@onready var health_bar: ProgressBar = $HealthBar
@onready var mana_bar: ProgressBar = $ManaBar
@onready var tier_icon: TierIcon = $TierIcon
@onready var drag_and_drop: DragAndDrop = $DragAndDrop
@onready var velocity_based_rotation: VelocityBasedRotation = $VelocityBasedRotation
@onready var outline_highlighter: OutlineHighlighter = $OutlineHighlighter
@onready var animations: UnitAnimations = $UnitAnimations
@onready var unit_state_machine: UnitStateMachine = $UnitStateMachine as UnitStateMachine
@onready var range_of_attack: CollisionShape2D = $Visuals/Skin/Area2D/RangeOfAttack
@onready var label: Label = %Label
@onready var area_2d: Area2D = $Visuals/Skin/Area2D
@onready var unit_drag_state: Node = $UnitStateMachine/UnitDragState


var is_hovered := false


func _ready() -> void:
	print("unit.gd. Unit READY: ", self.name, " | Parent: ", get_parent())
	unit_drag_state.drag_started.connect(_on_drag_started)
	unit_drag_state.drag_canceled.connect(_on_drag_canceled)
	unit_state_machine.init(self)
	
	# Check if the shape is a CircleShape2D
	if range_of_attack.shape is CircleShape2D:
		var circle_shape = range_of_attack.shape as CircleShape2D
		circle_shape.radius = stats.range_of_attack
	await get_tree().process_frame


func _input(event: InputEvent) -> void:
	if not is_hovered:
		return
	
	if event.is_action_pressed("quick_sell"):
		quick_sell_pressed.emit()
		
	unit_state_machine.on_input(event)


func set_stats(value: UnitStats) -> void:
	stats = value
	
	if value == null:
		return
	
	if not Engine.is_editor_hint():
		stats = value.duplicate()
	
	if not is_node_ready():
		await ready
	
	skin.region_rect.position = Vector2(stats.skin_coordinates) * Arena.CELL_SIZE
	tier_icon.stats = stats


func reset_after_dragging(starting_position: Vector2) -> void:
	print("unit.gd: reset_after_dragging()")
	velocity_based_rotation.enabled = false
	global_position = starting_position

func _on_drag_started() -> void: # This just does sprite rotation
	print("unit.gd: _on_drag_started")
	velocity_based_rotation.enabled = true

func _on_drag_canceled(starting_position: Vector2) -> void:
	reset_after_dragging(starting_position)

func _on_gui_input(event: InputEvent) -> void:
	unit_state_machine.on_gui_input(event)

func _on_mouse_entered() -> void:
	if unit_drag_state.dragging:
		return
	
	is_hovered = true
	outline_highlighter.highlight()
	z_index = 1
	
	unit_state_machine.on_mouse_entered()


func _on_mouse_exited() -> void:
	if unit_drag_state.dragging:
		return
	
	is_hovered = false
	outline_highlighter.clear_highlight()
	z_index = 0
	
	unit_state_machine.on_mouse_exited()
