extends Node2D

var deck_scene = preload("res://deck.tscn")
var card_scene = preload("res://card.tscn")
var slot_scene = preload("res://slot.tscn")
var battlefield_scene = preload("res://Battlefield.tscn")
var unit_scene = preload("res://Unit.tscn")


var player_hand = []
var player_slots = []

var deck_instance
var battlefield_instance
var unit_instance
var enemy_instance

var selected_cards_single_click = []
var selected_cards_double_click = []
# When clicking a stack of cards, all selected cards are added to the appropriate list
var single_click_helper_flag = true
var double_click_helper_flag = true
# When clicking a stack of cards, a signal is emitted for each card.
# This flag helps to run certain functions like rearrange_cards() only one per selection of a card stack.

func _ready():
	battlefield_instance = battlefield_scene.instantiate()
	battlefield_instance.position = Vector2(800,208)
	add_child(battlefield_instance)
	unit_instance = unit_scene.instantiate()
	#unit_instance.position = Vector2(randi_range(0,100),randi_range(20,390))
	unit_instance.position = Vector2(100,300)
	add_child(unit_instance)
	enemy_instance = unit_scene.instantiate()
	#enemy_instance.position = Vector2(randi_range(1100,1200),randi_range(20,390))
	enemy_instance.position = Vector2(700,300)
	enemy_instance.friendly = false
	add_child(enemy_instance)
	deck_instance = deck_scene.instantiate()
	deck_instance.position = Vector2(1100, 700)
	deck_instance.connect("draw_card", draw_card)
	add_child(deck_instance)
	
	for index in range(4):
		var slot_instance = slot_scene.instantiate()
		slot_instance.position = Vector2(125 + index * 225, 700)
		add_child(slot_instance)
		player_slots.append(slot_instance)

	var slot_instance = slot_scene.instantiate()
	slot_instance.position = Vector2(125, 550)
	add_child(slot_instance)
	player_slots.append(slot_instance)
	
func draw_card():
	for index in range(4):
		var card_instance = card_scene.instantiate()
		card_instance.card = deck_instance.deck.pop_back()
		card_instance.position = deck_instance.position
		card_instance.texture = load("res://cards/" + card_instance.card.get("texture"))
		card_instance.connect("double_click_card", double_click_card)
		card_instance.connect("single_click_card", single_click_card)
		card_instance.set_slot(player_slots[index])
		add_child(card_instance)
		player_hand.append(card_instance)
		
		await get_tree().create_timer(0.25).timeout
		
func _process(delta):
	if Input.is_action_just_pressed("ui_spacebar"):
		for index in range(4):
				if player_slots[index].slot_card:
					print(player_slots[index].slot_card.card)
					print(player_slots[index].card_instance)
		
func double_click_card(card_instance):
	selected_cards_double_click.append(card_instance)
	call_deferred("rearrange_cards") # call after all card signals have been handeled

func single_click_card(card_instance):
	selected_cards_single_click.append(card_instance)
	call_deferred("select_single_card")

func select_single_card():
	if single_click_helper_flag:
		
		var indicies = []
		for card_instance in selected_cards_single_click:
			indicies.append(player_hand.find(card_instance))
		indicies.sort() # find and sort indicies of the selected card in player_hand for ordering
		
		for index in indicies:
			player_hand[index].card_is_foreground = false
		player_hand[indicies[-1]].card_is_foreground = true
		player_hand[indicies[-1]].move_to_front()
		
		selected_cards_single_click = []
		single_click_helper_flag = false
		call_deferred("set_single_click_helper_flag_to_true") # since select_single_card will be called x times, set helper flag to true only if finished
	
func rearrange_cards():
	if double_click_helper_flag:
		
		var indicies = []
		for card_instance in selected_cards_double_click:
			indicies.append(player_hand.find(card_instance))
			
		var indicies_rotated = indicies
		indicies_rotated = indicies.slice(1)
		indicies_rotated.append(indicies[0]) # right rotatate elements of list, used as new forground order
		
		var _player_hand = player_hand.duplicate()
		for index in range(indicies_rotated.size()):
			player_hand[indicies[index]] = _player_hand[indicies_rotated[index]] # rearrange player hand to reflect new forground order

		for card_instance in player_hand:
			card_instance.move_to_front() # apply new forground order
	
		selected_cards_double_click = []
		double_click_helper_flag = false
		call_deferred("set_double_click_helper_flag_to_true")

func set_single_click_helper_flag_to_true():
	single_click_helper_flag = true
	
func set_double_click_helper_flag_to_true():
	double_click_helper_flag = true
