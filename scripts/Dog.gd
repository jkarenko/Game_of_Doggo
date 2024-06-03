extends AnimatedSprite2D

var max_speed = 300.0
var acceleration = 3000.0
var speech_offset = Vector2(-12, -10)
var current_velocity = Vector2()
var extra_sprites = []
var poop_size = 0
var poop_instance: AnimatedSprite2D = null
var can_poop = true

const poop := preload("res://scenes/poop.tscn")

func _ready():
	play("idle1")
	extra_sprites.append_array([$Speech])
	$Speech.offset = speech_offset
	

func _process(delta):
	handle_movement(delta)
	handle_state()

func handle_movement(delta):
	var input_velocity = Vector2()
	if Input.is_action_pressed("ui_up"):
		input_velocity.y -= 1
	if Input.is_action_pressed("ui_down"):
		input_velocity.y += 1
	if Input.is_action_pressed("ui_left"):
		flip_h = false
		input_velocity.x -= 1
	if Input.is_action_pressed("ui_right"):
		flip_h = true
		input_velocity.x += 1
	
	if input_velocity != Vector2():
		input_velocity = input_velocity.normalized() * max_speed
	var velocity_difference = input_velocity - current_velocity
	if velocity_difference != Vector2():
		var acceleration_vector = velocity_difference.normalized() * acceleration * delta
		if acceleration_vector.length() > velocity_difference.length():
			acceleration_vector = velocity_difference
		current_velocity += acceleration_vector
	position += current_velocity * delta

func set_action(action = null):
	if action == null:
		$Speech.visible = false
		return
	if action == "howl":
		$Speech.flip_h = !flip_h
		$Speech.offset.x = speech_offset.x * -1 if flip_h else speech_offset.x
		$Speech.visible = true
		play(action)
		return
	for sprite in extra_sprites:
		sprite.visible = false
	play(action)
	match action:
		"poop", can_poop:
			if $Timer.is_stopped():
				$Timer.start()
			elif poop_size > 5 and poop_instance:
				play("idle1")
				can_poop = false
				poop_instance = null
				$Timer.stop()


func handle_state():
	if current_velocity.length() > 0:
		set_action("walk")
		if not can_poop and not poop_instance:
			poop_reset()
	elif Input.is_key_pressed(KEY_SPACE):
		set_action("sniff")
	elif Input.is_key_pressed(KEY_CTRL):
		set_action("lying_down")
	elif Input.is_key_pressed(KEY_F):
		set_action("howl")
	elif Input.is_key_pressed(KEY_R):
		set_action("sleep")
	elif Input.is_key_pressed(KEY_C) and can_poop:
		set_action("poop")
	elif Input.is_key_pressed(KEY_V):
		set_action("pee")
	else:
		set_action("idle1")
	
	if !Input.is_key_pressed(KEY_C) and not $Timer.is_stopped():
		poop_reset()
	

func poop_reset():
	can_poop = true
	$Timer.stop()
	poop_instance = null
	poop_size = 0

func _on_timer_timeout():
	poop_size += 1
	if poop_size == 1 and not poop_instance:
		poop_instance = poop.instantiate()
		poop_instance.position = global_position
		poop_instance.position.x += 25 if not flip_h else -25
		poop_instance.position.y += 20
		get_parent().add_child(poop_instance)
	poop_instance.scale = Vector2(poop_size, poop_size)
	poop_instance.position.y = adjust_y_position_for_scale(global_position.y, poop_size)
	
func adjust_y_position_for_scale(original_y_position, scale_factor):
	var y_offset = 8 * (scale_factor - 1)
	return original_y_position - y_offset + 32
