extends Node2D

var deck_scene = preload("res://deck.tscn")
var card_scene = preload("res://card.tscn")
var slot_scene = preload("res://slot.tscn")

var card_instances = []

var player_hand = []
var dealer_hand = []
var player_slots = []
var dealer_slots = []

var deck_instance

var selected_cards_single_click = []
var selected_cards_double_click = []
# When clicking a stack of cards, all selected cards are added to the appropriate list
var single_click_helper_flag = true
var double_click_helper_flag = true
# When clicking a stack of cards, a signal is emitted for each card.
# This flag helps to run certain functions like rearrange_cards() only one per selection of a card stack.

func _ready():
	deck_instance = deck_scene.instantiate()
	deck_instance.position = Vector2(125, 175)
	add_child(deck_instance)
	
	for index in range(9):
		var slot_instance = slot_scene.instantiate()
		slot_instance.position = Vector2(125 + (index + 1) * 225, 500)
		add_child(slot_instance)
		player_slots.append(slot_instance)
		
	for index in range(9):
		var slot_instance = slot_scene.instantiate()
		slot_instance.position = Vector2(125 + (index + 1) * 225, 175)
		add_child(slot_instance)
		dealer_slots.append(slot_instance)
	
func instanciate_card(slot_instance, card):
	var card_instance = card_scene.instantiate()
	card_instance.card = card
	card_instance.position = deck_instance.position
	if not card.get("hidden"):
		card_instance.texture = load("res://cards/" + card_instance.card.get("texture"))
	else:
		card_instance.texture = load("res://cards/card-back2.png")
	card_instance.connect("double_click_card", double_click_card)
	card_instance.connect("single_click_card", single_click_card)
	card_instance.set_slot(slot_instance)
	add_child(card_instance)
	await get_tree().create_timer(0.25).timeout
	card_instances.append(card_instance)
	return card_instance

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
			indicies.append(card_instances.find(card_instance))
		indicies.sort() # find and sort indicies of the selected card in player_hand for ordering
		
		for index in indicies:
			card_instances[index].card_is_foreground = false
		card_instances[indicies[-1]].card_is_foreground = true
		card_instances[indicies[-1]].move_to_front()
		
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
		
		var _card_instances = card_instances.duplicate()
		for index in range(indicies_rotated.size()):
			card_instances[indicies[index]] = _card_instances[indicies_rotated[index]] # rearrange player hand to reflect new forground order

		for card_instance in card_instances:
			card_instance.move_to_front() # apply new forground order
	
		selected_cards_double_click = []
		double_click_helper_flag = false
		call_deferred("set_double_click_helper_flag_to_true")

func set_single_click_helper_flag_to_true():
	single_click_helper_flag = true
	
func set_double_click_helper_flag_to_true():
	double_click_helper_flag = true
	
func print_hands(verbose=false):
	if verbose:
		print("Player's Hand: ", player_hand, " ", calculate_end_value(calculate_hand_value(player_hand)), " ", calculate_hand_value(player_hand))
		print("Dealer's Hand: ", dealer_hand, " ", calculate_end_value(calculate_hand_value(dealer_hand)), " ", calculate_hand_value(dealer_hand))
	else:
		var player_cards = []
		var dealer_cards = []
		
		for card in player_hand:
			card = card.card
			player_cards.append(card.get("name") + " " + card.get("texture") + " " + str(card.get("value")))
		for card in dealer_hand:
			card = card.card
			if card.get("hidden"):
				dealer_cards.append("?")
			else:
				dealer_cards.append(card.get("name") + " " + card.get("texture") + " " + str(card.get("value")))
			
		print("Player's Hand: ", player_cards, " ")
		print("Dealer's Hand: ", dealer_cards, " ")

func _input(event):
	if event.is_action_pressed("deal"):
		
		print("Deal")
		
		await deal_card(dealer_hand, dealer_slots, true)
		await deal_card(player_hand, player_slots)
		await deal_card(dealer_hand, dealer_slots)
		await deal_card(player_hand, player_slots)
		
		if calculate_end_value(calculate_hand_value(dealer_hand)) == 21:
			
			print("Dealer wins! Blackjack!")
			clear()
			
	elif event.is_action_pressed("hit"):
		await deal_card(player_hand, player_slots)
		
		if calculate_end_value(calculate_hand_value(player_hand)) > 21:
			
			print("Bust! Player loses.")
			clear()
			
	elif event.is_action_pressed("stand"):
		
		print("Player stands.")
		await reveal_cards(dealer_hand)
		await get_tree().create_timer(1).timeout
		var above_seventeen = false
		while not above_seventeen:
			for value in calculate_hand_value(dealer_hand):
				if value < 17:
					await deal_card(dealer_hand, dealer_slots)
				else:
					above_seventeen = true
					
		var player_value = calculate_end_value(calculate_hand_value(player_hand))
		var dealer_value = calculate_end_value(calculate_hand_value(dealer_hand))
		
		if dealer_value > 21 or (player_value <= 21 and player_value > dealer_value):

			print("Player wins! ")
			clear()
			
		elif player_value == dealer_value:

			print("Push! Bets are returned. ")
			clear()

		else:

			print("Dealer wins! ")
			clear()


func shuffle_deck():
	deck_instance.shuffle()


func reveal_cards(hand):
	for card in hand:
		if card.card["hidden"]:
			card.flip_card = true
		card.card["hidden"] = false
		


func deal_card(hand, slots, hidden=false):
	var card = deck_instance.draw()
	card["hidden"] = hidden
	hand.append(await instanciate_card(slots[hand.size()], card))
	print_hands(false)
	await get_tree().create_timer(0.25).timeout

func calculate_combinations(lists, result = [], current_combination = [], current_index = 0):
	if current_index == lists.size():
		result.append(current_combination)
	else:
		var current_list = lists[current_index]
		for element in current_list:
			calculate_combinations(lists, result, current_combination + [element], current_index + 1)
	return result


func calculate_hand_value(hand):
	var card_values = []
	var result = []
	
	for card in hand:
		card = card.card
		card_values.append(card.get("value"))
		
	for possible_value_combination in calculate_combinations(card_values):
		var sum = 0
		for card_value in possible_value_combination:
			sum += card_value
		result.append(sum)
		
	return result


func clear():
	await get_tree().create_timer(1).timeout
	if deck_instance.deck.size() < 13:
		shuffle_deck()
		print("Deck shuffled")
	dealer_hand.clear()
	player_hand.clear()
	for card in card_instances:
		card.target_position = deck_instance.position
		card.flip_card = true
		await get_tree().create_timer(0.25).timeout
		card.queue_free()
	card_instances.clear()

func calculate_end_value(values):

	var lowestValue = values[0]
	for value in values:
		if value < lowestValue:
			lowestValue = value

	var highestValue = lowestValue
	for value in values:
		if value <= 21 and value > highestValue:
			highestValue = value
	
	return highestValue
