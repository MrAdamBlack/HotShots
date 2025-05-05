class_name PreBattle
extends UnitState

# This needs to be moved at the unit resource level
# Later problem
#@export var march_speed: float = 1.0
#var enemy: Unit

func enter() -> void:
	print("********** Entering Pre-Battle State ********** [%s] (%s)" % [unit.stats.name, unit])
	if enemy:
		print("Targeting enemy: ", enemy.name)
	else:
		print("No target enemy assigned.")
	
	unit.velocity_based_rotation.enabled = false  # Disable rotation while moving

func exit() -> void:
	# Reset movement logic or any other needed cleanup
	unit.velocity_based_rotation.enabled = true  # Optionally re-enable rotation
	print("********** Exiting Pre-Battle State ********** [%s] (%s)" % [unit.stats.name, unit])

func _process(delta: float) -> void:
	if unit == null:
		return
	if not unit.alive or not is_instance_valid(unit):
		print("Exiting PreBattle state due to unit death.")
		unit_state_machine.request_transition(unit, 
							unit_state_machine.current_state, 
							UnitState.State.IDLE, enemy)
		return
	
	var attack_range = unit.stats.range_of_attack
	var march_speed = unit.stats.march_speed
	# Check if we have a valid target enemy
	if enemy and enemy.is_inside_tree():
		# Calculate direction to the enemy
		var direction_to_enemy = (enemy.global_position - unit.global_position).normalized()
		# Move the unit towards the enemy
		unit.position += direction_to_enemy * march_speed * delta
		var distance_to_enemy = unit.global_position.distance_to(enemy.global_position)
		if unit_state_machine.current_state == self and distance_to_enemy <= attack_range:
			unit_state_machine.request_transition(unit, 
							unit_state_machine.current_state, 
							UnitState.State.BATTLE, enemy)

func is_enemy_in_attack_range(enemy: Unit) -> bool:
	var attack_range = unit.stats.range_of_attack
	var distance_to_enemy = unit.global_position.distance_to(enemy.global_position)
	return distance_to_enemy <= attack_range

func set_enemy(enemy: Unit) -> void:
	self.enemy = enemy

func _on_enemy_death(dead_stats: UnitStats) -> void:
	if enemy and dead_stats == enemy.stats:
		print("Enemy died: clearing target")
		enemy = null

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
