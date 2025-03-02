extends Node

# Code adapted from KidsCanCode
# example
# Audio.play("audio/splat.ogg", true, global_transform)
var num_audio_players = 12
var bus = "SFX"

var available: Array[AudioStreamPlayer3D] = []  # The available players.
	
class QueueEntry:
	var transform: Transform3D
	var pitch_mod: bool
	var file: String

var queue: Array[QueueEntry] = []  # The queue of sounds to play.

func _ready():
	for i in num_audio_players:
		var player = AudioStreamPlayer3D.new()
		add_child(player)

		available.append(player)

		player.volume_db = -5
		player.finished.connect(_on_stream_finished.bind(player))
		player.bus = bus

func _on_stream_finished(stream: AudioStreamPlayer3D):
	available.append(stream)

func play(sound_path:String, pitch_mod:bool = false, transform: Transform3D = Transform3D.IDENTITY ):  # Path (or multiple, separated by commas)
	var sounds = sound_path.split(",")
	var qe: QueueEntry = QueueEntry.new()
	qe.file = "res://" + sounds[randi() % sounds.size()].strip_edges()
	qe.pitch_mod = pitch_mod
	qe.transform = transform
	queue.append(qe)

func _process(_delta:float):
	if not queue.is_empty() and not available.is_empty():
		var qe:QueueEntry = queue.pop_front()
		var player = available.pop_front()
		player.stream = load(qe.file)
		player.play()
		if qe.pitch_mod:
			player.pitch_scale = randf_range(0.9, 1.1)
		else:
			player.pitch_scale = 0.0
		
		if qe.transform == Transform3D.IDENTITY:
			# If the transform is the default identity, place the sound at (0, 0, 0)
			player.transform.origin = Vector3.ZERO
		else:
			player.transform = qe.transform

		
