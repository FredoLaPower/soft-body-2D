tool
extends RigidBody2D

export(int) var BODY_RADIUS
export(int) var CORE_RADIUS
export(int, 3, 128, 1) var MAX_POINTS
export(int) var REST_LENGTH
export(int) var STIFFNESS
export(float, 0.0, 1.0, 0.1) var DAMPING


func _ready():
	$Collider.shape.radius = CORE_RADIUS
	
	_initialize()
	print_tree_pretty()

func _physics_process(_delta: float) -> void:
#	var index = 0
#
#	for point in $Points.get_children():
#		$PolyShape.polygon[index] = point.position
#
#		index += 1
#
#	if Input.is_action_pressed("ui_up"):
#		for point in $Points.get_children():
#			point.apply_torque_impulse(200)
#
#	if Input.is_action_pressed("ui_down"):
#		for point in $Points.get_children():
#			point.apply_torque_impulse(-200)
	
	update()


func _draw() -> void:
	var points: PoolVector2Array = PoolVector2Array()
	var angle: float = 0.0
	
	for i in range(MAX_POINTS + 1):
		angle = deg2rad(i * 360 / MAX_POINTS)
		
		points.push_back(Vector2(BODY_RADIUS, 0).rotated(angle))
	
	for i in range(MAX_POINTS):
		draw_line(points[i], points[i + 1], Color(255, 0, 0, 255))
		
	for body in $Points.get_children():
		draw_circle(body.position, 5, Color(255, 0, 0, 100))


func _initialize() -> void:
	var points: PoolVector2Array = PoolVector2Array()
	
	for i in range(MAX_POINTS + 1):
		points.push_back(Vector2(BODY_RADIUS, 0).rotated(deg2rad(i * 360 / MAX_POINTS)))
	
	for i in range(MAX_POINTS):
		_add_point(i, points[i], points[i + 1])
		_add_joint(i, points[i])
		_add_spring(i, points[i], points[i + 1])

func _add_point(index: int, a: Vector2, b:Vector2) -> void:
	var point = RigidBody2D.new()
	var collider = CollisionShape2D.new()
	var shape = CapsuleShape2D.new()
	
	var label = Label.new()
	label.text = "Point" + str(index + 1)
	point.add_child(label)
	
	# Setting Shape2D 
	shape.radius = 5
	shape.height = a.distance_to(b)
	
#	# Setting CollisionShape2D
	collider.set_name("Collider")
	collider.shape = shape
	collider.rotation = PI / 2
	point.add_child(collider)
	
	# Setting RigidBody2D
	point.set_name("Point" + str(index + 1))
	point.rotation = Vector2.RIGHT.angle_to(b - a)
	point.position = (a + b) / 2

	# Attaching nodes
	$Points.add_child(point)


# warning-ignore:unused_argument
func _add_joint(index: int, pos: Vector2) -> void:
	var joint = PinJoint2D.new()
	
	joint.set_name("Joint" + str(index + 1))
	joint.position = pos
	joint.node_a = "../../Points/Point" + str(index + 1)
	
	if index < MAX_POINTS - 1:
		joint.node_b = "../../Points/Point" + str(index + 2)
	else:
		joint.node_b = "../../Points/Point1"
	
#	var label = Label.new()
#	label.text = "J%s%s" % [get_node(joint.node_a).get_name(), get_node(joint.node_b).get_name()]
#	joint.add_child(label)
	
	
	$Joints.add_child(joint)


func _add_spring(index: int, a: Vector2, b: Vector2) -> void:
	var joint = DampedSpringJoint2D.new()
	
	joint.set_name("Spring" + str(index + 1))
	joint.length = Vector2.ZERO.distance_to((a + b) / 2)
	joint.rest_length = REST_LENGTH
	joint.stiffness = STIFFNESS
	joint.damping = DAMPING
	joint.rotation = Vector2.RIGHT.angle_to(b - a)
	joint.node_a = "../.."
	joint.node_b = "../../Points/Point" + str(index + 1)
	
	$Springs.add_child(joint)
