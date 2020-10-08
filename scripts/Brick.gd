extends StaticBody2D

func collide_with_mario(is_small = true):
  if is_small:
    $Bump.play()
    $AnimationPlayer.play("bounce")    
  else:
    $Break.play()
#    TODO
