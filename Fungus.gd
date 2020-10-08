extends RigidBody2D

func pop_up():
  visible = true
  apply_impulse(Vector2(0.5, 1), Vector2(50, -80))
  
func _physics_process(delta):
  pass

func _on_Fungus_body_entered(body):
  if body.name == "Mario":
    body.power_up()
    queue_free()
