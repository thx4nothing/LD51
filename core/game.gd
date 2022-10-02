extends Node

export (Resource) var high_score
export (Resource) var player_score

onready var player = get_tree().get_nodes_in_group("player")[0]

onready var fireball_info_tex: Texture = preload("res://assets/fireball_info.png") as Texture
onready var levitate_info_tex: Texture = preload("res://assets/levitate_info.png") as Texture
onready var shrink_info_tex: Texture = preload("res://assets/shrink_info.png") as Texture
onready var gradient: Gradient = ($"%SpellInfo".texture as GradientTexture2D).gradient as Gradient

func _ready() -> void:
	$"%HiScoreLabel".text = "Highscore: " + str(high_score.high_score)
	player.connect("spell_changed", self, "_player_spell_changed")
	_player_spell_changed(player._current_spell, player._next_spell)
	
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

func _player_spell_changed(_current_spell, _next_spell) -> void:
	#($"%SpellInfo".texture as GradientTexture2D).gradient.colors[0] = Color.blueviolet
	var tween = $"%SpellInfoTween"
	var old_color
	var new_color
	match _current_spell.name:
		"FireBall":
			old_color = Color.crimson
		"Levitate":			
			old_color = Color.gray
			#$"%SpellInfo".texture = levitate_info_tex
		"Shrink":
			old_color = Color.darkblue
			#$"%SpellInfo".texture = shrink_info_tex
	match _next_spell.name:
		"FireBall":
			new_color = Color.crimson
			#$"%SpellInfo".texture = fireball_info_tex
		"Levitate":
			new_color = Color.gray
			#$"%SpellInfo".texture = levitate_info_tex
		"Shrink":
			new_color = Color.darkblue
			#$"%SpellInfo".texture = shrink_info_tex
	
	print(old_color)
	print(new_color)
	print(gradient.colors[0])
	tween.interpolate_property(gradient, "colors", old_color, new_color, 10, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	#gradient.colors[0] = new_color
	$"%SpellLabelTimer".start()
