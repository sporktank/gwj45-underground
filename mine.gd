extends Node2D
class_name Mine


export(int) var width := Global.MAP_WIDTH
export(int) var num_sections := 15
export(int) var section_height := 10
export(float) var min_density := 0.12
export(float) var max_density := 0.37

var height: int
var block_map := []

var treasure_collected = 0
var treasure_value_collected = 0

onready var game_tilemap := $Game
onready var floor_tilemap := $Floor
onready var loot_tilemap := $Loot
onready var walls_tilemap := $Walls
onready var roof_tilemap := $YSort/Roof
onready var flags_tilemap := $YSort/Flags
onready var rocks_tilemap := $YSort/Rocks
onready var all_tilemaps := [game_tilemap, floor_tilemap, loot_tilemap, walls_tilemap, roof_tilemap, flags_tilemap, rocks_tilemap]

onready var y_sort := $YSort
onready var collection_effects := $CollectionEffects


func _ready() -> void:
	Events.connect("lizard_attacked", self, "_on_lizard_attacked")
	Events.connect("lizard_flagged", self, "_on_lizard_flagged")
	Events.connect("lizard_moved", self, "_on_lizard_moved")
	Events.connect("snake_swallowed", self, "_on_snake_swallowed")
	
	randomize()
	generate()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.scancode == KEY_F1 and event.is_pressed() and not event.is_echo():
		for tilemap in all_tilemaps:
			tilemap.visible = not tilemap.visible


func generate() -> void:
	block_map.clear()
	
	height = section_height * num_sections
	
	for x in width:
		var column := []
		for y in height:
			var border: bool = (x == 0) or (y == 0) or (x == width-1) or y == (height-1)
			column.append(Block.new(false, border, 0, true, false))
			#column.append(Block.new(false, border, 0, false, false))
		block_map.append(column)
	
	# Place sections, and mines in those sections.
	var y_offset := 0
	for section in num_sections:
		var current_density: float = lerp(min_density, max_density, pow(float(section) / (num_sections-1), 1.5))
		
		for y in range(1 if section == 0 else 0, section_height-1 if section == num_sections-1 else section_height):
			for x in range(1, width-1):
				block_map[x][y_offset + y].is_mine = randf() < current_density
		
		y_offset += section_height
	
	# Enforce some structure.
	block_map[7][0].is_border = false
	block_map[7][0].is_mine = false
	block_map[7][0].solid = false ; block_map[7][1].solid = false ; block_map[6][1].solid = false ; block_map[8][1].solid = false
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
	
	# Add loot.
	for section in num_sections:
		var y0 := int(max(1, section * section_height))
		var y1 := int((section + 1) * section_height)
		
		var s := float(section) / float(num_sections - 1)
		
		_place_treasure_in_range(y0, y1, Enums.LOOT.TREASURE_3, lerp(-3, 3, s) + int(rand_range(-1, 1)))
		_place_treasure_in_range(y0, y1, Enums.LOOT.TREASURE_2, lerp(0, 4, s) + int(rand_range(0, 0)))
		_place_treasure_in_range(y0, y1, Enums.LOOT.TREASURE_1, lerp(4, 1, s) + int(rand_range(-1, 1)))
		#_place_treasure_in_range(y0, y1, Enums.LOOT.TREASURE_1, lerp(5, 0, s) + int(rand_range(-1, 1)))
	
	# Remove loot from very beginning.
	block_map[6][1].loot_value = 0 ; block_map[7][1].loot_value = 0 ; block_map[8][1].loot_value = 0
	block_map[6][2].loot_value = 0 ; block_map[7][2].loot_value = 0 ; block_map[8][2].loot_value = 0
	block_map[6][3].loot_value = 0 ; block_map[7][3].loot_value = 0 ; block_map[8][3].loot_value = 0
	
	_update_tilemaps()


func _place_treasure_in_range(y0: int, y1: int, value: int, amount: int) -> void:
	if amount <= 0:
		return
	
	var cands := []
	for x in width:
		for y in range(y0, y1):
			var block := (block_map[x][y] as Block)
			if not block.is_border and not block.is_mine and block.number == 0 and block.loot_value == Enums.LOOT.NOTHING:
				cands.append(block)
	
	cands.shuffle()
	for i in amount:
		if not cands:
			return
		
		var block := (cands.pop_front() as Block)
		block.loot_value = value


func _update_tilemaps() -> void:
	for tilemap in all_tilemaps:
		tilemap.clear()
	
	floor_tilemap.set_cell(7, -1, 0)
	
	for y in height:
		for x in width:
			_set_block(x, y, block_map[x][y])
	
	rocks_tilemap.update_bitmask_region()


func _set_block(x: int, y: int, block: Block) -> void:
	game_tilemap.set_cell(x, y, _block_to_game_tile(block))
	floor_tilemap.set_cell(x, y, _block_to_floor_tile(block))
	walls_tilemap.set_cell(x, y, 0 if block.is_border else -1)
	loot_tilemap.set_cell(x, y, block.loot_value - 1)
	roof_tilemap.set_cell(x, y, 0 if block.is_border else -1)
	rocks_tilemap.set_cell(x, y, 0 if not block.is_border and block.solid else -1)
	flags_tilemap.set_cell(x, y, 1 if block.is_mine and not block.solid else 0 if block.flagged else -1)


func _block_to_floor_tile(block: Block) -> int:
	if block.is_border or block.is_mine:
		return 0
	else:
		return block.number


func _block_to_game_tile(block: Block) -> int:
	if block.is_border:
		return 9
	elif block.flagged or (block.is_mine and not block.solid):
		return 0
	elif block.is_mine:
		return 19
	else:
		return block.number + 10 * int(block.solid)
#	if block.is_border:
#		return 9
#	elif block.solid:
#		return 10
#	else:
#		return block.number + 10 * int(block.solid)


func _on_lizard_attacked(lizard: Lizard, x: int, y: int, recurse := true) -> void:
	if x < 0 or y < 0 or x >= width or y >= height:
		return
	
	var block := (block_map[x][y] as Block)
	if block.flagged or block.is_border:
		return
	
	if block.is_mine:
		block.solid = false
		_add_rock_crumble(x, y)
		_update_tilemaps()
		lizard.die()
		Events.emit_signal("lizard_died", lizard)
	
	elif block.solid:
		block.solid = false
		_add_rock_crumble(x, y)
		if block.number == 0:
			if lizard.automine_zero_blocks:
				_cascade_zero_blocks(x, y, lizard.automine_zero_block_neighbours)
		
		_update_tilemaps()
	
	elif recurse:
		if _count_neighbour_flags(x, y) == block.number:
			for dy in range(-1, 2):
				for dx in range(-1, 2):
					if dx == 0 and dy == 0:
						continue
					
					_on_lizard_attacked(lizard, x+dx, y+dy, false)


func _count_neighbour_flags(x: int, y: int) -> int:
	var count := 0
	
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			if dx == 0 and dy == 0:
				continue
			
			count += int(block_map[x+dx][y+dy].flagged)
	
	return count


func _cascade_zero_blocks(start_x: int, start_y: int, mine_all_numbers: bool) -> void:
	var xs := [start_x]
	var ys := [start_y]
	
	while xs:
		var x := int(xs.pop_front())
		var y := int(ys.pop_front())
		
		#for d in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]:
		#	var dx := int(d.x)
		#	var dy := int(d.y)
		for dy in range(-1, 2):
			for dx in range(-1, 2):
				if dx == 0 and dy == 0:
					continue
				
				if x+dx < 0 or y+dy < 0 or x+dx >= width or y+dy >= height:
					continue
				
				var block := (block_map[x+dx][y+dy] as Block)
				if not block.is_border and block.solid and not block.flagged:
					if block.number == 0 or mine_all_numbers:
						block.solid = false
						_add_rock_crumble(x+dx, y+dy)
					if block.number == 0:
						xs.append(x+dx)
						ys.append(y+dy)


func _add_rock_crumble(x: int, y: int) -> void:
	var rock_crumble := Scenes.ROCK_CRUMBLE.instance() as RockCrumble
	y_sort.add_child(rock_crumble)
	rock_crumble.global_position = Vector2(x, y+1) * Global.BLOCK_SIZE


func _on_lizard_flagged(lizard: Lizard, x: int, y: int) -> void:
	if x < 0 or y < 0 or x >= width or y >= height:
		return
	
	var block := (block_map[x][y] as Block)
	if block.is_border or not block.solid:
		return
	
	block.flagged = not block.flagged
	_update_tilemaps()


func _on_lizard_moved(lizard: Lizard, x: int, y: int) -> void:
	if x < 0 or y < 0 or x >= width or y >= height:
		return
	
	var block := (block_map[x][y] as Block)
	if not block.is_border and not block.solid and not block.flagged and block.loot_value > 0:
		Events.emit_signal("loot_found", block.loot_value)


func _on_snake_swallowed(snake: Snake, x: int, y: int) -> void:
	if x < 0 or y < 0 or x >= width or y >= height:
		return
	
	var block := (block_map[x][y] as Block)
	if not block.is_border and not block.solid and not block.flagged:
		
		if block.number > 0:
			snake.grow(block.number)
			block.number = 0
			_update_tilemaps()
		
		elif block.loot_value > 0:
			Events.emit_signal("loot_collected", block.loot_value)
			treasure_collected += 1
			treasure_value_collected += Enums.TREASURE_VALUE[block.loot_value]
			_spawn_loot_collected_effect(block.loot_value, x, y)
			block.loot_value = Enums.LOOT.NOTHING
			_update_tilemaps()


func _spawn_loot_collected_effect(value: int, x: int, y: int) -> void:
	var e := Scenes.LOOT_EFFECT.instance() as LootEffect
	e.text = "$" + str(Enums.TREASURE_VALUE[value])
	e.velocity = -64.0
	collection_effects.add_child(e)
	e.global_position = Vector2(x + 0.5, y + 0.5) * Global.BLOCK_SIZE


func get_correct_mine_count() -> int:
	var count := 0
	
	for y in range(1, height-1):
		for x in range(1, width-1):
			var block := (block_map[x][y] as Block)
			if block.is_mine and block.flagged:
				count += 1
	
	return count


func get_depth_mined() -> int:
	var depth := 1
	
	for y in range(1, height-1):
		for x in range(1, width-1):
			var block := (block_map[x][y] as Block)
			if not block.solid:
				depth = y+1
	
	return depth
