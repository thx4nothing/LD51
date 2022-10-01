extends Camera2D
class_name PlayerCamera

# shake variables
var _duration = 0.0
var _period_in_ms = 0.0
var _amplitude = 0.0
var _timer = 0.0
var _last_shook_timer = 0
var _previous_x = 0.0
var _previous_y = 0.0
var _last_offset = Vector2(0, 0)
var _shaking = false

# target
export (NodePath) var target: NodePath  # Assign the node this camera will follow.

# mouse offset
export var max_mouse_offset: float = 100
var mouse_offset: Vector2 = Vector2.ZERO

func _ready():
	randomize()
	set_as_toplevel(true)
	limit_top = $Node/TopLeft.position.y
	limit_left = $Node/TopLeft.position.x
	limit_bottom = $Node/BottomRight.position.y
	limit_right = $Node/BottomRight.position.x


func _process(delta: float) -> void:
	if get_node(target):
		global_position = get_node(target).global_position
	var vsize = get_viewport_rect().size * zoom
	var mouse_x_offset: = remap_range(get_viewport().get_mouse_position().x, 0, vsize.x, -1, 1)
	var mouse_y_offset: = remap_range(get_viewport().get_mouse_position().y, 0, vsize.y, -1, 1)
	mouse_offset = Vector2(mouse_x_offset * max_mouse_offset, mouse_y_offset * max_mouse_offset)
	var new_mouse_offset = get_offset() - mouse_offset
	#offset = mouse_offset
	#-set_offset(get_offset() - new_mouse_offset)
	if _shaking:
		# Only shake when there's shake time remaining.
		if _timer == 0:
			set_offset(Vector2())
			_shaking = false
			return
		# Only shake on certain frames.
		_last_shook_timer = _last_shook_timer + delta
		# Be mathematically correct in the face of lag; usually only happens once.
		while _last_shook_timer >= _period_in_ms:
			_last_shook_timer = _last_shook_timer - _period_in_ms
			# Lerp between [amplitude] and 0.0 intensity based on remaining shake time.
			var intensity = _amplitude * (1 - ((_duration - _timer) / _duration))
			# Noise calculation logic from http://jonny.morrill.me/blog/view/14
			var new_x = rand_range(-1.0, 1.0)
			var x_component = intensity * (_previous_x + (delta * (new_x - _previous_x)))
			var new_y = rand_range(-1.0, 1.0)
			var y_component = intensity * (_previous_y + (delta * (new_y - _previous_y)))
			_previous_x = new_x
			_previous_y = new_y
			# Track how much we've moved the offset, as opposed to other effects.
			var new_offset = Vector2(x_component, y_component)
			set_offset(get_offset() - _last_offset + new_offset)# - new_mouse_offset)
			_last_offset = new_offset
		# Reset the offset when we're done shaking.
		_timer = _timer - delta
		if _timer <= 0:
			_timer = 0
			set_offset(get_offset() - _last_offset)
	

# Kick off a new screenshake effect.
func shake(duration: float, frequency: float, amplitude: float):
	# Don't interrupt current shake duration
	if(_timer != 0):
		return
	
	# Initialize variables.
	_duration = duration
	_timer = duration
	_period_in_ms = 1.0 / frequency
	_amplitude = amplitude
	_previous_x = rand_range(-1.0, 1.0)
	_previous_y = rand_range(-1.0, 1.0)
	# Reset previous offset, if any.
	set_offset(get_offset() - _last_offset)
	_last_offset = Vector2(0, 0)
	_shaking = true

func remap_range(value, InputA, InputB, OutputA, OutputB) -> float:
	return(value - InputA) / (InputB - InputA) * (OutputB - OutputA) + OutputA
