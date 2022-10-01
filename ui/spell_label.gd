extends Label


func _process(delta: float) -> void:
	text = str(floor($"%SpellLabelTimer".time_left))
	
