extends Node3D

@onready var a_node: Node3D = $"."
@export var asp: AudioStreamPlayer
@export var smoothing_factor: float = 0.1  # 0.0 to 1.0, lower = smoother but slower response

var spectrum: AudioEffectSpectrumAnalyzerInstance
var current_magnitude: float = 0.0

func _ready() -> void:
	if asp:
		print("AudioStreamPlayer assigned: ", asp)
		# setup_spectrum_analyzer()
	else:
		print("AudioStreamPlayer not found!")

func setup_spectrum_analyzer() -> void:
	var bus_index = AudioServer.get_bus_index("MUSIC")
	if AudioServer.get_bus_effect_count(bus_index) == 0:
		var effect = AudioEffectSpectrumAnalyzer.new()
		AudioServer.add_bus_effect(bus_index, effect)
	spectrum = AudioServer.get_bus_effect_instance(bus_index, 0)

func _process(delta: float) -> void:
	if spectrum and asp.playing:
		var new_magnitude = get_audio_magnitude()
		# EMA: Blend current_magnitude with new_magnitude
		current_magnitude = lerp(current_magnitude, new_magnitude, smoothing_factor)
		a_node.scale.y = current_magnitude * 10.0
		#print("Current magnitude: ", current_magnitude)

func get_audio_magnitude() -> float:
	var low_freq = 20.0
	var high_freq = 20000.0
	var magnitude = spectrum.get_magnitude_for_frequency_range(low_freq, high_freq)
	return magnitude.length()
