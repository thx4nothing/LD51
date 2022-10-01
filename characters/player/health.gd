extends Resource
class_name PlayerHealth

export var max_health: float = 100.0
var current_health: float = max_health

signal health_changed

func reset():
	current_health = max_health
	
func take_damage(amount):
	current_health = max(0, current_health - amount)
	emit_signal("health_changed", current_health)
	
func heal(amount):
	current_health = min(max_health, current_health + amount)
	emit_signal("health_changed", current_health)
	
