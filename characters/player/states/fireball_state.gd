extends State

onready var fireball_res: = preload("res://characters/player/FireBall.tscn") as PackedScene

export var shoot_cooldown: float = 0.5
var shoot_timer: float = 0.0

func enter(_player: Player) -> void:
	shoot_timer = 0.0

func exit(_player: Player) -> void:
	pass
	
func tick(player: Player, delta: float) -> void:
	if Input.is_action_pressed("shoot") and shoot_timer == 0.0:
		_shoot_fireball(player)
		shoot_timer += delta
	elif shoot_timer > 0.0:
		shoot_timer = (shoot_timer + delta) if shoot_timer < shoot_cooldown else 0

func physics_tick(_player: Player, _delta: float) -> void:
	pass

func _shoot_fireball(player: Player) -> void:
	var fireball := fireball_res.instance() as FireBall
	var angle: float = player.get_global_mouse_position().angle_to_point(player._shoot_point.global_position)
	fireball.rotation = angle
	fireball.global_position = player._shoot_point.global_position
	var direction: = Vector2(cos(angle), sin(angle))
	fireball.apply_central_impulse(direction * 1000)
	player.get_parent().add_child(fireball)
