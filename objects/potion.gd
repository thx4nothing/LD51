extends Area2D
class_name Potion

export (float) var amount: float = 20.0

func _on_Potion_body_entered(body: Node) -> void:
	if body is Player:
		body.hurt(-amount, self)
		queue_free()
