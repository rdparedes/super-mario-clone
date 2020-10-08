extends KinematicBody2D

const WALK_SPEED = 90
const RUN_SPEED = 140
const JUMP_FORCE = 382
const JUMP_TIMER = 33
const GRAVITY = 900
const MAX_VERTICAL_SPEED = 220
const WALK_ACCELERATION = 2
const DESACCELERATION = 2.5
const TURN_AROUND_FACTOR = 4
const LOWEST_POINT = 232

export var starting_position = Vector2()

var velocity = Vector2()
var can_move = true
var is_alive = true
var is_small = true
var is_walking = false
var is_turning = false
var direction = "RIGHT"
var j_timer = 0
var current_sprite

var death_timer = Timer.new()

# Used to know if he's falling
var previous_y

func _ready():
  position = starting_position
  current_sprite = $SmallSprite
  death_timer.set_wait_time(2.0)
  death_timer.connect("timeout", self, "_on_death_timer_timeout")
  add_child(death_timer)
  
func _on_death_timer_timeout():
  shrink()
  look_right()
  is_alive = true
  velocity = Vector2.ZERO  
  position = starting_position
  death_timer.stop()
  
func _process(delta):
  current_sprite.speed_scale = max(1.0, (abs(velocity.x) / (RUN_SPEED * 0.5)))
  
  if not is_on_floor():
    current_sprite.play("jump")
  elif is_turning:
    current_sprite.play("turn")
  elif is_walking:
    current_sprite.play("walk")
  else:
    current_sprite.play("idle")

func is_moving_left():
  return velocity.x < 0

func is_moving_right():
  return velocity.x > 0

func look_right():
  current_sprite.set_flip_h(false)

func look_left():
  current_sprite.set_flip_h(true)

func cap_increase(v, step, max_v):
  v += step
  if v >= max_v:
    v = max_v
  return v

func cap_decrease(v, step, min_v):
  v -= step
  if v <= min_v:
    v = min_v
  return v

func move(is_running = false):
  is_walking = true
  var top_speed = RUN_SPEED if is_running else WALK_SPEED
  
  if direction == "LEFT":
    var _acc = WALK_ACCELERATION
    # when turning around - accelerate faster
    if is_moving_right():
      is_turning = true
      _acc *= TURN_AROUND_FACTOR
    velocity.x = cap_decrease(velocity.x, _acc, -top_speed)
    if velocity.x <= 0:
      is_turning = false
  elif direction == "RIGHT":
    var _acc = WALK_ACCELERATION
    # when turning around - accelerate faster
    if is_moving_left():
      is_turning = true
      _acc *= TURN_AROUND_FACTOR
    velocity.x = cap_increase(velocity.x, _acc, top_speed)
    if velocity.x >= 0:
      is_turning = false

func is_falling():
  return position.y > previous_y
  
func has_fallen_under():
  return position.y >= LOWEST_POINT
  
func set_direction(dir = direction, override = false):
  if dir == "LEFT":
    direction = "LEFT"
    if is_on_floor() or override:
      look_left()
  elif dir == "RIGHT":
    direction = "RIGHT"
    if is_on_floor() or override:
      look_right()

func get_input():
  var left = Input.is_action_pressed("ui_left")
  var right = Input.is_action_pressed("ui_right")
  var jump_just_pressed = Input.is_action_just_pressed("ui_jump")
  var jump = Input.is_action_pressed("ui_jump")
  var is_running = Input.is_action_pressed("ui_run")

  if left:
    set_direction("LEFT")
    move(is_running)    
  elif right:
    set_direction("RIGHT")
    move(is_running)
    
  if jump_just_pressed and is_on_floor():
    j_timer = 0
    $JumpSmall.play()
    velocity.y -= (JUMP_FORCE * 3/5)
  elif jump and j_timer <= JUMP_TIMER and not is_falling() and not is_on_floor():
    j_timer += 1
    velocity.y -= (JUMP_FORCE * 1/40)

  # If not moving in any direction, desaccelerate
  if not left and not right:
    if is_moving_left():
      velocity.x = cap_increase(velocity.x, DESACCELERATION, 0)
    elif is_moving_right():
      velocity.x = cap_decrease(velocity.x, DESACCELERATION, 0)

  if velocity.x == 0:
    is_turning = false
    is_walking = false
  
func handle_ceilling_collision():
  var collision = get_slide_collision(0)
  var collider = collision.collider

  if collider.collision_mask == 1:
    collider.collide_with_mario()
  elif collider.collision_mask == 2:
    collider.collide_with_mario(is_small)

func _physics_process(delta):
  if not is_alive or not can_move:
    return
    
  if has_fallen_under():
    is_alive = false
    death_timer.start()
  
  velocity.y += (GRAVITY * delta)

  if is_on_ceiling():
    # "Rebound" effect
    velocity.y += (MAX_VERTICAL_SPEED / 3)
    handle_ceilling_collision()

  if velocity.y >= MAX_VERTICAL_SPEED:
    velocity.y = MAX_VERTICAL_SPEED
  
  get_input()
  velocity = move_and_slide(velocity, Vector2(0, -1))

  previous_y = position.y

func power_up():
  $PowerUp.play()
  can_move = false
  
func grow_up():
  $CollisionShape.position.y = -6
  $CollisionShape.scale.y = 2
  $SmallSprite.visible = false
  $GrownUpSprite.visible = true
  current_sprite = $GrownUpSprite
  current_sprite.play($SmallSprite.animation)
  set_direction(direction, true)
  
func shrink():
  $CollisionShape.position.y = 0
  $CollisionShape.scale.y = 1
  $SmallSprite.visible = true
  $GrownUpSprite.visible = false
  current_sprite = $SmallSprite  

func _on_PowerUp_finished():
  grow_up()
  can_move = true  
