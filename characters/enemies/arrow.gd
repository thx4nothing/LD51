extends RigidBody2D
class_name Arrow

export (float) var damage: float = 10

func _on_LifeTimer_timeout() -> void:
	queue_free()


func _on_Arrow_body_entered(body: Node) -> void:
	var player = body as Player
	if player:
		player.hurt(damage, self)
		queue_free()
