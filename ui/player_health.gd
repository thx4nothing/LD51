extends ProgressBar

export (Resource) var player_health

func _ready():
	if player_health:
		player_health.connect("health_changed", self, "_on_player_health_changed")
		value = player_health.max_health
		print(player_health.max_health)

func _on_player_health_changed(valuee):
	value = float(valuee) / player_health.max_health * 100
