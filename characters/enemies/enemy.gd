extends KinematicBody2D
class_name Enemy

# movement
export (float) var speed := 200.0
var velocity: Vector2 = Vector2.ZERO

# hp and damage
signal died
var max_health: float = 100.0
var current_health: float = max_health
export (float) var damage: float = 10.0

# get player
onready var player = get_tree().get_nodes_in_group("player")[0]

# navigation
onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D as NavigationAgent2D

# nodes
onready var body: Polygon2D = $Body as Polygon2D
onready var collision_body: CollisionPolygon2D = $CollisionBody as CollisionPolygon2D
onready var blood_particles: Particles2D = $BloodParticles as Particles2D

func _ready() -> void:
	if player:
		navigation_agent_2d.set_target_location(player.global_position)

func impact(impulse: Vector2) -> void:
	velocity += impulse

func take_damage(dmg: float) -> void:
	current_health -= dmg
	if current_health <= 0:
		emit_signal("died", self)
		set_physics_process(false)
		blood_particles.one_shot = false
		blood_particles.explosiveness = 0
		blood_particles.speed_scale = 1
		blood_particles.emitting = true
	else:
		blood_particles.one_shot = true
		blood_particles.explosiveness = 1
		blood_particles.speed_scale = 2
		blood_particles.emitting = true

func _physics_process(delta: float) -> void:
	if navigation_agent_2d.is_navigation_finished():
		return
	var direction := global_position.direction_to(navigation_agent_2d.get_next_location())
	var desired_velocity := direction * speed
	var steering := (desired_velocity - velocity) * delta * 4.0
	velocity += steering
	#add_central_force(velocity)
	velocity = move_and_slide(velocity, Vector2.ZERO, false, 4, 0.785398, false)
	var _rotation := velocity.angle() 
	body.rotation = _rotation
	collision_body.rotation = _rotation
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider is RigidBody2D:
			#print("Collided with: ", collision.collider.name)
			collision.collider.apply_central_impulse(-collision.normal * velocity.length())
		if collision.collider == player:
			player.hurt(damage)


func _on_NavTimer_timeout() -> void:
	if player:
		navigation_agent_2d.set_target_location(player.global_position)
