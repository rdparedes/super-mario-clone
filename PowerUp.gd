extends StaticBody2D

const DEFAULT = 0
const CONSUMED = 1

export var state = DEFAULT

func _ready():
  $AnimationPlayer/AnimatedSprite.play("default")

func collide_with_mario(is_small = true):
  if state == DEFAULT:
    state = CONSUMED
    $PowerUpAppears.play()
    $Bump.play()
    $AnimationPlayer.play("consume")
    $AnimationPlayer/AnimatedSprite.play("consumed")
    
    $Fungus.pop_up()
  else:
    $Bump.play()    
