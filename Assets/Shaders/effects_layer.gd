extends CanvasLayer

@onready var pixel_sort: CanvasItem = $PixelSort # Or $ColorRect
@onready var fade_out: ColorRect = $FadeOut

func _ready() -> void:
	GameBus.call_pixel_sort.connect(trigger_pixel_sort)

func trigger_pixel_sort() -> void:
	# 1. Grab the specific material attached to the node
	var mat: ShaderMaterial = pixel_sort.material as ShaderMaterial
	
	if mat:
		# 2. Force the starting value to 0.0 just in case it got stuck halfway
		mat.set_shader_parameter("sort", 0.0)
		
		# 3. Create the Tween
		var tween = create_tween()
		
		# 4. Tween the shader parameter!
		# Syntax: tween_property(object, "shader_parameter/YOUR_VARIABLE_NAME", target_value, duration_in_seconds)
		tween.tween_property(mat, "shader_parameter/sort", 2.0, 1.0)
		
		# Optional: Add an ease-out so the sort slows down dramatically at the end
		tween.set_trans(Tween.TRANS_EXPO)
		tween.set_ease(Tween.EASE_OUT)
func fade_black() -> void:
	var tween := create_tween()
	
	tween.tween_property(fade_out, "color:a", 255, 3.0)
	
