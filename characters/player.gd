extends KinematicBody2D
class_name Player

var _velocity: Vector2 = Vector2.ZERO
export var _acceleration: float = 10000 # p/s^2
export var _max_speed: float = 300 # p/s

onready var bullet_res: = preload("res://characters/Bullet.tscn") as PackedScene
onready var _shoot_point: Position2D = $Body/Wand/ShootPoint as Position2D
onready var body: Polygon2D = $Body as Polygon2D

export var shoot_cooldown: float = 0.5
var shoot_timer: float = 0.0

enum FireMode {
	FireBall,
	Levitate
}

var current_fire_mode = FireMode.FireBall

func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug_change_mode"):
		current_fire_mode += 1
		if current_fire_mode > FireMode.size() - 1:
			current_fire_mode = 0
	match current_fire_mode:
		FireMode.FireBall:
			if Input.is_action_pressed("shoot") and shoot_timer == 0.0:
				_fire_bullet()
				shoot_timer += delta
			elif shoot_timer > 0.0:
				shoot_timer = shoot_timer + delta if shoot_timer < shoot_cooldown else 0
		FireMode.Levitate:
			pass

func _physics_process(delta: float) -> void:
	var direction: = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down")).normalized()
	var _move_vector: Vector2 = _acceleration * direction * delta
	_velocity = move_and_slide(_move_vector)
	var _rotation: float = get_angle_to(get_global_mouse_position())
	body.rotation = _rotation

func _fire_bullet() -> void:
	var bullet := bullet_res.instance() as RigidBody2D
	var angle: float = get_global_mouse_position().angle_to_point(_shoot_point.global_position)
	print(angle)
	bullet.rotation = angle
	bullet.global_position = _shoot_point.global_position
	var direction: = Vector2(cos(angle), sin(angle))
	bullet.apply_central_impulse(direction * 1000)
	get_parent().add_child(bullet)
	
