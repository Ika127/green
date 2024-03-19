extends Sprite2D

var initial_mouse_position # initial position of the mouse when selected, allows for smoother card movement 
var target_position = null # target position of lerp interpolation animation
var default_position = null
var target_rotation = 0

var count = 0
var increment = 1

var wiggle_direction = -1

var interpolation_speed = 10.0

var slot_instance = null

var card_is_foreground = false # card_is_foreground attribute is set by Main.gd, usage in selecting the top card of a card stack.
var mouse_on_card = false
var move_card = false
var lerp_card = true
var flip_card = false

var click_timer = 0.0
var double_click_time = 0.25

var card # holds a dictionary of card information like texture and name

signal double_click_card(card_instance)
signal single_click_card(card_instance)

func _ready():
	if not target_position:
		target_position = position
	if not default_position:
		default_position = position

func _process(delta):
	if Input.is_action_just_pressed("ui_mouse_left") and mouse_on_card:
		emit_signal("single_click_card", self)
		if click_timer > 0 and click_timer < double_click_time:
			emit_signal("double_click_card", self)
		else:
			click_timer = 0.0
		initial_mouse_position = get_global_mouse_position() - position
		move_card = true
	else:
		click_timer += delta
	
	if Input.is_action_just_pressed("ui_mouse_right") and mouse_on_card:
		pass
		
	if Input.is_action_just_released("ui_mouse_left"):
		move_card = false
		rotation_degrees = 0

	if (target_position-position).length() == 2.0:
		target_position = position
		
	if flip_card:
		scale = scale.lerp(Vector2(-0.1, scale.y), interpolation_speed * delta)
		if scale.x <= 0:
			if texture == load("res://cards/card-back2.png"):
				texture = load("res://cards/" + card.get("texture"))
			elif texture == load("res://cards/" + card.get("texture")):
				texture = load("res://cards/card-back2.png")
			flip_card = false
	else:
		scale = scale.lerp(Vector2(2.1, scale.y), interpolation_speed * delta)

	if lerp_card:
		position = position.lerp(target_position, interpolation_speed * delta)

	if move_card and card_is_foreground:
		position = get_global_mouse_position() - initial_mouse_position
		target_rotation = Input.get_last_mouse_velocity().x
		if target_rotation > 0:
			rotation_degrees += 1
		if target_rotation < 0:
			rotation_degrees -= 1
		rotation_degrees = clamp(rotation_degrees, -33, 33)
		rotation_degrees *= 0.95
	else:
		if count <= 100 and increment == 1:
			count += 1
		elif count > 100 and increment == 1:
			increment = -1
			count -= 1
		elif count >= -100 and increment == -1:
			count -= 1
		elif count < -100 and increment == -1:
			increment = 1
			count += 1
		target_rotation = count
		if target_rotation > 0:
			rotation_degrees += 0.1
		if target_rotation < 0:
			rotation_degrees -= 0.1
		rotation_degrees = clamp(rotation_degrees, -10, 10)
		rotation_degrees *= 0.95

		
	clamp_to_window()
	
func set_slot(_slot_instance):
	_slot_instance.slot_card = self
	slot_instance = _slot_instance
	target_position = slot_instance.position
	
func _on_area_2d_mouse_entered():
	mouse_on_card = true

func _on_area_2d_mouse_exited():
	mouse_on_card = false
	
func clamp_to_window():
	position.x = clamp(position.x, 50, get_viewport().size.x - 50)
	position.y = clamp(position.y, 75, get_viewport().size.y - 75)
