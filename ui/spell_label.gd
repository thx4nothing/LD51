extends Label


func _process(_delta: float) -> void:
	text = str(floor($"%SpellLabelTimer".time_left))
	
