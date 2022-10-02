extends Node2D
class_name GameWorld

onready var ai_region: Navigation2D = $Navigation2D as Navigation2D
onready var bat_res = preload("res://characters/enemies/Bat.tscn")
onready var lev_bat_res = preload("res://objects/LevitatingEnemy.tscn")

onready var player := $"%Player" as Player
onready var camera: Camera2D = $Camera2D as Camera2D

export (NodePath) var game_over_screen
export (NodePath) var death_screen

var wave: int = 2
var enemy_counter: int = 0
var wave_threshold: float = 3

export (Resource) var player_score

var random_spawn_pos: Vector2 = Vector2.ZERO
func get_random_spawn_pos() -> Vector2:
		var vsize = camera.get_viewport_rect().size
		var camera_pos = camera.global_position
		var top_left := Vector2(camera_pos.x - vsize.x / 2, camera_pos.y - vsize.y / 2) * camera.zoom #-vtrans.get_origin() / vtrans.get_scale()
		var bottom_right := Vector2(camera_pos.x + vsize.x / 2, camera_pos.y + vsize.y / 2) * camera.zoom #vtrans.get_origin() * vtrans.get_scale()
		var top: float= top_left.y
		var bottom: float= bottom_right.y
		var left: float= top_left.x
		var right: float= bottom_right.x
		var offscreen = 64
		top = rand_range(top, top - offscreen)
		bottom = rand_range(bottom, bottom + offscreen)
		left = rand_range(left, left - offscreen)
		right = rand_range(right, right + offscreen)
		var spawn_pos := Vector2(left if randi() % 2 == 0 else right, bottom if randi() % 2 == 0 else top)
		return spawn_pos

func _ready() -> void:
	player.connect("died", self, "_player_died")
	get_node(game_over_screen).visible = false
	get_node(death_screen).visible = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug_spawn_enemy"):
		spawn_enemy()
#	if Input.is_action_just_pressed("command_fall_back"):
#		camera.shake(0.5, 1000, 2)
	var enemy_spawn_rate = wave * log(wave + 1) # per second
	enemy_spawn_rate = 0.1 * wave
	var spawn_chance = enemy_spawn_rate * delta #1 - pow(0.5, delta)
	if randf() <= spawn_chance:
		spawn_enemy()

func _player_died() -> void:
	get_node(game_over_screen).visible = true
	get_node(death_screen).visible = true
	pass

func spawn_enemy() -> void:
	var enemy := bat_res.instance() as Bat
	ai_region.add_child(enemy)
	enemy.global_position = get_random_spawn_pos()
	#enemy.max_health = randi() % 25 + 25
	#enemy.current_health = enemy.max_health
	enemy.speed = enemy.speed * rand_range(0.5, 1.0)
	enemy.connect("died", self, "_enemy_died")
		
func _enemy_died(enemy: Enemy) -> void:
	var pos = enemy.global_position
	var rot = enemy.global_rotation
	var color = enemy.body.color
	var lev_bat = lev_bat_res.instance()
	lev_bat.global_position = pos
	lev_bat.global_rotation = rot
	lev_bat.default_color = color
	ai_region.call_deferred("add_child", lev_bat)
	#lev_bat.body.color = color
	enemy.queue_free()
	
	enemy_counter += 1
	player_score.get_points(wave+1)
	if enemy_counter >= wave_threshold:
		wave += 1
		wave_threshold = wave_threshold * 1.3
		enemy_counter = 0
	