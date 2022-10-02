extends RigidBody2D
class_name LevitatingObject

var shard_count = 1
var shard_velocity_map = {}
var exploded: bool = false
var explosion_speed: float = 10
onready var body: Polygon2D = $Body
var player
onready var levitate_particles: Particles2D = $LevitateParticles as Particles2D
onready var camera: PlayerCamera = get_tree().get_nodes_in_group("camera")[0] as PlayerCamera
onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D as CollisionPolygon2D

export (int) var _max_uses: int = 5
onready var _uses: int = _max_uses

onready var default_color: Color = body.color

func _ready():
	randomize()
	body.color = default_color.darkened(1 - (float(_uses) / float(_max_uses)))

func explode():
	stop_levitate()
	collision_polygon_2d.call_deferred("disabled", true)
	
	var points = body.polygon
	for _i in range(shard_count):
		points.append(Vector2(randi()%16, randi()%16))
	var delaunay_points = Geometry.triangulate_delaunay_2d(points)
	if not delaunay_points:
		print("serious error occurred no delaunay points found")
	for index in len(delaunay_points) / 3:
		var shard_pool = PoolVector2Array()
		var center = Vector2.ZERO
		for n in range(3):
			shard_pool.append(points[delaunay_points[(index * 3) + n]])
			center += points[delaunay_points[(index * 3) + n]]
		center /= 3
		var shard = Polygon2D.new()
		shard.polygon = shard_pool
		shard.color = body.color
		shard.global_position = body.global_position
		shard_velocity_map[shard] = Vector2(16, 16) - center #position relative to center of sprite
		shard.set_as_toplevel(true)
		add_child(shard)
	body.color.a = 0
		
func _integrate_forces(state: Physics2DDirectBodyState) -> void:
	if not exploded and player:
		state.set_linear_velocity(Vector2.ZERO)
		apply_central_impulse((get_global_mouse_position() - global_position) * 50)

func start_levitate(follow) -> void:
	player = follow
	levitate_particles.emitting = true

func stop_levitate() -> void:
	player = null
	levitate_particles.emitting = false

func _physics_process(delta):
	for child in shard_velocity_map.keys():
		child.position -= shard_velocity_map[child] * delta * explosion_speed
		child.rotation -= shard_velocity_map[child].x * delta * (explosion_speed * 0.01)
		explosion_speed = move_toward(explosion_speed, 0, 0.05)

func hit(fireball) -> void:
	if !exploded and fireball:
		exploded = true
		explosion_speed = fireball.linear_velocity.length() / weight
		explode()

func _on_LevitatingObject_body_entered(collider: Node) -> void:
	var bat: Bat = collider as Bat
	if bat and player and bat.current_health > 0:
		bat.take_damage(linear_velocity.length() / weight)
		bat.impact(linear_velocity * 2)
		camera.shake(0.2, 250, linear_velocity.length() / weight)
		_uses -= 1
		if _uses <= 0:
			explode()
		else:
			body.color = default_color.darkened(1 - (float(_uses) / float(_max_uses)))