extends KinematicBody2D
class_name Player

var _velocity: Vector2 = Vector2.ZERO
export var _acceleration: float = 10000 # p/s^2
export var _max_speed: float = 300 # p/s

onready var bullet_res: = preload("res://characters/FireBall.tscn") as PackedScene
onready var _shoot_point: Position2D = $Body/Wand/ShootPoint as Position2D
onready var body: Polygon2D = $Body as Polygon2D
onready var collision_body: CollisionPolygon2D = $CollisionBody as CollisionPolygon2D

export var shoot_cooldown: float = 0.5
var shoot_timer: float = 0.0


enum FireMode {
	FireBall,
	Levitate
}
onready var levitate_ray: RayCast2D = $LevitateRay as RayCast2D
onready var levitate_particles: Particles2D = $Body/Wand/LevitateParticles as Particles2D

var current_fire_mode = FireMode.Levitate

var selected_create: Crate

export (Resource) var health
signal died(score)

var score: int = 0

onready var camera: PlayerCamera = get_tree().get_nodes_in_group("camera")[0] as PlayerCamera

onready var blinkAnimPlayer: AnimationPlayer = $BlinkingPlayer as AnimationPlayer
onready var blink_timer: Timer = $BlinkTimer as Timer
onready var blood_particles: Particles2D = $BloodParticles as Particles2D

var invincible: bool = false
var dead: bool = false

func _ready() -> void:
	health.reset()
	health.connect("health_changed", self, "_health_changed")


func _process(delta: float) -> void:
	if dead: return
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
				shoot_timer = (shoot_timer + delta) if shoot_timer < shoot_cooldown else 0
		FireMode.Levitate:
			if Input.is_action_pressed("shoot"):
				levitate_particles.emitting = true
				if not selected_create and levitate_ray.is_colliding():
					var crate: = levitate_ray.get_collider() as Crate
					if crate:
						selected_create = crate
						selected_create.start_levitate(self)
			elif not Input.is_action_pressed("shoot"):
				levitate_particles.emitting = false
				if selected_create:
					selected_create.stop_levitate()
					selected_create = null

func _physics_process(delta: float) -> void:
	if dead: return
	var direction: = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down")).normalized()
	var _move_vector: Vector2 = _acceleration * direction * delta
	_velocity = move_and_slide(_move_vector)
	var _rotation: float = get_angle_to(get_global_mouse_position())
	body.rotation = _rotation
	collision_body.rotation = _rotation
	#levitate_ray.position = _shoot_point.position
	levitate_ray.rotation = _rotation - PI / 2

func _fire_bullet() -> void:
	var bullet := bullet_res.instance() as RigidBody2D
	var angle: float = get_global_mouse_position().angle_to_point(_shoot_point.global_position)
	print(angle)
	bullet.rotation = angle
	bullet.global_position = _shoot_point.global_position
	var direction: = Vector2(cos(angle), sin(angle))
	bullet.apply_central_impulse(direction * 1000)
	get_parent().add_child(bullet)
	
func hurt(amount) -> void:
	if !invincible and not dead:
		invincible = true
		camera.shake(0.2, 250, amount)
		blinkAnimPlayer.play("Start")
		blink_timer.start()
		blood_particles.emitting = true
		blood_particles.one_shot = true
		health.take_damage(amount)

func _health_changed(value) -> void:
	if value <= 0 and not dead:
		emit_signal("died", score)
		dead = true
		blood_particles.one_shot = false
		blood_particles.emitting = true
		#blood_particles.set_deferred("emitting", true)
	pass

func _on_BlinkTimer_timeout() -> void:
	blinkAnimPlayer.play("End")
	invincible = false
