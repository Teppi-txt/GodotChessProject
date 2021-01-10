extends Sprite

func _input(event):
	if event is InputEventMouseButton:
		var clicked_tile = Vector2(stepify(get_global_mouse_position().x, 16), stepify(get_global_mouse_position().y, 16))
		var dif_between_x = abs(position.x - clicked_tile.x)
		var dif_between_y = abs(position.y - clicked_tile.y)

		if dif_between_x == 16 and dif_between_y == 32 or dif_between_x == 32 and dif_between_y == 16:
			position = clicked_tile
