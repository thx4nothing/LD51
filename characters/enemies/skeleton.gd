extends Enemy
class_name SkeletonE

onready var shoot_timer: Timer = $ShootTimer

onready var arrow_res: PackedScene = preload("res://characters/enemies/Arrow.tscn") as PackedScene

export (float) var shooting_range: float = 200.0
export (float) var shoot_cooldown: float = 1.0

func _ready() -> void:
	navigation_agent_2d.target_desired_distance = shooting_range

func _on_ShootingArea_body_entered(body: Node) -> void:
	if body is Player:
		shoot_timer.start(shoot_cooldown)

func _on_ShootingArea_body_exited(_body: Node) -> void:
	shoot_timer.stop()

func _on_ShootTimer_timeout() -> void:
	if not player: return
	var arrow := arrow_res.instance() as Arrow
	var angle: float = player.global_position.angle_to_point(global_position)
	arrow.rotation = angle
	arrow.global_position = global_position
	var direction: = Vector2(cos(angle), sin(angle))
	arrow.apply_central_impulse(direction * 1000)
	get_parent().add_child(arrow)
