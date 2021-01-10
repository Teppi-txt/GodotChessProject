extends TileMap
# tiles dict
var tile_size = 16
var tiles := {}

#White Pieces

onready var pieces = [get_tree().get_nodes_in_group("pieces")]
var clicked_start_tile = get_start_tile()
var clicked_end_tile = get_end_tile()

# initialize dicionary to have an entry for each tile
func _ready():
	for height in 8:
		for width in 8:
			var cell = Vector2(width, height)
			tiles[cell] = null

	for piece in pieces:
		tiles[Vector2(piece.position.x/tile_size, piece.position.y/tile_size)] = piece

func piece_movement(start_tile, end_tile):
	if start_tile != end_tile && tiles[end_tile] == null:
		var dif_start_end = Vector2(abs(start_tile.x - end_tile.x), abs(start_tile.y - end_tile.y))
		var piece_name = tiles[start_tile].get_name()
		
		if "Bishop" in piece_name:
			#identify bishop move pattern
			if dif_start_end.x == dif_start_end.y:
				move_piece(start_tile, end_tile)
		elif "Rook" in piece_name:
			#identify rook move pattern
			if (start_tile.x == end_tile.x) != (start_tile.y == end_tile.y):
				move_piece(start_tile, end_tile)
		elif "King" in piece_name:
			#identify king move pattern
			if dif_start_end.x <= 1 and dif_start_end.y <= 1:
				move_piece(start_tile, end_tile)
		elif "Queen" in piece_name:
			#identify queen move pattern
			if dif_start_end.x == dif_start_end.y or (start_tile.x == end_tile.x) != (start_tile.y == end_tile.y):
				move_piece(start_tile, end_tile)

	else:
		print("you are trying to move to the same square")

func move_piece(start_tile, end_tile):
	tiles[end_tile] = tiles[start_tile]
	tiles[start_tile] = null
	tiles[end_tile].position = Vector2(end_tile.x * tile_size, end_tile.y * tile_size)
	
func get_start_tile():
	if Input.is_action_just_pressed("mouse_just_pressed") && clicked_start_tile == null:
		var start_tile = Vector2(stepify(get_global_mouse_position().x, tile_size), stepify(get_global_mouse_position().y, tile_size))/Vector2(tile_size, tile_size)
		if tiles[start_tile] != null:
			clicked_start_tile = start_tile

func get_end_tile():
	if Input.is_action_just_pressed("mouse_just_pressed") && clicked_start_tile != null:
		var end_tile = Vector2(stepify(get_global_mouse_position().x, tile_size), stepify(get_global_mouse_position().y, tile_size))/Vector2(tile_size, tile_size)
		clicked_end_tile = end_tile

func _process(delta):
	get_end_tile()
	get_start_tile()

	if clicked_end_tile != null:
		piece_movement(clicked_start_tile, clicked_end_tile)
		clicked_start_tile = null
		clicked_end_tile = null
