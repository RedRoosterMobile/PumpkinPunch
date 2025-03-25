extends Node


# when game is ready to spawn pumpkins
signal game_started()
# when game ends (player die, win)
signal game_finished()

signal skeleton_killed()
signal skeleton_died()

signal spawn_big_bat()

# on swarm spawn:
# after a timer (when the bats fly deep enough)
# add blocking area
# listen if we are blocking over time
# when blocked "enough"
# success
# otherwise fail
# show feedback when blocking
signal spawn_bat_swarm()
signal stop_bat_swarm()

signal pumpkin_spawned(pos: Vector3)
signal pumpkin_collision_player()
signal pumpkin_collision_hand()
# when it hits the killzone behind the player
signal pumpkin_auto_destroyed()

signal player_hit(area: Area3D)

signal is_blocking_bat()

signal add_score(score:int)

signal spawn_decal_requested(position: Vector3)
