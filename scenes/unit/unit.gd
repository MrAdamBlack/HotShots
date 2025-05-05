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
@onready var label: Label = %Label
@onready var area_of_interest: Area2D = $Visuals/Skin/AreaOfInterest
@onready var collision_area_of_interest: CollisionShape2D = $Visuals/Skin/AreaOfInterest/CollisionAreaOfInterest

var alive := true
var is_hovered := false

func _ready() -> void:
	print("unit.gd. Unit READY: ", self)
	#SignalBus.health_depleted.connect(_on_health_depleted)
	# Ensure that Unit is connected to the health-depleted signal of UnitStats
	stats.self_dead.connect(_on_self_dead)

	if collision_area_of_interest.shape is CircleShape2D:
		collision_area_of_interest.shape.radius = stats.area_of_interest
	else:
		print("ERROR ERROR ERROR 0")
		
	#SignalBus.connect("drag_started", Callable(self, "_on_drag_started"))
	SignalBus.connect("drag_canceled", Callable(self, "_on_drag_canceled"))
	await get_tree().process_frame

func _input(event: InputEvent) -> void:
	if not is_hovered:
		return
	#if event.is_action_pressed("quick_sell"):
		##quick_sell_pressed.emit()
		#SignalBus.quick_sell_pressed.emit()
	#unit_state_machine.on_input(event)

func reset_after_dragging(starting_position: Vector2) -> void:
	velocity_based_rotation.enabled = false
	global_position = starting_position

func _on_drag_canceled(starting_position: Vector2) -> void:
	reset_after_dragging(starting_position)

func _on_gui_input(event: InputEvent) -> void:
	unit_state_machine.on_gui_input(event)

func _on_mouse_entered() -> void:
	is_hovered = true
	outline_highlighter.highlight()
	z_index = 1
	unit_state_machine.on_mouse_entered()

func _on_mouse_exited() -> void:
	is_hovered = false
	outline_highlighter.clear_highlight()
	z_index = 0
	unit_state_machine.on_mouse_exited()
	
func reset() -> void:
	self.alive = true
	self.stats.health = self.stats.max_health
	#self.health_bar.value = 100
	self.position = Vector2(0, 0)  # This needs to go back to starting point
	unit_state_machine.reset()
	
	# Defer updating the health bar to the next frame
	call_deferred("_update_health_bar")
	# Reset any additional properties: buffs, debuffs, velocity, etc.
	
func _update_health_bar() -> void:
	if health_bar:  # Ensure health_bar is not null
		health_bar.value = stats.health / stats.max_health * health_bar.max_value

func update_health_bar() -> void:
	var current := stats.health
	var maximum := stats.max_health

	# Ensure we don't divide by zero
	if maximum <= 0:
		health_bar.value = 0
	else:
		health_bar.value = current / maximum * health_bar.max_value

func take_damage(amount: float) -> void:
	stats.health -= amount
	stats.health = max(stats.health, 0)
	update_health_bar()

func handle_death() -> void:
	print("unit.gd: handle_death")
	print("\t Self: ", self.stats.name)
	Objectpool.return_clone(self)
	# Transition out of the current state if the unit is dead
	if unit_state_machine.current_state is PreBattle:
		unit_state_machine.request_transition(self, unit_state_machine.current_state, UnitState.State.IDLE)
		# Or whatever state makes sense after death, such as IDLE, or a POST_DEATH state

func is_dead() -> bool:
	return stats.health <= 0

func set_stats(value: UnitStats) -> void:
	# Disconnect from old stats if needed
	#if stats and SignalBus.health_depleted.is_connected(self._on_health_depleted):
		#SignalBus.health_depleted.disconnect(self._on_health_depleted)
	if stats and SignalBus.enemy_dead.is_connected(self._on_health_depleted):
		SignalBus.enemy_dead.disconnect(self._on_health_depleted)

	stats = value
	if value == null:
		return
	if not Engine.is_editor_hint():
		stats = value.duplicate()
	if not is_node_ready():
		await ready

	# Initialize health and connect to signal
	stats.health = stats.max_health
	#SignalBus.health_depleted.connect(self._on_health_depleted)

	skin.region_rect.position = Vector2(stats.skin_coordinates) * Arena.CELL_SIZE
	tier_icon.stats = stats
	update_health_bar()

func _on_health_depleted(dead_unit: Unit) -> void:
	print("unit.gd: _on_health_depleted")
	print("\t Self: ", self.stats.name)
	print("\t _Stats: ", dead_unit.stats.name)
	
	if dead_unit == self:
		print(">>> unit.gd: I DIED", self.stats.name)
		#SignalBus.health_depleted.emit(self)
		handle_death()
	else:
		print("Someone else died: ", dead_unit.stats.name)

func _on_self_dead(dead_stats: UnitStats) -> void:
	print("unit.gd: _on_self_dead")
	print("\t%s has died!" % dead_stats.name)
	if dead_stats == self.stats:
		print("\t>>> unit.gd: I DIED ", self.stats.name)
		SignalBus.enemy_dead.emit(self)
		handle_death()
	else:
		print("\tSomeone else died: ", dead_stats.name)
	# Handle unit death logic here, such as state transition or cleanup
	#unit_state_machine.request_transition(unit, unit_state_machine.current_state, UnitState.State.DEAD, enemy)
