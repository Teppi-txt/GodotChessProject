extends TileMap
# tiles dict
var tile_size = 16
var tiles = {}

#White Pieces
onready var pieces = get_tree().get_nodes_in_group("pieces")

var clicked_start_tile = get_start_tile()
var clicked_end_tile = get_end_tile()

var moved_pieces = []

# initialize dicionary to have an entry for each tile
func _ready():
	for height in 8:
		for width in 8:
			var cell = Vector2(width, height)
			tiles[cell] = null

	for piece in pieces:
		tiles[Vector2(piece.position.x/tile_size, piece.position.y/tile_size)] = piece

func check_end_tile_validity(start_tile, end_tile):
	if start_tile != end_tile:
		if tiles[end_tile] == null:
			return true
		elif tiles[start_tile].get_parent() != tiles[end_tile].get_parent():
			return true
	return false

func piece_movement(start_tile, end_tile):
	if check_end_tile_validity(start_tile, end_tile):
		var dif_start_end = Vector2(abs(start_tile.x - end_tile.x), abs(start_tile.y - end_tile.y))
		var piece_name = tiles[start_tile].get_name()

		if "Pawn" in piece_name:
			var pawn_move = Vector2(0, -1)
			
			var pawn_take_white = [Vector2(1, -1), Vector2(-1, -1)]
			var pawn_take_black = [Vector2(1, 1), Vector2(-1, 1)]
			#identify bishop move pattern
			
			if tiles[start_tile].is_in_group("white_pieces"):
				if start_tile + pawn_move == end_tile && tiles[end_tile] == null:
					move_piece(start_tile, end_tile)
				elif tiles[end_tile] != null:
					for position in pawn_take_white:
						if start_tile + position == end_tile && tiles[end_tile].is_in_group("black_pieces"):
							move_piece(start_tile, end_tile)
				elif start_tile + pawn_move * 2 == end_tile && tiles[end_tile] == null && not tiles[start_tile] in moved_pieces:
					move_piece(start_tile, end_tile)
			elif tiles[start_tile].is_in_group("black_pieces"):
				if start_tile - pawn_move == end_tile && tiles[end_tile] == null:
					move_piece(start_tile, end_tile)
				elif tiles[end_tile] != null:
					for position in pawn_take_black:
						if start_tile + position == end_tile && tiles[end_tile].is_in_group("white_pieces"):
							move_piece(start_tile, end_tile)
				elif start_tile + pawn_move * -2 == end_tile && tiles[end_tile] == null && not tiles[start_tile] in moved_pieces:
					move_piece(start_tile, end_tile)

		elif "Bishop" in piece_name:
			#identify bishop move pattern
			if dif_start_end.x == dif_start_end.y:
				if !calculate_path_obstacle(start_tile, end_tile):
					move_piece(start_tile, end_tile)
		elif "Rook" in piece_name:
			#identify rook move pattern
			if (start_tile.x == end_tile.x) != (start_tile.y == end_tile.y):
				if !calculate_path_obstacle(start_tile, end_tile):
					move_piece(start_tile, end_tile)
		elif "King" in piece_name:
			#identify king move pattern
			if dif_start_end.x <= 1 and dif_start_end.y <= 1:
				if !calculate_path_obstacle(start_tile, end_tile):
					move_piece(start_tile, end_tile)
		elif "Queen" in piece_name:
			#identify queen move pattern
			if dif_start_end.x == dif_start_end.y or (start_tile.x == end_tile.x) != (start_tile.y == end_tile.y):
				if !calculate_path_obstacle(start_tile, end_tile):
					move_piece(start_tile, end_tile)
		elif "Knight" in piece_name:
			#identify knight move pattern
			if dif_start_end.x == 1 and dif_start_end.y == 2 or dif_start_end.x == 2 and dif_start_end.y == 1:
				move_piece(start_tile, end_tile)
	else:
		print("you are trying to move to the same square")

func calculate_path_obstacle(start_tile, end_tile):
	var dif_start_end = Vector2(end_tile - start_tile)
	
	if abs(dif_start_end.x) != abs(dif_start_end.y):
		for x in range(sign(end_tile.x - start_tile.x), dif_start_end.x, sign(dif_start_end.x)):
			var checked_tile = Vector2(start_tile.x + x, start_tile.y)
			if tiles[checked_tile] != null && x != 0:
				return true
		
		for y in range(sign(end_tile.y - start_tile.y), dif_start_end.y, sign(dif_start_end.y)):
			var checked_tile = Vector2(start_tile.x, start_tile.y + y)
			if tiles[checked_tile] != null:
				return true
	else:
		for i in range(abs(dif_start_end.x)):
			var checked_tile = Vector2(start_tile.x + i * sign(end_tile.x - start_tile.x), start_tile.y + i * sign(end_tile.y - start_tile.y))
			if tiles[checked_tile] != null && i != 0:
				return true

	return false

func move_piece(start_tile, end_tile):
	var piece_tween = tiles[start_tile].get_node("Tween")
	piece_tween.interpolate_property(tiles[start_tile], "position",
		start_tile * tile_size, end_tile * tile_size, 0.2,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		
	if tiles[end_tile] != null:
		tiles[end_tile].get_parent().remove_child(tiles[end_tile])
	if not tiles[start_tile] in moved_pieces:
		moved_pieces.append(tiles[start_tile])

	tiles[end_tile] = tiles[start_tile]
	tiles[start_tile] = null
	piece_tween.start()
	print(moved_pieces)

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
