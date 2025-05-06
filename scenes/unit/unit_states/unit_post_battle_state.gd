class_name UnitPostBattleState
extends UnitState


func _init() -> void:
	pass

func enter() -> void:
	print("********** Entering POST BATTLE State ********** [%s] (%s)" % [unit.stats.name, unit])

func exit() -> void:
	print("********** Exiting POST BATTLE State ********** [%s] (%s)" % [unit.stats.name, unit])

func _process(delta: float) -> void:
	pass
	#if unit.nearby_enemies.is_empty():
		#unit_state_machine.request_transition(self,
			#unit_state_machine.current_state,
			#UnitState.State.MARCHING)
			##no_more_enemies.emit()
			## This is the unit saying, there are no more enemies in my AOI
			## so, .... nothign should be done right... This should just maintain the list...
			## This transition should be done in POST BATTLE
			#
		#return

func _on_march_wave() -> void:
	pass

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


func _on_area_of_interest_entered(area: Area2D) -> void:
	print("Unit_marching_state.gd: _on_enemy_spotted")
	print("\tI am: ", unit.stats.name)
	print("\tSpotted: ", area)
	
	#var groups = area.get_groups()
	#var original_parent = area.get_parent()
	#var area_parent = original_parent
	#while area_parent != null and not area_parent is Unit:
		#area_parent = area_parent.get_parent()
#
	## Check if we reached the unit
	#if area_parent is Unit:
		#print("Enemy detected: ", area_parent)
		#if unit_state_machine.current_state == self:
			#unit_state_machine.request_transition(unit, 
						#unit_state_machine.current_state, 
						#UnitState.State.PRE_BATTLE, area_parent)
