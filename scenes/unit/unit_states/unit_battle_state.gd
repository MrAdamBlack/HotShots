class_name Battle
extends UnitState

# This needs to be moved at the unit resource level
# Later problem
#var target_enemy: Unit = null  # Store the detected enemy
var attack_cooldown := 0.0


func enter() -> void:
	print("********** Entering Battle State ********** [%s] (%s)" % [unit.stats.name, unit])
	var attack_range = unit.stats.range_of_attack
	var distance_to_enemy = unit.global_position.distance_to(enemy.global_position)
	SignalBus.enemy_dead.connect(_on_enemy_death)

func _on_enemy_death(dead_unit: Unit) -> void:
	print("unit_battle_state.gd: ")
	print("\t_on_enemy_death()")
	print("\t<<<<<<<<< SIGNAL RECEIVED: enemy_dead")
	print("\tDead Unit: ", dead_unit.stats.name)
	if enemy and dead_unit == enemy:
		print("unit_battle_state.gd: Enemy died, clearing reference.")
		enemy = null
		# Transition to the MARCHING state after enemy death
		#unit_state_machine.request_transition(unit, 
							#unit_state_machine.current_state, 
							#UnitState.State.MARCHING, enemy)
	else:
		# If the dead enemy is not the current target, we might need to handle this differently
		print("unit_battle_state.gd: Dead unit is not the current target.")
		
	# After removing the enemy, check if there are other enemies to engage
	#_check_for_new_enemy()

	# This helper function is called to find a new closest enemy after the death of the current one
func _check_for_new_enemy() -> void:
	var closest_enemy = unit._find_closest_enemy()

	if closest_enemy:
		print("unit_battle_state.gd: New closest enemy found: ", closest_enemy)
		enemy = closest_enemy
		# You can also update any targeting system or AI behavior here

	else:
		print("unit_battle_state.gd: No enemies left, transitioning to POST_BATTLE.")
		unit_state_machine.request_transition(unit, 
							unit_state_machine.current_state, 
							UnitState.State.POST_BATTLE, enemy)


func _on_enemy_death_OLD(dead_unit: Unit) -> void:
	if enemy and dead_unit == enemy:
		print("unit_battle_state.gd: Enemy died, clearing reference.")
		enemy = null
		unit_state_machine.request_transition(unit, 
							unit_state_machine.current_state, 
							UnitState.State.MARCHING, enemy)

func exit() -> void:
	# Reset movement logic or any other needed cleanup
	unit.velocity_based_rotation.enabled = true  # Optionally re-enable rotation
	enemy = null
	print("********** Exiting Battle State ********** [%s] (%s)" % [unit.stats.name, unit])

# Process logic for moving the unit towards the enemy
func _process(delta: float) -> void:
	attack_cooldown += delta

	if enemy and enemy.alive and unit.global_position.distance_to(enemy.global_position) <= unit.stats.range_of_attack:
		if attack_cooldown >= 1.0 / unit.stats.attack_speed:
			attack_cooldown = 0.0
			enemy.take_damage(unit.stats.attack_power)
			
	attack_cooldown -= delta
	if attack_cooldown <= 0.0:
		attack_cooldown = unit.stats.attack_speed
		attack_target()

func attack_target() -> void:
	if not enemy or not is_instance_valid(enemy):
		# This never prints!
		print("unit_battle_state.gd: attack_target() > Transition to POST BATTLE")
		unit_state_machine.request_transition(unit, 
							unit_state_machine.current_state, 
							UnitState.State.POST_BATTLE, enemy)
		return
	#print("This PRINT works")
	enemy.take_damage(unit.stats.attack_damage)

func check_if_enemy_alive() -> bool:
	if enemy and enemy.alive:
		return true
	return false

func engage_enemy():
	if check_if_enemy_alive():
		# Apply damage, or engage the enemy
		enemy.stats.health -= unit.stats.attack_power  # assuming `attack_power` exists in unit_stats
		print("unit_battle_state.gd: Attacking enemy. Enemy's remaining health: ", enemy.stats.health)
		print("unit_battle_state.gd: ", unit.stats.name, " >>--attacking--> ", enemy.stats.name)

		if enemy.stats.health <= 0:
			handle_enemy_death()  # If enemy health drops to 0, handle death

func handle_enemy_death():
	print("unit_battle_state.gd: Enemy has died!")
	print("\tKiller: ", unit.stats.name)
	print("\tEnemy: ", enemy)
	enemy.alive = false
	Objectpool.return_clone(enemy)

#func reacquire_new_target():
	#var new_target = find_new_target()
	#if new_target:
		#player.target = new_target
		# Maybe change the state to 'engaged' or 'attacking' if needed


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
