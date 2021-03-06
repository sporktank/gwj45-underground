extends Node


enum GAME_STATE {
	MINESWEEPER = 1,
	SNAKE = 2,
	CUTSCENE = 3,
}

enum LIZARD_STATE {
	INACTIVE = -1,
	IDLE = 0,
	WALK = 1,
	ATTACK = 2,
	FLAG = 3,
	DEAD = 4,
}

enum SNAKE_STATE {
	INACTIVE = -1,
	STILL = 0,
	MOVING = 1,
	DEAD = 2,
	WON = 3,
}

enum LOOT {
	NOTHING = 0,
	TREASURE_1 = 1,
	TREASURE_2 = 2,
	TREASURE_3 = 3,
	TREASURE_4 = 4,
}

const TREASURE_VALUE := [
	0,
	100,
	200,
	1000,
	0,
]
