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

onready var default_color: Color = body.color

func _ready() -> void:
	if player:
		navigation_agent_2d.set_target_location(player.global_position)
		navigation_agent_2d.connect("velocity_computed", self, "move")

func impact(impulse: Vector2) -> void:
	velocity += impulse
	#navigation_agent_2d.set_velocity(velocity)

func move(_velocity: Vector2) -> void:
	velocity = move_and_slide(_velocity, Vector2.ZERO, false, 4, 0.785398, false)
	var _rotation := velocity.angle() 
	body.rotation = _rotation
	collision_body.rotation = _rotation
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider is RigidBody2D:
			#print("Collided with: ", collision.collider.name)
			collision.collider.apply_central_impulse(-collision.normal * velocity.length())
		if collision.collider == player:
			player.hurt(damage, self)

func take_damage(dmg: float) -> void:
	current_health -= dmg
	if current_health <= 0:
		emit_signal("died", self)
		blood_particles.one_shot = false
		blood_particles.explosiveness = 0
		blood_particles.speed_scale = 1
		blood_particles.emitting = true
	else:
		blood_particles.one_shot = true
		blood_particles.explosiveness = 1
		blood_particles.speed_scale = 2
		blood_particles.emitting = true
		var new_color_index = remap_range(current_health, 0, max_health, 0.5, 1)
		body.color = default_color.lightened(1 - new_color_index)

func _physics_process(delta: float) -> void:
	if current_health > 0:
		if navigation_agent_2d.is_navigation_finished():
			return
		var direction := global_position.direction_to(navigation_agent_2d.get_next_location())
		var desired_velocity := direction * speed
		var steering := (desired_velocity - velocity) * delta * 4.0
		velocity += steering
		navigation_agent_2d.set_velocity(velocity)
		#add_central_force(velocity)


func _on_NavTimer_timeout() -> void:
	if player:
		navigation_agent_2d.set_target_location(player.global_position)

func remap_range(value, InputA, InputB, OutputA, OutputB):
	return(value - InputA) / (InputB - InputA) * (OutputB - OutputA) + OutputA
