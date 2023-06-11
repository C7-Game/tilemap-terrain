extends TileMap

var camera: PlayerCamera = null

func _ready():
	camera = get_parent().get_child(0) as PlayerCamera

func fill(cell, id, atlas):
	self.set_cell(0, cell, id, atlas)

func global_to_tile(position: Vector2) -> Vector2i:
	return local_to_map(to_local(position))

func _input(event):
	if event is InputEventMouseButton and event.is_pressed():
		var gmp = get_global_mouse_position()
		var tile = global_to_tile(gmp)
		print('clicked on tile', tile)
		camera.center_on_tile(tile)
