extends Camera2D

var speed = 500
var current_zoom = 1

func update_zoom(amount: float):
	current_zoom += amount
	self.set_zoom(Vector2(1, 1) * current_zoom)

func _ready():
	self.zoom *= current_zoom # zoom out a bit

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
	if Input.is_physical_key_pressed(KEY_UP):
		update_zoom(0.5 * delta)
	if Input.is_physical_key_pressed(KEY_DOWN):
		update_zoom(-0.5 * delta)
