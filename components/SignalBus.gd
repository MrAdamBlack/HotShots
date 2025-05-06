#class_name SignalBus
extends Node

#signal unit_bought(unit: Node)
signal unit_bought(unit: UnitStats)
signal unit_spawned(unit: Node)
#signal unit_selected(unit: Node)
#signal unit_state_changed(unit: Node, new_state: int)
#signal battle_started(attacker: Node, defender: Node)
signal game_over(winner: String)
#signal march_wave
#signal quick_sell_pressed
signal drag_started
#signal player_stats_changed
#signal drag_canceled(starting_position: Vector2)
signal dropped(starting_position: Vector2)
signal global_transition_requested(requester: Node, from: UnitState, to: UnitState.State, enemy: Unit)
signal unit_grid_changed(tile: Vector2i, unit: Node)
signal enemy_dead(dead_unit: Unit)
#signal enemy_removed_from_battle(enemy: Unit)
