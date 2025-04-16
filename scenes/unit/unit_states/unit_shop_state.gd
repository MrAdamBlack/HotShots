#extends UnitState
#
#
#func enter() -> void:
	#if not unit.is_node_ready():
		#await unit.ready
		#
	#print("FSM: Entering ShopState")
#
	##if unit.tween and unit.tween.is_running():
		##unit.tween.kill()
##
	##unit.panel.set("theme_override_styles/panel", unit.BASE_STYLEBOX)
	##unit.reparent_requested.emit(unit)
	##unit.pivot_offset = Vector2.ZERO
	##Events.tooltip_hide_requested.emit()
	#
#func on_input(event: InputEvent) -> void:
	#if event.is_action_pressed("left_mouse"):
		#print("ShopState: Clicked, requesting transition to DRAG")
		#transition_requested.emit(self, UnitState.State.DRAG)
#
#func on_gui_input(event: InputEvent) -> void:
	#print("ShopState: on gui input")
	##if not unit.playable or unit.disabled:
		##return
##
	##if event.is_action_pressed("left_mouse"):
		##unit.pivot_offset = unit.get_global_mouse_position() - unit.global_position
		##transition_requested.emit(self, UnitState.State.CLICKED)
#
#
#func on_mouse_entered() -> void:
	#print("ShopState: Mouse Enter")
	##if not unit.playable or unit.disabled:
		##return
##
	##unit.panel.set("theme_override_styles/panel", unit.HOVER_STYLEBOX)
	##Events.card_tooltip_requested.emit(unit.card.icon, unit.card.tooltip_text)
#
#
#func on_mouse_exited() -> void:
	#print("ShopState: Mouse Exit")
	##if not unit.playable or unit.disabled:
		##return
##
	##unit.panel.set("theme_override_styles/panel", unit.BASE_STYLEBOX)
	##Events.tooltip_hide_requested.emit()
