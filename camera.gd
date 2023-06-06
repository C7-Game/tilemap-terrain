extends Camera2D

var speed = 200

func _ready():
	self.zoom *= 0.6 # zoom out a bit

func _physics_process(delta):
	var magnitude = speed * delta
	if Input.is_physical_key_pressed(KEY_A):
		global_position += Vector2.LEFT * magnitude
	if Input.is_physical_key_pressed(KEY_D):
		global_position += Vector2.RIGHT * magnitude
	if Input.is_physical_key_pressed(KEY_W):
		global_position += Vector2.UP * magnitude
	if Input.is_physical_key_pressed(KEY_S):
		global_position += Vector2.DOWN * magnitude
