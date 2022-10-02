extends Node

export (Resource) var high_score
export (Resource) var player_score

export (Color) var gradient_color: Color

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
		"Shrink":
			old_color = Color.darkblue
	match _next_spell.name:
		"FireBall":
			new_color = Color.crimson
		"Levitate":
			new_color = Color.gray
		"Shrink":
			new_color = Color.darkblue
	gradient.colors[0] = old_color
	if not gradient_color:
		gradient_color = old_color
	tween.interpolate_property(self, "gradient_color", old_color, new_color.lightened(0.5), 10, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	$"%SpellLabelTimer".start()


func _on_SpellInfoTween_tween_step(object: Object, key: NodePath, elapsed: float, value: Object) -> void:
	gradient.colors[0] = gradient_color
