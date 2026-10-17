extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -400.0

# Вземаме връзка към AnimatedSprite2D възела
@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Добавяне на гравитация
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Скок (бутон "jump")
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Вземане на посоката за ляво/дясно (клавиши A/D или стрелки)
	var direction = Input.get_axis("left", "right")
	if direction != 0:
		velocity.x = direction * SPEED
		# Обръщане на пилето наляво или надясно
		animated_sprite.flip_h = (direction < 0)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Управление на анимациите
	if direction != 0:
		animated_sprite.play("run")
	else:
		animated_sprite.play("idle")

	move_and_slide()
