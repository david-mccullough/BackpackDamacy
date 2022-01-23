extends KinematicBody

var gravity = Vector3(0, -.03, 0)

# Declare member variables here. Examples:
var velocity = Vector3(0,0,0)
var acceleration = Vector3(0,0,0)

var accelerationRate = .8
var maxSpeed = 10
var jumpStrength = 20
var walkFriction = 2

var floorCheckDist = 0.1
var minFloorAngle = 0.8

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func get_input():
	var xDir = 0
	var zDir = 0;
	var right = int(Input.is_action_pressed('ui_right'))
	var left = int(Input.is_action_pressed('ui_left'))
	var forward = int(Input.is_action_pressed('ui_up'))
	var backward = int(Input.is_action_pressed('ui_down'))
	var jump = Input.is_action_just_pressed('ui_select')

	
	xDir = -right + left;	
	zDir = forward - backward;
	
	var dir = Vector3(xDir, 0, zDir).normalized()
	

	
	acceleration = dir * accelerationRate;	
	
	if jump:
		acceleration.y += jumpStrength
	
	velocity += acceleration
	print(velocity)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (is_on_floor()):	
		_applyFriction(delta);
		velocity.y = 0
	else:
		_applyGravity()
	
	get_input()
	
	#_applyAcceleration();
	_clampHorizontalVelocity();

	# apply velocity
	# move_and_slide() automatically includes the timestep in its calculation, so you should not multiply the velocity vector by delta.
	move_and_slide(velocity, Vector3(0,1,0))
	
	
func _clampHorizontalVelocity():
	var horizontalVelocity = velocity;
	horizontalVelocity.y = 0;
	if horizontalVelocity.length() > maxSpeed:
		horizontalVelocity = horizontalVelocity.normalized() * maxSpeed;
	velocity.x = horizontalVelocity.x;
	velocity.z = horizontalVelocity.z;
	# Ignore the y value to prevent clamping the fall speed

func _applyFriction(delta):
	var horizontalVelocity = velocity;
	horizontalVelocity.y = 0;

	var frictionDir = velocity.normalized();
	if acceleration.length_squared() > 0.001:
		# Don't apply friction along the acceleration direction
		frictionDir += acceleration.normalized() * -acceleration.normalized().dot(frictionDir);

	# Apply friction only when on the ground
	var frameFriction = frictionDir * walkFriction;
	if (frameFriction.length() > horizontalVelocity.length()):
		horizontalVelocity = Vector3.ZERO;
	else:
		horizontalVelocity -= frameFriction;

	velocity.x = horizontalVelocity.x;
	velocity.z = horizontalVelocity.z;
	
func _applyGravity():
	velocity += gravity
