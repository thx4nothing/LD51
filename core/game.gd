extends Node

export (Resource) var high_score
export (Resource) var player_score

onready var player = get_tree().get_nodes_in_group("player")[0]

func _ready() -> void:
	$"%HiScoreLabel".text = "Highscore: " + str(high_score.high_score)
	print(player)
	player.connect("spell_changed", self, "_player_spell_changed")
	
func _on_RestartButton_pressed() -> void:
	if player_score.score > high_score.high_score:
		high_score.high_score = player_score.score
		$"%HiScoreLabel".text = "Highscore: " + str(high_score.high_score)
	player_score.lose_points(player_score.score)
	if not get_tree().reload_current_scene() == OK:
		get_tree().quit()

func _input(event: InputEvent) -> void:
	if event and event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func _player_spell_changed(_new_spell) -> void:
	$"%SpellLabelTimer".start()