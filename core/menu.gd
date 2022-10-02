extends HBoxContainer




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), -20)


func _on_VolumeSlider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), $VBoxContainer/HBoxContainer/VolumeSlider.value)


func _on_QuitButton_pressed() -> void:
	get_tree().quit()


func _on_StartButton_pressed() -> void:
	get_tree().change_scene("res://core/Game.tscn")

func _on_VolumeTestButton_pressed() -> void:
	($TestAudio as AudioStreamPlayer).play()
