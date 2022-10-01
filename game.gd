extends Node

onready var world: Node2D = $World
var world_res = load("res://World.tscn")

export (Resource) var high_score

export (Resource) var player_score

onready var player = get_tree().get_nodes_in_group("player")[0]

func _ready() -> void:
	$"%HiScoreLabel".text = "Highscore: " + str(high_score.high_score)
	print(player)
	player.connect("spell_changed", self, "_player_spell_changed")
	
func _on_RestartButton_pressed() -> void:
	#if world:
	#	world.queue_free()
	#world = world_res.instance()
	#add_child(world)
	if player_score.score > high_score.high_score:
		high_score.high_score = player_score.score
		$"%HiScoreLabel".text = "Highscore: " + str(high_score.high_score)
	player_score.lose_points(player_score.score)
	get_tree().reload_current_scene()

func _player_spell_changed(new_spell) -> void:
	$"%SpellLabelTimer".start()
