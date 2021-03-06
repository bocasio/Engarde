extends Node

const TRANSITION = Tween.TRANS_SINE
const EASE = Tween.EASE_IN_OUT

var amplitude = 0
var priority = 0

onready var camera = get_parent()


func start(duration = 0.2, frequency = 15, amplitude = 16, priority = 0):
	if priority >= self.priority:
		self.priority = priority
		self.amplitude = amplitude
	
		$Duration.wait_time = duration
		$Frequency.wait_time = 1 / float(frequency)
		$Duration.start()
		$Frequency.start()
		
		_new_shake()


func _new_shake():
	var random_vector = Vector2.ZERO
	
	random_vector.x = rand_range(-amplitude, amplitude)
	random_vector.y = rand_range(-amplitude, amplitude)
	
	$ShakeTween.interpolate_property(camera, "offset", camera.offset, random_vector, $Frequency.wait_time, TRANSITION, EASE)
	$ShakeTween.start()


func _reset():
	$ShakeTween.interpolate_property(camera, "offset", camera.offset, Vector2.ZERO, $Frequency.wait_time, TRANSITION, EASE)
	$ShakeTween.start()
	
	priority = 0


func _on_Frequency_timeout():
	_new_shake()


func _on_Duration_timeout():
	_reset()
	$Frequency.stop()
