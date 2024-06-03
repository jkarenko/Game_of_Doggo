extends AnimatedSprite2D

var rnd = RandomNumberGenerator.new()

func _ready():
	visible = true
	play("default")
	frame = rnd.randi_range(0, 3)
	pause()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
