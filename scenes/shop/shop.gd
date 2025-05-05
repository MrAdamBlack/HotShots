class_name Shop
extends Control

const UNIT_CARD = preload("res://scenes/unit_card/unit_card.tscn")
#signal unit_bought_relay(unit: UnitStats)
@export var unit_pool: UnitPool
@export var player_stats: PlayerStats
@onready var shop_cards: VBoxContainer = %ShopCards
@onready var unit_mover: UnitMover = $"../../UnitMover"

func _ready() -> void:
	unit_pool.generate_unit_pool()
	for child: Node in shop_cards.get_children():
		child.queue_free()
	_roll_units()
	#for card in shop_cards.get_children():
		#if card is UnitCard:
			#print("shop.gd: _ready(). Card: " + str(card.name))
			#card.unit_bought.connect(_on_unit_bought)
			#SignalBus.connect("unit_bought", Callable(self, "_on_unit_bought"))


func _roll_units() -> void:
	for i in 3: # was 5
		#var rarity := player_stats.get_random_rarity_for_level()
		#print("shop.gd - _roll_units() for i: " + str(i))
		#print("shop.gd - _roll_units(): var new_card: UnitCard = UNIT_CARD.instantiate()")
		#new_card.unit_stats = unit_pool.get_random_unit_by_rarity(rarity)
		#new_card.unit_bought.connect(_on_unit_bought)
		var new_card: UnitCard = UNIT_CARD.instantiate()
		new_card.unit_stats = unit_pool.get_next_unit()
		shop_cards.add_child(new_card)

func _put_back_remaining_to_pool() -> void:
	for unit_card: UnitCard in shop_cards.get_children():
		if not unit_card.bought:
			unit_pool.add_unit(unit_card.unit_stats)
		unit_card.queue_free()

#func _on_unit_bought(unit: UnitStats) -> void:
	#print("<-<-<- shop.gd: Signal Received: unit_bought")
	#print("->->-> shop.gd: Do nothing?")
	##unit_bought_relay.emit(unit)
	##SignalBus.unit_bought.emit(unit)

func _on_reroll_button_pressed() -> void:
	print("Reroll button pressed")
	_put_back_remaining_to_pool()
	_roll_units()

func get_cards() -> Array[UnitCard]:
	var cards: Array[UnitCard] = []
	for child in %ShopCards.get_children():
		if child is UnitCard:
			print("shop.gd. child READY: ", child.name, " | Parent: ", get_parent())
			cards.append(child as UnitCard)
	return cards
