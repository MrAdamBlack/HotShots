extends UnitState

func enter() -> void:
	print("**********")
	print("Entering Drop State")
	print("**********")

func exit() -> void:
	print("**********")
	print("Exiting Drop State")
	print("**********")

func on_input(event: InputEvent) -> void:
	pass

func on_gui_input(event: InputEvent) -> void:
	pass

func on_mouse_entered() -> void:
	pass

func on_mouse_exited() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	pass
