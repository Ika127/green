extends CollisionShape2D



# Called when the node enters the scene tree for the first time.
func _ready():
	
	#weird way to get the grandparents variable
	var child_node = get_parent()
	var parent_node = child_node.get_parent()
	var temp_friendly = parent_node.friendly
	
	if(not temp_friendly):
		position.x -= 50 #no idea why this has to be 50????



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
