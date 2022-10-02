extends State

var levitating_object: LevitatingObject
onready var levitate_sound: AudioStreamPlayer2D = $"../../LevitateSound" as AudioStreamPlayer2D

func enter(player: Player) -> void:
	deactivate(player)

func exit(player: Player) -> void:
	deactivate(player)
	
func tick(player: Player, _delta: float) -> void:
	if Input.is_action_pressed("shoot"):
		player.levitate_particles.emitting = true
		if not levitating_object and player.levitate_ray.is_colliding():
			levitating_object = player.levitate_ray.get_collider() as LevitatingObject
			if levitating_object:
				levitating_object.start_levitate(player)
	else:
		deactivate(player)

func deactivate(player: Player) -> void:
	player.levitate_particles.emitting = false
	if levitating_object:
		levitating_object.stop_levitate()
		levitating_object = null

func physics_tick(_player: Player, _delta: float) -> void:
	pass
