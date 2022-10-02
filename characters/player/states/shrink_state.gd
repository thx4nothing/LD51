extends State

var targeted_enemy: Enemy

func enter(player: Player) -> void:
	deactivate(player)

func exit(player: Player) -> void:
	deactivate(player)
	
func tick(player: Player, _delta: float) -> void:
	if Input.is_action_pressed("shoot"):
		player.shrinking_particles.emitting = true
		if player.shrink_ray.is_colliding():
			targeted_enemy = player.shrink_ray.get_collider() as Enemy
			if targeted_enemy:
				targeted_enemy.start_shrinking()
	else:
		deactivate(player)
		
func deactivate(player: Player) -> void:
	player.shrinking_particles.emitting = false
	if targeted_enemy and is_instance_valid(targeted_enemy):
		targeted_enemy.stop_shrinking()
		targeted_enemy = null

func physics_tick(_player: Player, _delta: float) -> void:
	pass
