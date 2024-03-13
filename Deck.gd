extends Sprite2D

var mouse_on_deck = false
var deck = []

signal draw_card

func _ready():
	generate_deck()
	deck.shuffle()
	
func generate_deck():
	var ranks = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
	var suits = ["hearts", "diamonds", "clubs", "spades"]
	var value
	for suit in suits:
		for rank in ranks:
			if rank == 1:
				value = [11, 1]
			elif rank > 10:
				value = [10]
			else:
				value = [int(rank)]
			deck.append({"texture": "card" + "-" + suit + "-" + str(rank) + ".png", "value": value, "hidden": false})
	
func _process(_delta):
	if Input.is_action_just_pressed("ui_mouse_left") and mouse_on_deck:
		emit_signal("draw_card")

func draw():
	return deck.pop_back()

func _on_area_2d_mouse_entered():
	mouse_on_deck = true

func _on_area_2d_mouse_exited():
	mouse_on_deck = false
