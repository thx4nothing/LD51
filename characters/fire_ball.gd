extends RigidBody2D
class_name FireBall

export (float) var damage = 20.0
export (float) var lifetime = 2
export (float) var max_bounces: int = 1
var bounces: int = 0
var bounced: bool = false
onready var life_timer: Timer = $LifeTimer as Timer
onready var bounce_timer: Timer = $BounceTimer as Timer

func _ready() -> void:
	life_timer.start(lifetime)
	pass # Replace with function body.


func _process(delta: float) -> void:
	pass


func _on_FireBall_body_entered(collider: Node) -> void:
	print(collider)
	if collider is StaticBody2D and not bounced:
		bounces += 1
		bounced = true
		bounce_timer.start(0.2)
		if bounces > max_bounces:
			queue_free()
	elif collider is Bat:
		var bat: Bat = collider as Bat
		bat.take_damage(damage)
		bat.impact(linear_velocity / weight)
		print(bat.current_health)


func _on_LifeTimer_timeout() -> void:
	queue_free()


func _on_BounceTimer_timeout() -> void:
	bounced = false
