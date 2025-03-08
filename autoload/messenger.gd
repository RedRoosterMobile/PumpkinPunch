extends Node

# do signals here
# example
signal screenshake(strength: float)

# when game is ready to spawn pumpkins
signal game_started()
# when game ends (player die, win)
signal game_finished()

signal skeleton_killed()
signal skeleton_died()

signal pumpkin_spawned(pos: Vector3)
signal pumpkin_collision_player()
signal pumpkin_collision_hand()
# when it hits the killzone behind the player
signal pumpkin_auto_destroyed()
