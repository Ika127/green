extends Sprite2D

var slot_card
var card_instance
var mouse_on_slot

func _process(delta):
	if Input.is_action_just_released("ui_mouse_left"):
		if card_instance and mouse_on_slot:
				if slot_card:
					if card_instance.slot_instance:
						slot_card.set_slot(card_instance.slot_instance)
					else:
						slot_card.slot_instance = null
				else:
					card_instance.slot_instance.slot_card = null
				card_instance.set_slot(self)
			
func _on_area_2d_area_entered(area):
	if area.get_parent().is_in_group("card"):
		card_instance = area.get_parent()

func _on_area_2d_area_exited(area):
	pass
			
func _on_area_2d_mouse_entered():
	mouse_on_slot = true

func _on_area_2d_mouse_exited():
	mouse_on_slot = false

