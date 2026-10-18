extends Area2D

@export var light_color: Color = Color("#D23108")
@onready var light: PointLight2D = $light

func _ready() -> void:
	light.color = light_color

	var gradient_texture = light.texture as GradientTexture2D

	if gradient_texture:
		gradient_texture = gradient_texture.duplicate()
		gradient_texture.gradient = gradient_texture.gradient.duplicate()
		light.texture = gradient_texture

		gradient_texture.gradient.set_color(0, light_color)
