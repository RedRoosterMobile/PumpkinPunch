extends Node

# when game is ready to spawn pumpkins
var game_started:bool = false
# when music stopped, mage died
var game_finished:bool = false

var skeleton_resurrected:bool = false
var skeleton_active:bool = false # game started??
var skeleton_died:bool = false

# raycast stuff from gloves
var is_left_hand_blocking_bat:bool = false
var is_right_hand_blocking_bat:bool = false

var is_left_hand_blocking_swarm:bool = false
var is_right_hand_blocking_swarm:bool = false

# punch pumpkin: 10 points
# block swarm: 30 points
# block big bat: 50 points
# miss pumpkin: -5 points

const SCORE_BLOCKED_BAT:int = 50
const SCORE_MISSED_BAT:int = -25

const SCORE_PUNCHED_PUMPKIN:int = 10
const SCORE_MISSED_PUMPKIN:int = -5

# how to block swarm:
# - have an area move towards the player unless he is blocking
# - when area overlaps player area: subtract points
# - else add points 

var score:int = 0
