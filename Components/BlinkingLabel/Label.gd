extends Label

var blink_timeout = 0
var fadeout_duration = 0

func _ready():
	set_process(true)

func _process(delta):
	if fadeout_duration != null:
		if fadeout_duration > 0:
			fadeout_duration -= delta
		else:
			fadeout_duration = null
			var color = self.modulate
			color.a = 1
			self.modulate = color
			blink_timeout = rand_range(0.01, 0.8)
	else:
		if blink_timeout <= 0:
			var color = self.modulate
			color.a = 0.3
			self.modulate = color
			fadeout_duration = rand_range(0.01, 0.1)		
		else:
			blink_timeout -= delta
	