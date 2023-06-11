extends TileMap
class_name CornerMap

@export var edge: Vector2

class TerrainPcx:
	var name: String
	var abc: Array
	var id: int
	func _init(_name, _abc, _id):
		self.name = _name; self.abc = _abc; self.id = _id
	func valid_for(tiles: Array) -> bool:
		return tiles.all(func(tile): return abc.has(tile))

class TerrainCorner:
	var tiles: Array # top, right, bottom, left

	var terrains: Array[TerrainPcx] = [
		TerrainPcx.new('dpc', ['desert', 'plains', 'coast'], 0),
		#TerrainPcx.new('ggc', ['grassland', 'grassland', 'coast'], 1),
		TerrainPcx.new('dgp', ['desert', 'grassland', 'plains'], 2),
		TerrainPcx.new('pgc', ['plains', 'grassland', 'coast'], 3),
		TerrainPcx.new('cso', ['coast', 'sea', 'ocean'], 4),
		TerrainPcx.new('ooo', ['ocean', 'ocean', 'ocean'], 5),
		TerrainPcx.new('tgc', ['tundra', 'grassland', 'coast'], 6),
		TerrainPcx.new('dgc', ['desert', 'grassland', 'coast'], 7),
		TerrainPcx.new('sss', ['sea', 'sea', 'sea'], 8),
	]

	func get_valid_tile_sets() -> Array[TerrainPcx]:
		return terrains.filter(func(terrain): return terrain.valid_for(self.tiles))

	func _init(types: Array):
		self.tiles = types

	func tileset() -> TerrainPcx:
		return get_valid_tile_sets().pick_random()

	func index_to_3d(idx: int) -> Vector2:
		return Vector2(idx % 9, idx / 9)

	func abc_index(abc, name):
		var indices = []
		for i in range(0, len(abc)):
			if abc[i] == name:
				indices.append(i)
		return indices.pick_random()

	func position(abc) -> Vector2:
		var top = abc_index(abc, tiles[0])
		var right = abc_index(abc, tiles[1])
		var bottom = abc_index(abc, tiles[2])
		var left = abc_index(abc, tiles[3])
		var index = top + (left * 3) + (right * 9) + (bottom * 27)
		return self.index_to_3d(index)

func fill(cell, id, atlas):
	self.set_cell(0, cell, id, atlas)

func populate_tiles(width, height, tiles):
	var map = []
	map.resize(height)
	for y in range(0, height):
		map[y] = []
		for x in range(0, width):
			map[y].resize(width)
	
	self.clear_layer(0)
	for i in range(0, len(tiles)):
		var tile = tiles[i]
		var x: int = tile['xCoordinate']
		var y: int = tile['yCoordinate']
		# convert to stacked coordinate system
		x = x / 2 if y % 2 == 0 else (x - 1) / 2
		map[y][x] = tiles[i]['baseTerrainTypeKey']

	for y in range(0, height):
		for x in range(0, width):
			var pos = Vector2(x, y)
			var left = map[y][x]
			var right = map[y][(x+1) % width]

			var even = y % 2 == 0
			var top = 'coast'
			if y > 0:
				top = map[y-1][x] if even else map[y-1][(x+1) % width]
			var bottom = 'coast'
			if y != height-1:
				bottom = map[y+1][x] if even else map[y+1][(x+1) % width]

			var lst = [top, right, bottom, left]
			var corner = TerrainCorner.new(lst)
			var ts = corner.tileset()
			var index = corner.position(ts.abc)
			fill(pos, ts.id, index)

func _ready():
	var file = FileAccess.open('res://c7-static-map-save.json', FileAccess.READ)
	var json = JSON.parse_string(file.get_as_text())['gameData']
	var width: int = json['map']['numTilesWide'] / 2
	var height: int = json['map']['numTilesTall']
	var tiles = json['map']['tiles']
	populate_tiles(width, height, tiles)
	edge = to_global(map_to_local(Vector2i(79, 0)))
	edge.x += 64
	print('map edge: ', edge)
