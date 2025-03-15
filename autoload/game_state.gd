extends Node


# when game is ready to spawn pumpkins
var game_started:bool = false

var game_finished:bool = false

var skeleton_resurrected:bool = false
var skeleton_active:bool = false # game started??
var skeleton_died:bool = false

# raycast stuff from gloves
var is_left_hand_blocking:bool = false
var is_right_hand_blocking:bool = false
