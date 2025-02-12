extends TextureRect

# A custom control to preview noise areas (in white) versus non-affected areas (in black).
# The colorization is based on the "min" and "max" thresholds from the assigned 'object'.
# If the value is within the threshold range, it becomes white; otherwise black.
# If no valid noise is found, the texture is cleared.

var object: Object

func _ready() -> void:
	# Set a consistent size and aspect ratio handling for this preview.
	custom_minimum_size = Vector2(128, 128)
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	focus_mode = Control.FOCUS_NONE

	# Adjust size after setting stretch_mode to ensure no dimension issues.
	custom_minimum_size = get_combined_minimum_size()

	# Provide a helpful tooltip for users.
	tooltip_text = "White = tile is affected, Black = tile is unaffected."

func update() -> void:
	var noise: FastNoiseLite = _extract_noise_from_object()
	if not is_instance_valid(noise):
		texture = null
		return

	var size := 128
	var image: Image = noise.get_seamless_image(size, size)

	# Because 'image.get_size()' returns a Vector2i,
	# we need range() to properly iterate in GDScript.
	for x in range(size):
		for y in range(size):
			var value := noise.get_noise_2d(x, y)
			if _is_in_threshold(value):
				image.set_pixel(x, y, Color.WHITE)
			else:
				image.set_pixel(x, y, Color.BLACK)

	texture = ImageTexture.create_from_image(image)

func _extract_noise_from_object() -> FastNoiseLite:
	# Depending on the 'object' type, extract the relevant noise reference.
	if object is Modifier or object is NoiseCondition:
		return object.get("noise")
	elif object is NoiseGeneratorData:
		return object.settings.get("noise")
	return null

func _is_in_threshold(value: float) -> bool:
	# If 'min' and 'max' exist, check that 'value' is within [min, max].
	# Otherwise, default to false if thresholds are missing or invalid.
	var has_min := object.has("min")
	var has_max := object.has("max")
	if has_min and has_max:
		var min_val: float = object.get("min")
		var max_val: float = object.get("max")
		return value >= min_val and value <= max_val
	return false
