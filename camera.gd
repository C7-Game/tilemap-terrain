extends Camera2D
class_name PlayerCamera

var speed = 1000
var current_zoom = 1.0
var tiles: TileMap
var corners: CornerMap

func update_zoom(amount: float):
	current_zoom += amount
	self.set_zoom(Vector2(1, 1) * current_zoom)

func _ready():
	corners = get_parent().get_child(1).get_child(0) as CornerMap
	tiles = get_parent().get_child(1) as TileMap

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

	var edge = get_world_rect()
	var x = edge.end.x
	#print('edge of viewport:', edge.x)
	if x >= corners.edge.x:
		#print('OVER EDGE!')
		#set_global_position(Vector2(0, get_global_position().y))
		pass

func center_on_tile(pos: Vector2i):
	var tile_position = tiles.map_to_local(pos)
	self.set_global_position(tile_position)

func get_world_rect() -> Rect2:
	var vpt = self.get_viewport()
	var vpt_rect: Rect2 = self.get_viewport_rect()
	var global_to_vpt = vpt.global_canvas_transform * self.get_canvas_transform()
	var vpt_to_global: Transform2D = global_to_vpt.affine_inverse()
	return vpt_to_global * vpt_rect

func _input(event):
	if event is InputEventMouseButton and event.is_pressed():
		var edge = get_world_rect().end
		print('edge of viewport:', edge.x)
		if edge.x >= corners.edge.x:
			print('OVER EDGE!')
			#set_global_position(Vector2(0, get_global_position().y))
