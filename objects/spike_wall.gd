extends RigidBody2D

export (float) var damage = 200.0

func _on_SpikesArea_body_entered(body: Node) -> void:
	var enemy := body as Enemy
	if enemy:
		enemy.take_damage(damage)
	var player := body as Player
	if player:
		player.hurt(damage / 10, self)
