extends StaticBody2D

const MIN_WIDTH: float = 120.0
const MAX_WIDTH: float = 500.0
const SMOOTH_SPEED: float = 15.0
const HIDE_DURATION: float = 5.0

var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO

var aspect_ratio: float = 1.0
var current_width: float = 250.0
var target_width: float = 250.0
var current_size: Vector2 = Vector2(250, 250)

var hide_timer: float = 0.0

func _ready():
	collision_layer = 0
	collision_mask = 0
	
	# Взимаме точната пропорция от текстурата на рамката (InnerContent)
	if has_node("InnerContent") and $InnerContent.texture:
		var frame_tex_size = $InnerContent.texture.get_size()
		if frame_tex_size.y > 0:
			aspect_ratio = frame_tex_size.x / frame_tex_size.y
		$InnerContent.visible = true
		$InnerContent.z_index = 2
		
	# Черното поле (Border) стои под сивия кант на рамката
	if has_node("Border"):
		$Border.visible = true
		$Border.z_index = 1
		
	current_size = Vector2(current_width, current_width / aspect_ratio)
	apply_window_size(current_size)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			is_dragging = false
			
		var mouse_pos = get_global_mouse_position()
		var rect = Rect2(global_position - (current_size / 2.0), current_size)
		
		if rect.has_point(mouse_pos):
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				is_dragging = true
				drag_offset = global_position - mouse_pos
				hide_black_box()
				
			elif event.pressed:
				var step = 40.0
				var scrolled = false
				
				if event.button_index == MOUSE_BUTTON_WHEEL_UP:
					target_width += step
					scrolled = true
				elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
					target_width -= step
					scrolled = true
					
				if scrolled:
					target_width = clamp(target_width, MIN_WIDTH, MAX_WIDTH)
					hide_black_box()

func hide_black_box():
	hide_timer = HIDE_DURATION
	# Скриваме САМО черното квадратче за 5 секунди
	if has_node("Border"):
		$Border.visible = false
	# Рамката винаги остава видима
	if has_node("InnerContent"):
		$InnerContent.visible = true

func _process(delta):
	if is_dragging:
		global_position = global_position.lerp(get_global_mouse_position() + drag_offset, 0.8)
		
	if abs(current_width - target_width) > 0.1:
		current_width = lerp(current_width, target_width, SMOOTH_SPEED * delta)
		current_size = Vector2(current_width, current_width / aspect_ratio)
		apply_window_size(current_size)

	if hide_timer > 0:
		hide_timer -= delta
		if hide_timer <= 0:
			if has_node("Border"):
				$Border.visible = true

	check_hidden_blocks()

func apply_window_size(new_size: Vector2):
	if has_node("Collision") and $Collision.shape is RectangleShape2D:
		$Collision.shape.size = new_size
		
	# 1. Рамката (InnerContent) определя външния размер
	if has_node("InnerContent") and $InnerContent.texture:
		var frame_tex_size = $InnerContent.texture.get_size()
		if frame_tex_size.x > 0 and frame_tex_size.y > 0:
			$InnerContent.position = Vector2.ZERO
			$InnerContent.scale = new_size / frame_tex_size
			
	# 2. Черното квадратче (Border) се вписва точно вътре в сивата рамка
	if has_node("Border") and $Border.texture:
		var black_tex_size = $Border.texture.get_size()
		if black_tex_size.x > 0 and black_tex_size.y > 0:
			var inner_box_size = Vector2(new_size.x * 0.90, new_size.y * 0.85)
			$Border.scale = inner_box_size / black_tex_size
			$Border.position = Vector2(0, new_size.y * 0.025)

func check_hidden_blocks():
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	
	if has_node("Collision"):
		query.shape = $Collision.shape
		query.transform = global_transform
		query.collision_mask = 0xFFFFFFFF
		
		var results = space_state.intersect_shape(query)
		for result in results:
			var collider = result.collider
			if collider and collider.is_in_group("hidden_blocks"):
				collider.visible = true
