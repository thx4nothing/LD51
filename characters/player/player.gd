extends KinematicBody2D
class_name Player

export (Resource) var score

# States
onready var FireBallState = $States/FireBall
onready var LevitateState = $States/Levitate
onready var ShrinkState = $States/Shrink

var _current_spell = null setget set_state
var _next_spell
func set_state(value):
		if value == _current_spell: return
		if _current_spell: _current_spell.exit(self)
		if value:
			_current_spell = value
			_current_spell.enter(self)

# movement
var _velocity: Vector2 = Vector2.ZERO
export var speed: float = 300 # p/s
export var friction = 0.18
var _knockback: Vector2 = Vector2.ZERO
export var dodge_speed: float = 25000
export var dodge_cooldown: float = 3.0
var dodged: bool = false

# nodes
onready var _shoot_point: Position2D = $Body/Wand/ShootPoint as Position2D
onready var body: Polygon2D = $Body as Polygon2D
onready var collision_body: CollisionPolygon2D = $CollisionBody as CollisionPolygon2D
onready var levitate_ray: RayCast2D = $LevitateRay as RayCast2D
onready var levitate_particles: Particles2D = $Body/Wand/LevitateParticles as Particles2D
onready var camera: PlayerCamera = get_tree().get_nodes_in_group("camera")[0] as PlayerCamera
onready var blinkAnimPlayer: AnimationPlayer = $BlinkingPlayer as AnimationPlayer
onready var blink_timer: Timer = $BlinkTimer as Timer
onready var blood_particles: Particles2D = $BloodParticles as Particles2D
onready var shrinking_particles: Particles2D = $Body/Wand/ShrinkingParticles as Particles2D
onready var shrink_ray: RayCast2D = $ShrinkRay as RayCast2D
onready var dodge_timer: Timer = $DodgeTimer as Timer

# spell changer
onready var spell_timer: Timer = $SpellTimer as Timer
signal spell_changed(_current_spell, _next_spell)

# health _current_spell
export (Resource) var health
signal died
var invincible: bool = false
var dead: bool = false

func _ready() -> void:
	randomize()
	health.reset()
	health.connect("health_changed", self, "_health_changed")
	_choose_random_spell()


func _process(delta: float) -> void:
	if dead: return
	_current_spell.tick(self, delta)
	score.get_points(delta)
	if Input.is_action_just_pressed("debug_change_mode"):
		_choose_random_spell()

func _physics_process(delta: float) -> void:
	if dead: return
	_current_spell.physics_tick(self, delta)
	var direction: = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down"))
	if direction.length() > 1.0:
		direction = direction.normalized()
	var target_velocity = direction * speed
	
	if direction and Input.is_action_just_pressed("dodge") and not _knockback and not dodged:
		dodged = true
		dodge_timer.start(dodge_cooldown)
		target_velocity += direction * dodge_speed
	elif _knockback:
		target_velocity += _knockback
		_knockback.x = move_toward(_knockback.x, 0, 100)
		_knockback.y = move_toward(_knockback.y, 0, 100)
	
	_velocity += (target_velocity - _velocity) * friction
	_velocity = move_and_slide(_velocity)
	var _rotation: float = get_angle_to(get_global_mouse_position())
	body.rotation = _rotation
	collision_body.rotation = _rotation
	levitate_ray.rotation = _rotation - PI / 2
	shrink_ray.rotation = _rotation - PI / 2

func hurt(amount, source) -> void:
	if !invincible and not dead:
		invincible = true
		camera.shake(0.2, 250, amount)
		blinkAnimPlayer.play("Start")
		blink_timer.start()
		blood_particles.one_shot = true
		blood_particles.emitting = true
		health.take_damage(amount)
		var normals = source.global_position.direction_to(global_position)
		_knockback = normals * 1000

func _health_changed(value) -> void:
	if value <= 0 and not dead:
		emit_signal("died")
		dead = true
		blood_particles.one_shot = false
		blood_particles.emitting = true

func _on_BlinkTimer_timeout() -> void:
	blinkAnimPlayer.play("End")
	invincible = false

func _on_SpellTimer_timeout() -> void:
	_choose_random_spell()

func _choose_random_spell() -> void:
	if not _next_spell:
		_next_spell = $"%States".get_children()[randi() % $"%States".get_children().size()]
	self._current_spell = _next_spell
	var spell_count = $"%States".get_children().size()
	while _next_spell == _current_spell:
		_next_spell = $"%States".get_children()[randi() % spell_count]
	emit_signal("spell_changed", _current_spell, _next_spell)


func _on_DodgeTimer_timeout() -> void:
	dodged = false
