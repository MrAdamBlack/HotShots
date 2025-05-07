#@tool
class_name Unit
extends Area2D

signal quick_sell_pressed
signal enemy_spotted(enemy: Unit)
signal no_more_enemies

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
var nearby_enemies: Array = []
var current_target: Unit = null
var attackable_enemies := [] 
var enemy: Unit = null

func _ready() -> void:
	print("unit.gd. Unit READY: ", self)

	# Connect self_dead signal once
	if not stats.is_connected("self_dead", Callable(self, "_on_self_dead")):
		stats.self_dead.connect(Callable(self, "_on_self_dead"))
	
	# Connect enemy_dead signal once
	if not SignalBus.enemy_dead.is_connected(_on_enemy_dead):
		SignalBus.enemy_dead.connect(_on_enemy_dead)

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
	#print("unit.gd: Take Damage")
	#print("\t", self.stats.name, " is taking damage!!!")
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
	#if stats and SignalBus.enemy_dead.is_connected(self._on_health_depleted):
		#SignalBus.enemy_dead.disconnect(self._on_health_depleted)

	stats = value
	if value == null:
		return
	
	stats = value.duplicate()
	if not is_node_ready():
		await ready

	# Initialize health and connect to signal
	stats.health = stats.max_health

	skin.region_rect.position = Vector2(stats.skin_coordinates) * Arena.CELL_SIZE
	tier_icon.stats = stats
	update_health_bar()

#func _on_health_depleted(dead_unit: Unit) -> void:
	#print("unit.gd: _on_health_depleted")
	#print("\t Self: ", self.stats.name)
	#print("\t _Stats: ", dead_unit.stats.name)
	#
	#if dead_unit == self:
		#print(">>> unit.gd: I DIED", self.stats.name)
		##SignalBus.health_depleted.emit(self)
		#handle_death()
	#else:
		#print("Someone else died: ", dead_unit.stats.name)

func _find_closest_enemy() -> Unit:
	if nearby_enemies.size() == 0:
		return null  # No enemies in the list

	var closest_enemy: Unit = null
	var closest_distance = INF  # Start with an infinite distance

	for enemy in nearby_enemies:
		if enemy is Unit:  # Ensure the enemy is of type 'Unit'
			var distance = global_position.distance_squared_to(enemy.global_position)
			if distance < closest_distance:
				closest_distance = distance
				closest_enemy = enemy  # Cast to Unit

	return closest_enemy  # Return the closest Unit or null if no valid enemies

func _on_area_of_interest_area_entered(area: Area2D) -> void:
	nearby_enemies.append(area)
	nearby_enemies.sort_custom(func(a, b):
		return global_position.distance_squared_to(a.global_position) < global_position.distance_squared_to(b.global_position)
	)
	if nearby_enemies.size() == 1:
		enemy_spotted.emit(nearby_enemies[0])
#
func _on_area_of_interest_area_exited(area: Area2D) -> void:
	nearby_enemies.erase(area)

	 ##Check if the list is now empty → return to MARCHING
	#if nearby_enemies.is_empty():
		#if unit_state_machine.get_current_state_enum() != unit_state_machine.UnitState.State.MARCHING:
			#unit_state_machine.request_transition(self,
				#unit_state_machine.current_state,
				#UnitState.State.MARCHING)
		#no_more_enemies.emit()
		# This is the unit saying, there are no more enemies in my AOI
		# so, .... nothign should be done right... This should just maintain the list...
		# This transition should be done in POST BATTLE
		
		#return

	# Resolve Area2D to Unit
	var exited_parent = area.get_parent()
	while exited_parent != null and not exited_parent is Unit:
		exited_parent = exited_parent.get_parent()

	# If current target left, retarget to the new closest enemy
	if exited_parent == current_target and nearby_enemies.size() > 0:
		var new_target = nearby_enemies[0].get_parent()
		while new_target != null and not new_target is Unit:
			new_target = new_target.get_parent()
		if new_target != null:
			unit_state_machine.request_transition(self,
				unit_state_machine.current_state,
				UnitState.State.PRE_BATTLE,
				new_target)

func _on_range_of_attack_area_entered(area: Area2D) -> void:
	attackable_enemies.append(area)  # Add enemy to the list
	print("Added to attackable enemies: ", area.stats.name)
	_update_target()  # Update the target based on proximity

func _on_range_of_attack_area_exited(area: Area2D) -> void:
	if area in attackable_enemies:  # If the enemy is in the list, remove it
		attackable_enemies.erase(area)
		print("Removed from attackable enemies: ", area.stats.name)
		_update_target()  # Reevaluate the target if necessary

func _update_target() -> void:
	print("unit.gd: _update_target")
	if attackable_enemies.size() > 0:
		enemy = _find_closest_enemy()
		print("\tEnemy: ", enemy.stats.name)
		unit_state_machine.request_transition(self, 
				unit_state_machine.current_state, 
				UnitState.State.BATTLE, 
				enemy)
	else:
		enemy = null
		transition_to_post_battle()

func _on_enemy_dead(dead_unit: Unit) -> void:
	print("unit.gd: _on_enemy_dead")
	print("\tI am: ", self.stats.name)
	print("\tDead Unit: ", dead_unit.stats.name)
	if dead_unit == self:
		print("Disregard SIGNAL as I am the dead unit")
		print("\tUnit: ", self.stats.name)
		return
	# Remove from both tracking arrays
	if dead_unit in nearby_enemies:
		nearby_enemies.erase(dead_unit)

	if dead_unit in attackable_enemies:
		attackable_enemies.erase(dead_unit)
		_update_target()
		
func _on_self_dead(dead_stats: UnitStats) -> void:
	print("<<<<<<< unit.gd: SIGNAL self_dead")
	print("\tFunc: _on_self_dead")
	print("\tI am: ", dead_stats.name)
	#print("\tStack: ", get_stack())
	if dead_stats == self.stats:
		handle_death()
		print("\t>>> unit.gd: EMIT enemy_dead(", self.stats.name,")")
		# Check connection count before disconnecting
		print("\tConnection count BEFORE disconnecting: ", SignalBus.enemy_dead.get_connections().size())
		SignalBus.enemy_dead.disconnect(_on_enemy_dead)
		print("\tConnection count AFTER disconnecting: ", SignalBus.enemy_dead.get_connections().size())
		SignalBus.enemy_dead.emit(self)
		
		
	else:
		# This never calls...
		print("\tSomeone else died: ", dead_stats.name)

func transition_to_post_battle() -> void:
	unit_state_machine.request_transition(self, 
					unit_state_machine.current_state, 
					UnitState.State.POST_BATTLE)

func disconnect_enemy_dead_signal():
	if SignalBus.enemy_dead.is_connected(_on_enemy_dead):
		SignalBus.enemy_dead.disconnect(_on_enemy_dead)
		print("Unit.gd: Disconnected from enemy_dead")
