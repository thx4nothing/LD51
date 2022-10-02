extends KinematicBody2D
class_name Enemy

# movement
export (float) var speed := 400.0
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

# shrinking
var shrinking: bool = false
var shrunk: bool = false
onready var shrink_particles: Particles2D = $ShrinkParticles as Particles2D
export (float) var _shrinking_speed: float = 0.25
export (float) var _growth_speed: float = 0.1
onready var shrink_step_area: Area2D = $ShrinkStepArea as Area2D


onready var default_color: Color = body.color

func _ready() -> void:
	if player:
		navigation_agent_2d.set_target_location(player.global_position)
		navigation_agent_2d.connect("velocity_computed", self, "move")

func impact(impulse: Vector2) -> void:
	velocity += impulse
	move(velocity)

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
			if not shrunk:
				player.hurt(damage, self)

func start_shrinking() -> void:
	if not shrunk and not shrinking:
		shrink_particles.emitting = true
		shrinking = true

func stop_shrinking() -> void:
	shrink_particles.emitting = false
	shrinking = false

func take_damage(dmg: float) -> void:
	if current_health > 0:
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

func _process(delta: float) -> void:
	if navigation_agent_2d.get_final_location().distance_to(global_position) > 1000:
		take_damage(1000)
	if shrinking and not shrunk:
		_shrink(_shrinking_speed * delta)
		if scale.x <= 0.35:
			stop_shrinking()
			shrunk = true
			speed *= _shrinking_speed
	elif not shrinking:
		_shrink(-_growth_speed * delta)
		if scale.x == 1 and shrunk:
			shrunk = false
			speed /= _shrinking_speed

func _physics_process(delta: float) -> void:
	if navigation_agent_2d.get_final_location().distance_to(global_position) < navigation_agent_2d.target_desired_distance:
		var _rotation = get_angle_to(player.global_position)
		body.rotation = _rotation
		collision_body.rotation = _rotation
	elif current_health > 0:
		var direction := global_position.direction_to(navigation_agent_2d.get_next_location())
		var desired_velocity := direction * speed
		var steering := (desired_velocity - velocity) * delta * 4.0
		velocity += steering
		navigation_agent_2d.set_velocity(velocity)
		#add_central_force(velocity)

func _on_NavTimer_timeout() -> void:
	if player and not shrunk:
		navigation_agent_2d.set_target_location(player.global_position)
	else:
		var player_normal: = -global_position.direction_to(player.global_position)
		navigation_agent_2d.set_target_location(player_normal * rand_range(50, 200))

func remap_range(value, InputA, InputB, OutputA, OutputB):
	return(value - InputA) / (InputB - InputA) * (OutputB - OutputA) + OutputA

func _shrink(amount: float) -> void:
	scale.x = clamp(scale.x - amount, 0.3, 1)
	scale.y = clamp(scale.y - amount, 0.3, 1)
	shrink_step_area.scale.x = clamp(scale.x - amount, 0.3, 1)
	shrink_step_area.scale.y = clamp(scale.y - amount, 0.3, 1)

func _on_ShrinkStepArea_body_entered(_collider: Node) -> void:
	if shrunk:
		take_damage(current_health)
