extends RigidBody2D
class_name FireBall

# projectile dmg
export (float) var _damage: float = 20.0

# _bounces
export (float) var _max_bounces: int = 1
var _bounces: int = 0
var _bounced: bool = false
onready var _bounce_timer: Timer = $BounceTimer as Timer

# life timer
export (float) var _lifetime = 2.0
onready var _life_timer: Timer = $LifeTimer as Timer

# aoe calculations
onready var _aoe_radius: Area2D = $AoERadius as Area2D

# player _camera
onready var _camera: PlayerCamera = get_tree().get_nodes_in_group("camera")[0] as PlayerCamera

onready var explosion_particles: Particles2D = $ExplosionParticles as Particles2D

# sound
onready var explosion_sound: AudioStreamPlayer2D = $ExplosionSound as AudioStreamPlayer2D


func _ready() -> void:
	_life_timer.start(_lifetime)

func _on_FireBall_body_entered(collider: Node) -> void:
	if collider is StaticBody2D and not _bounced:
		_bounces += 1
		_bounced = true
		_bounce_timer.start(0.2)
		if _bounces > _max_bounces:
			queue_free()
	elif collider is Enemy:
		for node in _aoe_radius.get_overlapping_bodies():
			var enemy: Enemy = node as Enemy
			if enemy and enemy.current_health > 0:
				enemy.take_damage(_damage)
				enemy.impact(linear_velocity)
				_camera.shake(0.2, 250, linear_velocity.length() / weight)
		explosion_particles.emitting = true
		explosion_sound.play()
	elif collider is Crate:
		(collider as Crate).hit(self)

func _on_LifeTimer_timeout() -> void:
	queue_free()

func _on_BounceTimer_timeout() -> void:
	_bounced = false


func _on_ExplosionSound_finished() -> void:
	_life_timer.start(0.1)
	
