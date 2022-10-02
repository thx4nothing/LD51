extends State

var levitating_object: LevitatingObject

func enter(player: Player) -> void:
	levitating_object = null
	pass

func exit(player: Player) -> void:
	levitating_object = null
	player.levitate_particles.emitting = false
	pass
	
func tick(player: Player, _delta: float) -> void:
	if Input.is_action_pressed("shoot"):
		player.levitate_particles.emitting = true
		if not levitating_object and player.levitate_ray.is_colliding():
			levitating_object = player.levitate_ray.get_collider() as LevitatingObject
			if levitating_object:
				levitating_object.start_levitate(player)
	else:
		if levitating_object:
			levitating_object.stop_levitate()
			levitating_object = null
			player.levitate_particles.emitting = false

func physics_tick(_player: Player, _delta: float) -> void:
	pass
