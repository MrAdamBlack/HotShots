class_name IdleState
extends UnitState

func _init() -> void:
	pass

func enter() -> void:
	print("********** Entering Idle State ********** [%s] (%s)" % [unit.stats.name, unit])
	for group in unit.get_groups():
		if group == "dragging":
			unit.remove_from_group(group)
	SignalBus.connect("march_wave", Callable(self, "_on_march_wave"))

func exit() -> void:
	print("********** Exiting Idle State ********** [%s] (%s)" % [unit.stats.name, unit])

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		print("#### Space bar pressed, triggering march")
		_on_march_wave()  

func _on_march_wave() -> void:
	arena.unit_spawner.spawn_marching_clone(unit)

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
