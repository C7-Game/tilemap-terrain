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
		self.name = _name; self.abc = _abc; self.id = _id

class TerrainCorner:
	var tiles: Array # top, right, bottom, left
	var sorted: Array

	var terrains = [
		TerrainPcx.new('dpc', ['desert', 'plains', 'coast'], 0),
		# TerrainPcx.new('ggc', ['grassland', 'coast'], 1),
		TerrainPcx.new('dgp', ['desert', 'grassland', 'plains'], 2),
		TerrainPcx.new('pgc', ['plains', 'grassland', 'coast'], 3),
		TerrainPcx.new('cso', ['coast', 'sea', 'ocean'], 4),
		TerrainPcx.new('ooo', ['ocean'], 5),
	]

	func _init(types: Array):
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
		)
		if len(ts) == 0:
			#print(self.sorted)
			return terrains[0].id
		return ts[0].id

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

func fill(cell, id, atlas):
	self.set_cell(0, cell, id, atlas)

func tileIndexToTileSet(index, width) -> Vector2:
	var row = index % width
	var col = index / width
	return Vector2(col, row)

func test(width, height, tiles):
	var map = []
	map.resize(height)
	for y in range(0, height):
		map[y] = []
		for x in range(0, width):
			map[y].resize(width)
	
	self.clear_layer(0)
	for i in range(0, len(tiles)):
		var tile = tiles[i]
#		var x: int = tile['xCoordinate']
#		var y: int = tile['yCoordinate']
#		if x % 2 == 0 and y % 2 == 0:
#			x -= 1
#		map[y][x] = tiles[i]['baseTerrainTypeKey']

	for y in range(0, height):
		for x in range(0, width):
			var pos = Vector2(x, y)
			var left = 'coast' if x == 0 else map[y][x-1]
			var right = 'coast' if x == width-1 else map[y][x+1]
			var top = 'coast' if y == 0 else map[y-1][x]
			var bottom = 'coast' if y == height-1 else map[y+1][x]
			var lst = [top, right, bottom, left]
			var corner = TerrainCorner.new(lst)
			var sheet = corner.tileset()
			var index = corner.position()
			fill(pos, sheet, index)

func _ready():
	var file = FileAccess.open('res://c7-static-map-save.json', FileAccess.READ)
	var text = file.get_as_text()
	var json = JSON.parse_string(text)['gameData']
	var width: int = json['map']['numTilesWide']
	var height: int = json['map']['numTilesTall']
	var tiles = json['map']['tiles']
	test(width, height, tiles)
