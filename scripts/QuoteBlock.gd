extends StaticBody2D

export var state = 0

func _ready():
  $AnimationPlayer/AnimatedSprite.play("default")

func collide_with_mario():
  if state == 0:
    state = 1
    $Coin.play()
    $Bump.play()
    $AnimationPlayer.play("consume")
    $AnimationPlayer/AnimatedSprite.play("consumed")
  else:
    $Bump.play()    
