extends KinematicBody2D
class_name Bat

export (float) var speed := 200.0

onready var player = get_tree().get_nodes_in_group("player")[0]
onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D as NavigationAgent2D

var velocity: Vector2 = Vector2.ZERO

export (int, 0, 200) var push = 100
var push_factor: float = 1

signal died

var max_health: float = 100.0
var current_health: float = max_health

func _ready() -> void:
	if player:
		navigation_agent_2d.set_target_location(player.global_position)


func _physics_process(delta: float) -> void:
	if navigation_agent_2d.is_navigation_finished():
		return
	var direction := global_position.direction_to(navigation_agent_2d.get_next_location())
	var desired_velocity := direction * speed
	var steering := (desired_velocity - velocity) * delta * 4.0
	velocity += steering
	#add_central_force(velocity)
	velocity = move_and_slide(velocity, Vector2.ZERO, false, 4, 0.785398, false)
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider is RigidBody2D:
			#print("Collided with: ", collision.collider.name)
			collision.collider.apply_central_impulse(-collision.normal * velocity.length() * push_factor)

func impact(impulse: Vector2) -> void:
	velocity += impulse

func _on_NavTimer_timeout() -> void:
	if player:
		navigation_agent_2d.set_target_location(player.global_position)
