extends RigidBody2D

export(int) var BODY_RADIUS
export(int) var CORE_RADIUS
export(int, 3, 128, 1) var MAX_POINTS
export(int) var REST_LENGTH
export(int) var STIFFNESS
export(float, 0.0, 1.0, 0.1) var DAMPING

var _collider_radius: float = 0.0

func _ready():
	$Collider.shape.radius = CORE_RADIUS
	
	_initialize()

func _physics_process(_delta: float) -> void:
	var index = 0

	for point in $Points.get_children():
		$PolyShape.polygon[index] = point.position.normalized() * (point.position.length() + _collider_radius)
		
		index += 1
	
	if Input.is_action_pressed("ui_up"):
		for point in $Points.get_children():
			point.apply_torque_impulse(200)
	
	if Input.is_action_pressed("ui_down"):
		for point in $Points.get_children():
			point.apply_torque_impulse(-200)

func _initialize() -> void:
	var points: PoolVector2Array = PoolVector2Array()
	var angle: float
	
	# Creating points
	for i in range(MAX_POINTS + 1):
		angle = deg2rad(i * 360 / MAX_POINTS - 90)
		points.push_back(Vector2(cos(angle), sin(angle)) * BODY_RADIUS)
	
	_collider_radius = points[0].distance_to(points[1]) / 2
	
	for i in range(MAX_POINTS):
		_add_point(i, _collider_radius, points[i])
	
	# Creating joints
	for i in range(MAX_POINTS):
		_add_joint(i, points[i])
		_add_spring(i, points[i])
	
	# Creating PolyShape
	points = PoolVector2Array()
	
	for point in $Points.get_children():
		points.push_back(point.position.normalized() * (_collider_radius + BODY_RADIUS))
	
	$PolyShape.polygon = points
	$PolyShape.uv = points


func _add_point(index: int, collider_radius: float, pos: Vector2) -> void:
	var point = RigidBody2D.new()
	var collider = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	
	# Setting Shape2D 
	shape.radius = collider_radius
	
	# Setting CollisionShape2D
	collider.set_name("Collider")
	collider.shape = shape
	
	# Setting RigidBody2D
	point.position = pos
	point.mass = 1
	point.set_name("Point" + str(index + 1))

	# Attaching nodes
	point.add_child(collider)
	$Points.add_child(point)


func _add_joint(index: int, from: Vector2) -> void:
	var joint = PinJoint2D.new()
	
	joint.set_name("Joint" + str(index + 1))
	joint.position = from
	joint.rotation = Vector2.RIGHT.angle_to(joint.position)
	joint.node_a = "../../Points/Point" + str(index + 1)
	
	if index < MAX_POINTS - 1:
		joint.node_b = "../../Points/Point" + str(index + 2)
	else:
		joint.node_b = "../../Points/Point1"
	
	$Joints.add_child(joint)


func _add_spring(index: int, to: Vector2) -> void:
	var joint = DampedSpringJoint2D.new()
	
	joint.set_name("Spring" + str(index + 1))
	joint.length = to.length()
	joint.rest_length = REST_LENGTH
	joint.stiffness = STIFFNESS
	joint.damping = DAMPING
	joint.position = Vector2.ZERO
	joint.rotation = Vector2.RIGHT.angle_to(to) - PI/2
	joint.node_a = "../.."
	joint.node_b = "../../Points/Point" + str(index + 1)
	
	$Springs.add_child(joint)
