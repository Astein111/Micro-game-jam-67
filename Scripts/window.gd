extends StaticBody2D

const MIN_WIDTH: float = 120.0
const MAX_WIDTH: float = 500.0
const SMOOTH_SPEED: float = 15.0
const TOGGLE_INTERVAL: float = 2.5 # Времето за автоматична смяна (2.5 секунди)

var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO

var aspect_ratio: float = 1.0
var current_width: float = 250.0
var target_width: float = 250.0
var current_size: Vector2 = Vector2(250, 250)

var toggle_timer: float = 0.0

func _ready():
	collision_layer = 0
	collision_mask = 0
	
	if has_node("InnerContent") and $InnerContent.texture:
		var frame_tex_size = $InnerContent.texture.get_size()
		if frame_tex_size.y > 0:
			aspect_ratio = frame_tex_size.x / frame_tex_size.y
		$InnerContent.visible = true
		$InnerContent.z_index = 2
		
	if has_node("Border"):
		$Border.visible = true
		$Border.z_index = 1
		
	current_size = Vector2(current_width, current_width / aspect_ratio)
	apply_window_size(current_size)

func _input(event):
	if event is InputEventMouseButton:
		# 1. Спираме влаченето, ако отпуснем левия бутон, независимо къде е мишката
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			is_dragging = false
			
		var mouse_pos = get_global_mouse_position()
		var rect = Rect2(global_position - (current_size / 2.0), current_size)
		var is_hovering = rect.has_point(mouse_pos)
		
		# 2. Започваме влачене (САМО ако мишката е отгоре)
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and is_hovering:
			is_dragging = true
			drag_offset = global_position - mouse_pos
			
		# 3. Оразмеряване (РАЗРЕШЕНО ако мишката е отгоре ИЛИ ако вече го влачим)
		elif event.pressed and (event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN):
			if is_hovering or is_dragging:
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

func _process(delta):
	# Гладко влачене
	if is_dragging:
		global_position = global_position.lerp(get_global_mouse_position() + drag_offset, 0.8)
		
	# Плавно оразмеряване
	if abs(current_width - target_width) > 0.1:
		current_width = lerp(current_width, target_width, SMOOTH_SPEED * delta)
		current_size = Vector2(current_width, current_width / aspect_ratio)
		apply_window_size(current_size)

	# Автоматично превключване на черното поле
	toggle_timer += delta
	if toggle_timer >= TOGGLE_INTERVAL:
		toggle_timer -= TOGGLE_INTERVAL
		if has_node("Border"):
			$Border.visible = not $Border.visible

	check_hidden_blocks()

func apply_window_size(new_size: Vector2):
	if has_node("Collision") and $Collision.shape is RectangleShape2D:
		$Collision.shape.size = new_size
		
	if has_node("InnerContent") and $InnerContent.texture:
		var frame_tex_size = $InnerContent.texture.get_size()
		if frame_tex_size.x > 0 and frame_tex_size.y > 0:
			$InnerContent.position = Vector2.ZERO
			$InnerContent.scale = new_size / frame_tex_size
			
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
