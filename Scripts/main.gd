extends Node2D

@onready var boss_sprite = $Boss
@onready var camera = $"Player/camera"

func _ready() -> void:
	boss_sprite.modulate.a = 0.3

func _process(delta: float) -> void:
	boss_sprite.global_position.x = camera.get_screen_center_position().x
	
func idle_animation() -> void:
	while true:
		var tween = create_tween()
		tween.tween_property(boss_sprite, "scale", Vector2(0.8, 0.8), 1.0)
		await tween.finished

		tween = create_tween()
		tween.tween_property(boss_sprite, "scale", Vector2(1.0, 1.0), 1.0)
		await tween.finished
