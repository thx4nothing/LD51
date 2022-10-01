extends Camera2D

export var decay: = 0.8  # How quickly the shaking stops [0, 1].
export var max_offset: = Vector2(100, 75)  # Maximum hor/ver shake in pixels.
export var max_roll: float = 0.1  # Maximum rotation in radians (use sparingly).
export (NodePath) var target: NodePath  # Assign the node this camera will follow.
export var mouse_offset: float = 100

var trauma: = 0.0  # Current shake strength.
var trauma_power: int = 2  # Trauma exponent. Use [2, 3].

onready var noise: = OpenSimplexNoise.new()
var noise_y: float = 0

func _ready():
	randomize()
	noise.seed = randi()
	noise.period = 4
	noise.octaves = 2
	set_as_toplevel(true)
	limit_top = $Node/TopLeft.position.y
	limit_left = $Node/TopLeft.position.x
	limit_bottom = $Node/BottomRight.position.y
	limit_right = $Node/BottomRight.position.x

func add_trauma(amount: float) -> void:
	trauma = min(trauma + amount, 1.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if get_node(target):
		global_position = get_node(target).global_position
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()
	var vsize = get_viewport_rect().size * zoom
	var mouse_x_offset: = remap_range(get_viewport().get_mouse_position().x, 0, vsize.x, -1, 1)
	var mouse_y_offset: = remap_range(get_viewport().get_mouse_position().y, 0, vsize.y, -1, 1)
	offset = Vector2(mouse_x_offset * mouse_offset, mouse_y_offset * mouse_offset)
		
func shake():
	var amount = pow(trauma, trauma_power)
	noise_y += 1
	rotation = max_roll * amount * noise.get_noise_2d(noise.seed, noise_y)
	offset.x = max_offset.x * amount * noise.get_noise_2d(noise.seed*2, noise_y)
	offset.y = max_offset.y * amount * noise.get_noise_2d(noise.seed*3, noise_y)


func remap_range(value, InputA, InputB, OutputA, OutputB) -> float:
	return(value - InputA) / (InputB - InputA) * (OutputB - OutputA) + OutputA
