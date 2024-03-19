extends Sprite2D

var enemy_detected
var base_movement_speed = 1
var movement_speed_modifier = 1.1
var friendly



# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if(not enemy_detected):
		move();
		
	
	pass




func move():
	position.x += base_movement_speed * movement_speed_modifier;
	

