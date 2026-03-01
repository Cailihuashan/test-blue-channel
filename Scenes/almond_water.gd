extends Area3D

func _on_body_entered(body):
	if body.name == "Player" or body is CharacterBody3D:
		body.has_key = true
		print("Item collected!")
		queue_free()
