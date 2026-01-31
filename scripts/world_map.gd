extends TileMapLayer

func _ready() -> void:
	# Fill a 50x50 area with grass tiles
	# Assuming tile_grass.png is set up as a standard atlas with ID 0
	# We'll fill from -25,-25 to 25,25
	for x in range(-25, 26):
		for y in range(-25, 26):
			set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
