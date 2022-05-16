extends Node2D
class_name Mine


export(int) var width := Global.MAP_WIDTH
export(int) var num_sections := 10
export(int) var section_height := 10
export(float) var min_density := 0.1
export(float) var max_density := 0.5

var height: int
var block_map := []

onready var debug_tilemap := $Debug


func _ready() -> void:
	Events.connect("lizard_attacked", self, "_on_lizard_attacked")
	
	generate()


func generate() -> void:
	debug_tilemap.clear()
	block_map.clear()
	
	height = section_height * num_sections
	
	for x in width:
		var column := []
		for y in height:
			var border: bool = (x == 0) or (y == 0) or (x == width-1) or y == (height-1)
			column.append(Block.new(false, border, 0, true, false))
		block_map.append(column)
	
	# Place sections, and mines in those sections.
	var y_offset := 0
	for section in num_sections:
		var current_density: float = lerp(min_density, max_density, float(section) / (num_sections-1))
		
		for y in section_height:
			for x in width:
				block_map[x][y_offset + y].is_mine = randf() < current_density
		
		y_offset += section_height
	
	# Enforce some structure.
	block_map[7][0].is_border = false
	block_map[7][0].is_mine = false
	block_map[7][0].solid = false ; block_map[7][1].solid = false
	block_map[6][1].is_mine = false ; block_map[7][1].is_mine = false ; block_map[8][1].is_mine = false
	block_map[6][2].is_mine = false ; block_map[7][2].is_mine = false ; block_map[8][2].is_mine = false
	block_map[6][3].is_mine = false ; block_map[7][3].is_mine = false ; block_map[8][3].is_mine = false
	
	# Calculate numbers.
	for y in range(1, height-1):
		for x in range(1, width-1):
			if block_map[x][y].is_mine:
				for dy in range(-1, 2):
					for dx in range(-1, 2):
						if dx != 0 or dy != 0:
							block_map[x+dx][y+dy].number += 1
	
	_update_tilemaps()


func _update_tilemaps() -> void:
	for y in height:
		for x in width:
			_set_block(x, y, block_map[x][y])


func _set_block(x: int, y: int, block: Block) -> void:
	debug_tilemap.set_cell(x, y, _convert_block_to_tile_num(block))


func _convert_block_to_tile_num(block: Block) -> int:
#	if block.is_border:
#		return 9
#	elif block.is_mine:
#		return 19
#	else:
#		return block.number + 10 * int(block.solid)
	if block.is_border:
		return 9
	elif block.solid:
		return 10
	else:
		return block.number + 10 * int(block.solid)


func _on_lizard_attacked(lizard: Lizard, x: int, y: int) -> void:
	if x < 0 or y < 0 or x >= width or y >= height:
		return
	
	var block := (block_map[x][y] as Block)
	
	if block.is_mine:
		print("BOOM!!")
	
	elif block.solid:
		block.solid = false
		_update_tilemaps()  # TODO: This might be a slow down.
