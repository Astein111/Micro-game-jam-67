extends CharacterBody2D

@export var jump_velocity: float = -400.0
@export var gravity: float = 1000.0
@export var jump_cut: float = 0.5

@export var dash_velocity: float = 700.0
@export var dash_duration: float = 0.2
@export var max_stamina: float = 3.0
@export var stamina_regen: float = 0.5

@onready var animated_sprite = $AnimatedSprite2D
@onready var stamina_bar: ProgressBar = $UI/StaminaBar

var is_dashing = false
var facing_direction = 1
var stamina: float = 3.0

func _ready() -> void:
	stamina = max_stamina
	stamina_bar.max_value = max_stamina
	stamina_bar.value = stamina

func _physics_process(delta: float) -> void:
	var direction = Input.get_axis("left", "right")

	if direction != 0:
		facing_direction = sign(direction)
		animated_sprite.flip_h = direction < 0

	if not is_dashing:
		stamina = min(stamina + stamina_regen * delta, max_stamina)
		velocity.x = direction * 300.0

		if not is_on_floor():
			velocity.y += gravity * delta

		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = jump_velocity

		if Input.is_action_just_released("jump") and velocity.y < 0:
			velocity.y *= jump_cut

		if Input.is_action_just_pressed("dash") and stamina >= 1.0:
			handle_dash()

	if not is_dashing:
		if not is_on_floor():
			animated_sprite.play("jump")
		elif direction != 0:
			animated_sprite.play("run")
		else:
			animated_sprite.play("idle")

	stamina_bar.value = stamina

	move_and_slide()

func handle_dash() -> void:
	is_dashing = true
	stamina -= 1.0

	velocity.x = facing_direction * dash_velocity
	velocity.y = 0

	await get_tree().create_timer(dash_duration).timeout

	is_dashing = false
