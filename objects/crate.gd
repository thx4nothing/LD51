extends RigidBody2D
class_name Crate

var shard_count = 1
var shard_velocity_map = {}
var exploded: bool = false
var explosion_speed: float = 10
onready var body: Polygon2D = $Body
var player
onready var levitate_particles: Particles2D = $LevitateParticles as Particles2D


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()

func explode():
	#this will let us add more points to our polygon later on
	var points = body.polygon
	for i in range(shard_count):
		points.append(Vector2(randi()%16, randi()%16))
	
	
	var delaunay_points = Geometry.triangulate_delaunay_2d(points)
	
	if not delaunay_points:
		print("serious error occurred no delaunay points found")
	
	#loop over each returned triangle
	for index in len(delaunay_points) / 3:
		var shard_pool = PoolVector2Array()
		#find the center of our triangle
		var center = Vector2.ZERO
		
		# loop over the three points in our triangle
		for n in range(3):
			shard_pool.append(points[delaunay_points[(index * 3) + n]])
			center += points[delaunay_points[(index * 3) + n]]
			
		# adding all the points and dividing by the number of points gets the mean position
		center /= 3
		
		#create a new polygon to give these points to
		
		var shard = Polygon2D.new()
		shard.polygon = shard_pool
		shard.color = body.color
		shard.global_position = body.global_position
		shard_velocity_map[shard] = Vector2(16, 16) - center #position relative to center of sprite
		shard.set_as_toplevel(true)
		add_child(shard)
		#print(shard)
		
	#this will make our base sprite invisible
	body.color.a = 0
		
func _integrate_forces(state: Physics2DDirectBodyState) -> void:
	if not exploded and player:
		state.set_linear_velocity(Vector2.ZERO)
		apply_central_impulse ((get_global_mouse_position() - global_position) * 50)
		pass

func start_levitate(follow) -> void:
	player = follow
	levitate_particles.emitting = true

func stop_levitate() -> void:
	player = null
	levitate_particles.emitting = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	#we wan't to chuck our traingles out from the center of the parent
	for child in shard_velocity_map.keys():
		child.position -= shard_velocity_map[child] * delta * explosion_speed
		child.rotation -= shard_velocity_map[child].x * delta * (explosion_speed * 0.01)
		explosion_speed = move_toward(explosion_speed, 0, 0.05)
		#apply gravity to the velocity map so the triangle falls
		#shard_velocity_map[child].y -= delta * 55

func _on_Crate_body_entered(body: Node) -> void:
	if body is Bat:
		var bat: Bat = body as Bat
		bat.impact(linear_velocity)
		#print(linear_velocity)
		
	if !exploded and body is FireBall:
		var thing: RigidBody2D = body as RigidBody2D
		exploded = true
		explosion_speed = thing.linear_velocity.length() / weight
		print(explosion_speed)
		explode()
