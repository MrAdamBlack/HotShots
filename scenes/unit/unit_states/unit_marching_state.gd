class_name MarchingState
extends UnitState

# Speed in pixels per second for marching
@export var march_speed: float = 100.0

func enter() -> void:
	print("********** Entering Marching State ********** [%s] (%s)" % [unit.stats.name, unit])
	unit.enemy_spotted.connect(_on_enemy_spotted)
	#unit.area_of_interest.monitoring = true
	#unit.area_of_interest.monitorable = true
	#unit.area_of_interest.area_entered.connect(_on_area_of_interest_entered)
	
	for group in unit.get_groups():
		if group == "dragging":
			unit.remove_from_group(group)

#func _on_area_of_interest_entered(area: Area2D) -> void:
func _on_enemy_spotted(area: Area2D) -> void:
	print("Unit_marching_state.gd: _on_enemy_spotted")
	print("\tI am: ", unit.stats.name)
	print("\tSpotted: ", area)
	
	var groups = area.get_groups()
	var original_parent = area.get_parent()
	var area_parent = original_parent
	while area_parent != null and not area_parent is Unit:
		area_parent = area_parent.get_parent()

	# Check if we reached the unit
	if area_parent is Unit:
		print("Enemy detected: ", area_parent)
		if unit_state_machine.current_state == self:
			unit_state_machine.request_transition(unit, 
						unit_state_machine.current_state, 
						UnitState.State.PRE_BATTLE, area_parent)

func exit() -> void:
	print("********** Exiting Marching State ********** [%s] (%s)" % [unit.stats.name, unit])

func _process(delta: float) -> void:
	# Move the unit to the right based on the march speed
	#unit.velocity_based_rotation.enabled = false
	var direction := Vector2.RIGHT  # Default

	if unit.is_in_group("player2_clone"):
		direction = Vector2.LEFT
	unit.position += direction * march_speed * delta

func on_input(event: InputEvent) -> void:
	pass

func on_gui_input(event: InputEvent) -> void:
	pass

func on_mouse_entered() -> void:
	pass

func on_mouse_exited() -> void:
	pass

func _physics_process(delta: float) -> void:
	pass
