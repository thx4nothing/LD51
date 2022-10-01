extends KinematicBody2D
class_name Player

var _velocity: Vector2 = Vector2.ZERO
export var _acceleration: float = 10000 # p/s^2
export var _max_speed: float = 300 # p/s

onready var bullet_res: = preload("res://characters/Bullet.tscn") as PackedScene
onready var _fire_bullet_point: Position2D = $Body/Wand/_fire_bulletPoint

func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	if Input.is_action_pressed("_fire_bullet"):
		_fire_bullet()
	
	pass

func _physics_process(delta: float) -> void:
	var direction = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down")).normalized()
	var _move_vector = _acceleration * direction * delta
	_velocity = move_and_slide(_move_vector)
	var _rotation = get_angle_to(get_global_mouse_position())
	$"Body".rotation = _rotation

func _fire_bullet() -> void:
	var bullet := bullet_res.instance() as RigidBody2D
	var angle = get_angle_to(get_global_mouse_position())
	bullet.rotation = angle
	bullet.global_position = _fire_bullet_point.global_position
	var direction = Vector2(cos(angle), sin(angle))
	bullet.apply_central_impulse(direction * 3000)
	get_parent().add_child(bullet)
	pass
