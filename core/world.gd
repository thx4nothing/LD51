extends Node2D
class_name GameWorld

onready var ai_region: Navigation2D = $Navigation2D as Navigation2D
onready var bat_res = preload("res://characters/enemies/Bat.tscn") as PackedScene
onready var skel_res = preload("res://characters/enemies/Skeleton.tscn") as PackedScene
onready var potion_res = preload("res://objects/Potion.tscn") as PackedScene
onready var crate_res = preload("res://objects/Crate.tscn") as PackedScene
onready var spike_res = preload("res://objects/SpikeWall.tscn") as PackedScene
onready var lev_bat_res = preload("res://objects/LevitatingBat.tscn") as PackedScene
onready var lev_skel_res = preload("res://objects/LevitatingSkeleton.tscn") as PackedScene
onready var enemy_res: Array = [bat_res, skel_res] as Array

onready var enemy_costs: Dictionary = {bat_res: 1, skel_res: 2}
onready var item_costs: Dictionary = {potion_res: 1, crate_res: 2} #, spike_res: 3}


onready var player := $"%Player" as Player
onready var camera: Camera2D = $Camera2D as Camera2D

export (NodePath) var game_over_screen
export (NodePath) var death_screen

# waves
var wave: int = 0
var wave_budget: int = 3
var items_budget: int = 3
var enemies: Array = []
var difficulty: float = 0.1
onready var wave_timer: Timer = $WaveTimer as Timer
onready var spawn_points: Node = $SpawnPoints as Node

export (Resource) var player_score

var random_spawn_pos: Vector2 = Vector2.ZERO
func get_random_spawn_pos() -> Vector2:
	var spawn_pos: Vector2 = spawn_points.get_children()[randi() % spawn_points.get_children().size()].global_position
	return spawn_pos
#		var vsize = camera.get_viewport_rect().size
#		var camera_pos = camera.global_position
#		var top_left := Vector2(camera_pos.x - vsize.x / 2, camera_pos.y - vsize.y / 2) * camera.zoom #-vtrans.get_origin() / vtrans.get_scale()
#		var bottom_right := Vector2(camera_pos.x + vsize.x / 2, camera_pos.y + vsize.y / 2) * camera.zoom #vtrans.get_origin() * vtrans.get_scale()
#		var top: float= top_left.y
#		var bottom: float= bottom_right.y
#		var left: float= top_left.x
#		var right: float= bottom_right.x
#		var offscreen = 64
#		top = rand_range(top, top - offscreen)
#		bottom = rand_range(bottom, bottom + offscreen)
#		left = rand_range(left, left - offscreen)
#		right = rand_range(right, right + offscreen)
#		var spawn_pos := Vector2(left if randi() % 2 == 0 else right, bottom if randi() % 2 == 0 else top)
#		return spawn_pos

func _ready() -> void:
	player.connect("died", self, "_player_died")
	get_node(game_over_screen).visible = false
	get_node(death_screen).visible = false

func _player_died() -> void:
	get_node(game_over_screen).visible = true
	get_node(death_screen).visible = true

func next_wave() -> void:
	wave += 1
	wave_budget = wave * 4
	items_budget = wave * 3
	difficulty += 0.1
	while wave_budget > 0:
		var random = enemy_costs.keys()[randi() % enemy_costs.keys().size()]
		if enemy_costs[random] <= wave_budget:
			wave_budget -= enemy_costs[random]
			spawn_object(random)
	while items_budget > 0:
		var random = item_costs.keys()[randi() % item_costs.keys().size()]
		if item_costs[random] <= items_budget:
			items_budget -= item_costs[random]
			spawn_object(random)
	print(enemies)

func spawn_object(enemyr: PackedScene) -> void:
	var enemy = enemyr.instance()
	ai_region.add_child(enemy)
	if enemy is Enemy:
		enemies.append(enemy)
		enemy.global_position = get_random_spawn_pos()
		enemy.max_health += (-10 + (randi() % 50)) * difficulty
		enemy.current_health = enemy.max_health
		enemy.speed *= rand_range(0.5 + difficulty, 0.8 + difficulty)
		enemy.connect("died", self, "_enemy_died")
		
func _enemy_died(enemy: Enemy) -> void:
	_spawn_levitating_enemy(enemy)
	if enemy in enemies:
		enemies.erase(enemy)
		enemy.queue_free()
	player_score.get_points(wave / difficulty)
	if enemies.empty():
		wave_timer.start(3)

func _spawn_levitating_enemy(enemy: Enemy) -> void:
	var lev_obj
	if enemy is Bat:
		lev_obj = lev_bat_res.instance()
	elif enemy is SkeletonE:
		lev_obj = lev_skel_res.instance()
	if lev_obj:
		var pos = enemy.global_position
		var rot = enemy.global_rotation
		var color = enemy.body.color
		var e_scale = enemy.scale
		lev_obj.global_position = pos
		lev_obj.global_rotation = rot
		lev_obj.default_scale = e_scale
		lev_obj.default_color = color
		ai_region.call_deferred("add_child", lev_obj)


func _on_WaveTimer_timeout() -> void:
	next_wave()
	wave_timer.autostart = false
