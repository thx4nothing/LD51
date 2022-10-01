extends Resource
class_name PlayerScore

export var score: float = 0

signal score_changed
	
func lose_points(amount):
	score -= amount
	emit_signal("score_changed", score)
	
func get_points(amount):
	score += amount
	emit_signal("score_changed", score)
	
