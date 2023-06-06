extends TileMap

enum Direction { N, NE, E, SE, S, SW, W, NW }

func neighbor(pos: Vector2i, dir: Direction) -> Vector2i:
	match dir:
		Direction.N: return Vector2i(pos.x, pos.y - 2)
		Direction.NE: return Vector2i(pos.x + 1, pos.y - 1)
		Direction.E: return Vector2i(pos.x + 1, pos.y)
		Direction.SE: return Vector2i(pos.x + 1, pos.y + 1)
		Direction.S: return Vector2i(pos.x, pos.y + 2)
		Direction.SW: return Vector2i(pos.x, pos.y + 1)
		Direction.W: return Vector2i(pos.x - 1, pos.y)
		Direction.NW: return Vector2i(pos.x, pos.y - 1)
		_:
			push_error('invalid direction')
			return pos

class TerrainPcx:
	var name: String
	var abc: Array
	var id: int
	func _init(_name, _abc, _id):
		self.name = _name
		self.abc = _abc
		self.id = _id


var map = [
	['grass', 'grass', 'grass', 'grass', 'grass', 'grass'],
	['plains', 'plains', 'plains', 'plains', 'plains', 'plains'],
	['grass', 'grass', 'grass', 'grass', 'grass', 'grass'],
	['plains', 'plains', 'plains', 'plains', 'plains', 'plains'],
	['grass', 'grass', 'grass', 'grass', 'grass', 'grass'],
	['grass', 'grass', 'grass', 'grass', 'grass', 'grass'],
	['grass', 'grass', 'grass', 'grass', 'grass', 'grass'],
	['plains', 'plains', 'plains', 'plains', 'plains', 'plains'],
	['grass', 'grass', 'grass', 'grass', 'grass', 'grass'],
	['plains', 'plains', 'plains', 'plains', 'plains', 'plains'],
	['grass', 'grass', 'grass', 'grass', 'grass', 'grass'],
	['plains', 'plains', 'plains', 'plains', 'plains', 'plains'],
]

class TerrainCorner:
	var tiles: Array[String] # top, right, bottom, left
	var sorted: Array

	var terrains = [
		TerrainPcx.new('dpc', ['desert', 'plains', 'coast'], 0),
		# TerrainPcx.new('ggc', ['grass', 'coast'], 1),
		TerrainPcx.new('dgp', ['desert', 'grass', 'plains'], 2),
		TerrainPcx.new('pgc', ['plains', 'grass', 'coast'], 3),
	]

	func _init(types: Array[String]):
		self.tiles = types
		var map = {}
		for t in types:
			map[t] = true
		var unique = map.keys()
		unique.sort()
		self.sorted = unique

	func tileset_abc(idx: int) -> Array:
		var ts = terrains.filter(func(e): return e.id == idx)[0]
		return ts.abc

	func tileset() -> int:
		var ts = terrains.filter(func(e):
			for kind in self.sorted:
				if not e.abc.has(kind):
					return false
			return true
		)[0]
		return ts.id

	func index_to_3d(idx: int) -> Vector2:
		return Vector2(idx % 9, idx / 9)

	func position() -> Vector2:
		var tc = self.tileset()
		var abc = tileset_abc(tc)
		var top = abc.find(self.tiles[0])
		var right = abc.find(self.tiles[1])
		var bottom = abc.find(self.tiles[2])
		var left = abc.find(self.tiles[3])
		var index = top + (left * 3) + (right * 9) + (bottom * 27)
		return self.index_to_3d(index)

func get_tileset_file(tc: TerrainCorner) -> int:
	if tc.has('grass') and tc.has('plains'):
		return 3
	return -1

func fill(cell, id, atlas):
	self.set_cell(0, cell, id, atlas)

func tileIndexToTileSet(index, width) -> Vector2:
	var row = index % width
	var col = index / width
	return Vector2(col, row)

func test():

	self.clear_layer(0)

	var width = 6
	var height = len(map)
	for y in range(0, height):
		for x in range(0, width):
			var pos = Vector2(x, y)
			var left = 'coast' if x == 0 else map[y][x-1]
			var right = 'coast' if x == width-1 else map[y][x+1]
			var top = 'coast' if y == 0 else map[y-1][x]
			var bottom = 'coast' if y == height-1 else map[y+1][x]
			var corner = TerrainCorner.new([top, right, bottom, left])
			var sheet = corner.tileset()
			var index = corner.position()
			fill(pos, sheet, index)

func _ready():
	test()
