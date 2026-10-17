extends CharacterBody2D

@export var jump_velocity: float = -400.0
@export var gravity: float = 980.0
@export var jump_cut: float = 0.6

func _physics_process(delta: float) -> void:
	var direction = Input.get_axis("left", "right")
	velocity.x = direction * 300.0
	if not is_on_floor():
		velocity.y += gravity * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= jump_cut
	move_and_slide()
