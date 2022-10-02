extends Area2D
class_name Potion

export (float) var amount: float = 20.0
onready var heal_sound: AudioStreamPlayer2D = $HealSound as AudioStreamPlayer2D

func _on_Potion_body_entered(body: Node) -> void:
	if body is Player:
		body.hurt(-amount, self)
		set_deferred("monitoring", false)
		visible = false
		heal_sound.play()
		
func _on_HealSound_finished() -> void:
	queue_free()
