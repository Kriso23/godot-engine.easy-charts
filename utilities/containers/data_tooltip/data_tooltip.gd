@tool
extends PanelContainer
class_name DataTooltip

var gap: float = 15

@onready var x_lbl: Label = $PointData/Value/x
@onready var y_lbl: Label = $PointData/Value/y
@onready var func_lbl: Label = $PointData/Value/Function
@onready var function_type_label: FunctionTypeLabel = $PointData/Value/FunctionTypeLabel

func _ready():
	hide()
	update_size()

func update_position(point_position: Vector2) -> void:
	# The panel is resized to zero whenever it hides, and the new text has not been laid out
	# yet when this runs, so get_rect() is stale on the first show. The minimum size is
	# accurate immediately, which is what the flip and the clamp below both need.
	var tooltip_size: Vector2 = get_combined_minimum_size()
	# Prefer sitting to the right of the point; flip to its left when that would run past
	# the plot's right edge.
	var offset_x: float = gap
	if offset_x + tooltip_size.x > get_parent().size.x - point_position.x:
		offset_x = -gap - tooltip_size.x
	position = _clamped_to_viewport(point_position + Vector2(offset_x, -tooltip_size.y / 2), tooltip_size)

## Keep the whole tooltip on screen. The flip above only reasons about the plot box's right
## edge, so a chart docked against a window edge could still push the tooltip out of the
## window — and a point near the top or bottom was never checked at all.
func _clamped_to_viewport(local_position: Vector2, tooltip_size: Vector2) -> Vector2:
	var origin: Vector2 = get_parent().global_position
	var limit: Vector2 = get_viewport_rect().size - tooltip_size
	var target: Vector2 = origin + local_position
	target.x = clampf(target.x, 0.0, maxf(limit.x, 0.0)) # maxf: a tooltip wider than the
	target.y = clampf(target.y, 0.0, maxf(limit.y, 0.0)) # window still pins to the corner
	return target - origin

func set_font(font: FontFile) -> void:
	theme.set("default_font", font)

func set_stylebox(stylebox: StyleBox) -> void:
	add_theme_stylebox_override("panel", stylebox)

func update_values(x: String, y: String, function: Function, color: Color) -> void:
	x_lbl.set_text("(%s)" % x)
	x_lbl.add_theme_color_override("font_color", get_theme_color("tooltip_text_color", "Chart"))
	y_lbl.set_text(y)
	y_lbl.add_theme_color_override("font_color", get_theme_color("tooltip_text_color", "Chart"))
	func_lbl.set_text(function.name)
	function_type_label.color = color
	function_type_label.marker = function.get_marker()
	function_type_label.type = function.get_type()
	function_type_label.icon = function.get_icon()
	function_type_label.indicator_visible = true
	function_type_label.add_theme_color_override("font_color", get_theme_color("tooltip_text_color", "Chart"))

func update_size():
	x_lbl.set_text("")
	y_lbl.set_text("")
	func_lbl.set_text("")
	size = Vector2.ZERO

func _on_DataTooltip_visibility_changed():
	if not visible:
		update_size()
