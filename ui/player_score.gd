extends Label

export (Resource) var player_score

func _ready():
	if player_score:
		player_score.connect("score_changed", self, "_on_player_score_changed")
		text = "Score: " + str(player_score.score)
		print(player_score.score)

func _on_player_score_changed(score):
	text = "Score: " + str(score)
