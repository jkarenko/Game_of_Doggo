extends Node2D

var max_speed = 300.0  # Maximum velocity
var acceleration = 3000.0  # Initial acceleration per second
var is_moving = false
var flip = false
var is_sniffing = false
var is_lying_down = false
var is_howling = false
var movement_keys = [KEY_W, KEY_S, KEY_A, KEY_D]
var current_velocity = Vector2()
var speech_offset = Vector2(12, -10)

func _ready():
	$Dog.global_position = Vector2(600, 250)
	$Dog.scale = Vector2(10, 10) # Sprite size
	$Dog.play("idle1") # Start playing the idle animation when loaded
	$Dog.flip_h = true
	$Dog/DogSpeech.visible = false
	$Dog/DogSpeech.offset = speech_offset

func is_any_movement_key_pressed(keys: Array) -> bool:
	for key in keys:
		if Input.is_key_pressed(key):
			return true
	return false

func _process(delta):
	var input_velocity = Vector2()
	
	# Movement related checks
	if Input.is_action_pressed("ui_up"):
		input_velocity.y -= 1
	if Input.is_action_pressed("ui_down"):
		input_velocity.y += 1
	if Input.is_action_pressed("ui_left"):
		input_velocity.x -= 1
	if Input.is_action_pressed("ui_right"):
		input_velocity.x += 1
		
	var movement_key_pressed = is_any_movement_key_pressed(movement_keys)
	
	# Normalize input velocity
	if input_velocity != Vector2():
		input_velocity = input_velocity.normalized() * max_speed
	else:
		input_velocity = Vector2()
	
	# Calculate the difference between current and target velocities
	var velocity_difference = input_velocity - current_velocity
	
	# Calculate the tapering acceleration
	var taper_acceleration_x = acceleration
	var taper_acceleration_y = acceleration
	var angle = input_velocity.angle()

	if angle == 0 or angle == PI:
		taper_acceleration_x = lerp(acceleration, acceleration * 0.3, abs(current_velocity.x) / max_speed)
	elif angle == PI/2 or angle == -PI/2:
		taper_acceleration_y = lerp(acceleration, acceleration * 0.3, abs(current_velocity.y) / max_speed)

	var taper_acceleration = Vector2(taper_acceleration_x, taper_acceleration_y)

	# Apply acceleration
	if velocity_difference != Vector2():
		var acceleration_vector = velocity_difference.normalized() * taper_acceleration * delta
	
		# If the magnitude of the acceleration vector is greater than the difference, clamp it
		if acceleration_vector.length() > velocity_difference.length():
			acceleration_vector = velocity_difference
		
		# Update current velocity
		current_velocity += acceleration_vector
		
	# Update position
	$Dog.position += current_velocity * delta

	# Animation and flipping logic
	if current_velocity.length() > 0:
		if movement_key_pressed:
			$Dog.play("walk")
		else:
			$Dog.set_frame_and_progress(1, 0)			
			$Dog.pause()
			
		if current_velocity.x > 0:
			flip = true
		elif current_velocity.x < 0:
			flip = false
		$Dog.flip_h = flip
		$Dog/DogSpeech.flip_h = !flip
		$Dog/DogSpeech.offset = speech_offset if flip else Vector2(-speech_offset.x, speech_offset.y)
	else:
		is_moving = false
		if is_sniffing:
			$Dog.play("sniff")
		elif is_lying_down:
			$Dog.play("lying_down")
		elif is_howling:
			$Dog.play("howl")
			$Dog/DogSpeech.visible = true
			$Dog/DogSpeech.play()
		else:
			$Dog.play("idle1")
			$Dog/DogSpeech.visible = false
			$Dog/DogSpeech.stop()
	
	# Update labels
	$CanvasLayer/VelocityLabel.text =  "%s\n%s\n%s\n%s\n%s" % [str(current_velocity), str(current_velocity.length()), input_velocity, taper_acceleration, input_velocity.angle()]

	# Other actions
	is_sniffing = Input.is_action_pressed("ui_accept")
	is_lying_down = Input.is_action_pressed("lie_down")
	is_howling = Input.is_key_pressed(KEY_F)  # This doesn't work with a controller
