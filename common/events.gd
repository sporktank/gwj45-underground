extends Node


signal intro_finished()

signal lizard_attacked(lizard, x, y)  # (Lizard, int, int)
signal lizard_flagged(lizard, x, y)  # (Lizard, int, int)
signal lizard_died(lizard)  # (Lizard)
signal lizard_moved(lizard, x, y)  # (Lizard, int, int)

signal snake_died(snake)  # (Snake)
signal snake_swallowed(snake, x, y)  # (Snake, int, int)

signal loot_collected(value)  # (Enums.LOOT)
signal loot_found(value)  # (Enums.LOOT)
