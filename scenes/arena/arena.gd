class_name Arena
extends Node2D

const CELL_SIZE := Vector2(32, 32)
const HALF_CELL_SIZE := Vector2(16, 16)
const QUARTER_CELL_SIZE := Vector2(8, 8)

signal march_wave

@onready var sell_portal: SellPortal = $SellPortal
@onready var unit_mover: UnitMover = $UnitMover
@onready var unit_spawner: UnitSpawner = $UnitSpawner
@onready var shop: Shop = %Shop
#@onready var timer: Timer = $Timer
#@onready var unit_combiner: UnitCombiner = $UnitCombiner

@export var arena_music_stream: AudioStream


func _ready() -> void:
	print("@ Arena.gd _ready()")
	SignalBus.connect("unit_spawned", Callable(self, "sell_portal.setup_unit"))
	#MusicPlayer.play(arena_music_stream)
	#timer.start(10)
	#timer.connect("timeout", _on_Timer_timeout)

func _on_Timer_timeout() -> void:
	print("->->-> arena.gd: march_wave.emit()")
	SignalBus.march_wave.emit()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("KEY_1"):  # Using KEY_1 as an example
		print("++++++ Dev Comment:")
		print("       Game Just Loaded")
	elif event.is_action_pressed("KEY_2"):
		print("++++++ Dev Comment:")
		print("       Starting Drag")
	elif event.is_action_pressed("KEY_3"):
		print("++++++ Dev Comment:")
		print("       Release Drag")
	elif event.is_action_pressed("KEY_4"):
		print("++++++ Dev Comment:")
		print("       About to click on board. No unit in hand")
	elif event.is_action_pressed("KEY_5"):
		print("++++++ Dev Comment:")
		print("       Enemy Detected")
	elif event.is_action_pressed("KEY_6"):
		print("++++++ Dev Comment:")
		print("       Resource Gathered")
	elif event.is_action_pressed("KEY_7"):
		print("++++++ Dev Comment:")
		print("       Ability Used")
	elif event.is_action_pressed("KEY_8"):
		print("++++++ Dev Comment:")
		print("       Dialogue Started")
	elif event.is_action_pressed("KEY_9"):
		print("++++++ Dev Comment:")
		print("       About to press Space Bar to deploy units!")
