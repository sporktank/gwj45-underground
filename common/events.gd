extends Node


signal lizard_attacked(lizard, x, y)  # (Lizard, int, int)
signal lizard_flagged(lizard, x, y)  # (Lizard, int, int)
signal lizard_died(lizard)  # (Lizard)

signal snake_died(snake)  # (Snake)
signal snake_swallowed(snake, x, y)  # (Snake, int, int)
signal testtest
