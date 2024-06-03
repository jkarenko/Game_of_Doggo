extends Node2D

const Dog = preload("res://scenes/Dog.tscn")
const Poop = preload("res://scenes/poop.tscn")
var actors = []

func _ready():
	var dog_instance = Dog.instantiate()
	add_child(dog_instance)
	dog_instance.position = Vector2(600, 250)
	actors.append(dog_instance)
	scale_all_sprites(self)

func scale_all_sprites(parent_node):
	for child in parent_node.get_children():
		if child is AnimatedSprite2D:
			child.scale = Vector2(5, 5)
		elif child.has_node("."):  # Check if the node has children
			scale_all_sprites(child)  # Recursively scale children
