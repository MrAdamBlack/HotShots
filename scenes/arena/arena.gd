class_name Arena
extends Node2D

const CELL_SIZE := Vector2(32, 32)
const HALF_CELL_SIZE := Vector2(16, 16)
const QUARTER_CELL_SIZE := Vector2(8, 8)

@onready var sell_portal: SellPortal = $SellPortal
@onready var unit_mover: UnitMover = $UnitMover
@onready var unit_spawner: UnitSpawner = $UnitSpawner
@onready var unit_combiner: UnitCombiner = $UnitCombiner
@onready var shop: Shop = %Shop

@export var arena_music_stream: AudioStream

func _ready() -> void:
	print("arena.gd: _ready()")
	shop.unit_bought_relay.connect(_on_unit_bought_relay)
	unit_spawner.unit_spawned.connect(_on_unit_spawned)
	
	for card in shop.get_cards():
		if card is UnitCard:
			print("arena.gd. _ready(): for card in shop.get_cards(), if UnitCard")
			card.unit_bought.connect(_on_unit_bought_relay)
	
	#unit_spawner.unit_spawned.connect(sell_portal.setup_unit)
	#unit_spawner.unit_spawned.connect(unit_combiner.queue_unit_combination_update.unbind(1))
	#shop.new_card.unit_bought.connect(unit_spawner.spawn_unit_at_mouse)
	
	#MusicPlayer.play(arena_music_stream)
	print("**********")
	print("arena.gd: Game finished loading ")
	print("**********")
	
func _on_unit_bought_relay(unit_stats: UnitStats) -> void:
	print("<-<-<- arena.gd: Signal Received: unit_bought_relay")
	unit_spawner.spawn_unit_at_mouse(unit_stats)
	
func _on_unit_spawned(unit: Unit) -> void:
	print("<-<-<- arena.gd: Signal Received: unit_spawned")
	unit_spawner.spawn_unit_at_mouse
	unit_mover.setup_unit
	
func _on_unit_bought(stats: UnitStats) -> void:
	print("arena.gd: _on_unit_bought")
	unit_spawner.spawn_unit_at_mouse(stats)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		unit_combiner.queue_unit_combination_update()
	elif event.is_action_pressed("KEY_1"):  # Using KEY_1 as an example
		print("+++Dev Comment: Game Just Loaded")
	elif event.is_action_pressed("KEY_2"):
		print("+++Dev Comment: About to Click on Shop")
	elif event.is_action_pressed("KEY_3"):
		print("+++Dev Comment: About to Left Click on Board")
	elif event.is_action_pressed("KEY_4"):
		print("+++Dev Comment: Unit Selected")
	elif event.is_action_pressed("KEY_5"):
		print("+++Dev Comment: Enemy Detected")
	elif event.is_action_pressed("KEY_6"):
		print("+++Dev Comment: Resource Gathered")
	elif event.is_action_pressed("KEY_7"):
		print("+++Dev Comment: Ability Used")
	elif event.is_action_pressed("KEY_8"):
		print("+++Dev Comment: Dialogue Started")
	elif event.is_action_pressed("KEY_9"):
		print("+++Dev Comment: Menu Opened")
