@tool
@icon("res://addons/RadialMenu/ICONS/INTERNAL/RadialMenuClassIcon.png")
extends Control
class_name RadialMenu

# ENSURE THAT RadialMenuBus.gd in Scripts is set as a Global script in Autoload
var bus_script = preload("res://addons/RadialMenu/Scripts/RadialMenuBus.gd").new()
var MenuBus = bus_script

@export_category("Customization Parameters")

@export_group("Color Palette")
@export var unselected_segment_color: Color = Color(0.173, 0.183, 0.203) :
	set(value):
		unselected_segment_color = value
		queue_redraw()

@export var hovered_segment_color: Color = Color(0.94, 0.357, 0.522) :
	set(value):
		hovered_segment_color = value
		queue_redraw()

@export var selected_segment_color: Color = Color(1.0, 0.75, 0.25, 0.961) :
	set(value):
		selected_segment_color = value
		queue_redraw()

@export var background_fill_color: Color = Color(0.098, 0.132, 0.16, 0.18) :
	set(value):
		background_fill_color = value
		queue_redraw()

@export var icon_unselected_color: Color = Color(0.941, 0.357, 0.522) :
	set(value):
		icon_unselected_color = value
		queue_redraw()

@export var icon_selected_color: Color = Color(1.0, 1.0, 1.0) :
	set(value):
		icon_selected_color = value
		queue_redraw()

@export_group("Shape Composition")
var highlight_extrusion: float = 10.0 # pixels
var highlight_extrusion_lerp_speed: float = 12.0
var _highlighted_inner_extrusion: float = 0.0
var _highlighted_outer_extrusion: float = 0.0
var _extruding_inner_index: int = -1
var _extruding_outer_index: int = -1

var context_title: String = ""
var context_description: String = ""
var context_icon: Texture2D = null

var center_position: Vector2 = Vector2(0, 0) :
	set(value):
		center_position = value
		queue_redraw()

const MIN_RING_WIDTH = 1.0
const MIN_GAP_WIDTH = 0.0
const MIN_ICON_SIZE = 1.0

enum MenuState {
	INNER_RING_UNSELECTED,
	INNER_RING_SELECTED,
	INNER_RING_IMMEDIATE_SELECTED
}

var _menu_outer_radius: float = 0.0
var _actual_outer_ring_width: float = 0.0
var _actual_inner_ring_width: float = 0.0
var _actual_ring_gap_margin: float = 0.0
var _actual_menu_padding: float = 0.0
var _actual_icon_size: float = 0.0

@export var global_scale_margin: float = 0.95

@export var outer_ring_unit: float = 16.0 :
	set(value):
		outer_ring_unit = max(MIN_RING_WIDTH, value)
		_update_derived_radii()
		queue_redraw()

@export var inner_ring_unit: float = 16.0 :
	set(value):
		inner_ring_unit = max(MIN_RING_WIDTH, value)
		_update_derived_radii()
		queue_redraw()

@export var ring_gap_unit: float = 1.25 :
	set(value):
		ring_gap_unit = max(MIN_GAP_WIDTH, value)
		_update_derived_radii()
		queue_redraw()

var menu_padding_unit: float = 25.0 :
	set(value):
		value = max(0.0, value)
		if menu_padding_unit != value:
			menu_padding_unit = value
			_update_derived_radii()
			queue_redraw()

var _outer_ring_extrusion_factor: float = 0.0
var _current_inner_ring_unit_lerped: float = 0.0

const extrusion_lerp_time_to_target: float = 0.13
const inner_ring_lerp_time_to_target: float = 0.21
const highlight_extrusion_time_to_target: float = 0.12

var num_inner_segments: int = 0
var _current_num_outer_segments: int = 0
var _segment_gap_degrees: float = 2.0
@export var segment_gap_degrees: float = 2.0:
	get: return _segment_gap_degrees
	set(value):
		_segment_gap_degrees = clamp(value, 0.0, 360.0 / max(num_inner_segments, _current_num_outer_segments, 1))
		_update_derived_radii()
		queue_redraw()

var _hovered_outer_segment_index: int = -1
var _selected_outer_segment_index: int = -1
var _hovered_inner_segment_index: int = -1
var _selected_inner_segment_index: int = -1:
	set(value):
		if _selected_inner_segment_index != -1 and value != -1 and _selected_inner_segment_index != value:
			_outer_ring_extrusion_factor = 0.0  # Snap back
		_selected_inner_segment_index = value
		queue_redraw()
var _immediate_selected_inner_segment_index: int = -1

var _current_menu_state: int = MenuState.INNER_RING_UNSELECTED
var _target_extrusion_factor: float = 0.0

@export var icon_unit: float = 30.0 :
	set(value):
		icon_unit = max(MIN_ICON_SIZE, value)
		_update_derived_radii()
		queue_redraw()

@export var icon_scale_margin: float = 0.75

@export_group("Center Info")
@export var title_font: Font = SystemFont.new()
@export var title_font_delta_scale: float = 0.4
@export var title_color: Color = Color(1, 1, 1, 1)
@export var title_vertical_offset: float = 16.0

@export var hint_font: Font = SystemFont.new()
@export var hint_font_delta_scale: float = 0.45
@export var hint_color: Color = Color(0.8, 0.9, 1, 0.9)

@export var inner_icon_size_margin: float = 30.0
@export var inner_radius_margin: float = 0.5
@export var inner_content_scale_ratio: float = 0.8
@export var inner_font_size_margin: float = 0.5

@export var center_back_margin_fraction: float = 0.6
@export var back_icon: Texture2D = preload("res://addons/RadialMenu/ICONS/INTERNAL/UI_BACK.png")

@export_group("Misc")
@export_range(0.25, 4.0, 0.01) var motion_speed_scale: float = 1.0

const ICON_PATH = "res://addons/RadialMenu/ICONS/INTERNAL/"

var menu_construct_example: Dictionary = { 
	"[EDITOR EXAMPLE CATEGORY 0]": {
		"icon": ICON_PATH+"UI_TESTICON.png",
		"description": "Check The Documentation In The RadialMenu Folder",
		"command": "example_command",
		"meta_source": null,
		"meta_input": null,
	},
	"[EDITOR EXAMPLE CATEGORY 1]": {
		"icon": ICON_PATH+"UI_TESTICON.png",
		"description": "Check The Documentation In The RadialMenu Folder",
		"command": "example_command",
		"meta_source": null,
		"meta_input": null,
		"sub_items": {
			"[EDITOR EXAMPLE ActionA]": {
				"icon": ICON_PATH+"UI_TESTICON2.png",
				"description": "Check The Documentation In The RadialMenu Folder",
				"command": "example_command",
				"meta_source": null,
				"meta_input": null,
			},
			"[EDITOR EXAMPLE ActionB]": {
				"icon": ICON_PATH+"UI_TESTICON2.png",
				"description": "Check The Documentation In The RadialMenu Folder",
				"command": "example_command",
				"meta_source": null,
				"meta_input": null,
			},
			"[EDITOR EXAMPLE ActionC]": {
				"icon": ICON_PATH+"UI_TESTICON2.png",
				"description": "Check The Documentation In The RadialMenu Folder",
				"command": "example_command",
				"meta_source": null,
				"meta_input": null,
			}
		}
	},
	"[EDITOR EXAMPLE CATEGORY 2]": {
		"icon": ICON_PATH+"UI_TESTICON.png",
		"description": "Check The Documentation In The RadialMenu Folder",
		"command": "example_command",
		"meta_source": null,
		"meta_input": null,
		"sub_items": {
			"[EDITOR EXAMPLE ActionD]": {
				"icon": ICON_PATH+"UI_TESTICON2.png",
				"description": "Check The Documentation In The RadialMenu Folder",
				"command": "example_command",
				"meta_source": null,
				"meta_input": null,
			},
			"[EDITOR EXAMPLE ActionE]": {
				"icon": ICON_PATH+"UI_TESTICON2.png",
				"description": "Check The Documentation In The RadialMenu Folder",
				"command": "example_command",
				"meta_source": null,
				"meta_input": null,
			},
		}
	},
}

var menu_construct: Dictionary = {}
var _loaded_icon_textures: Dictionary = {}
var _inner_segment_keys: Array = []
var _outer_segment_keys: Array = []
var _outer_ring_inner_edge: float = 0.0
var _inner_ring_outer_edge: float = 0.0
var _inner_ring_inner_edge: float = 0.0
var _current_outer_ring_outer_edge: float = 0.0

var scale_lerp := 1.0
const SCALE_LERP_START := 3.0
const SCALE_LERP_END := 1.0
const SCALE_LERP_TIME_TO_TARGET := 0.18

var alpha_lerp := 1.0
const ALPHA_LERP_START := 0.0
const ALPHA_LERP_END := 1.0
const ALPHA_LERP_TIME_TO_TARGET := 0.18

func _reset_menu_state():
	_current_menu_state = MenuState.INNER_RING_UNSELECTED
	_selected_inner_segment_index = -1
	_immediate_selected_inner_segment_index = -1
	_selected_outer_segment_index = -1
	_hovered_inner_segment_index = -1
	_hovered_outer_segment_index = -1
	_extruding_inner_index = -1
	_extruding_outer_index = -1
	_highlighted_inner_extrusion = 0.0
	_highlighted_outer_extrusion = 0.0
	_outer_ring_extrusion_factor = 0.0
	_current_inner_ring_unit_lerped = inner_ring_unit
	context_title = ""
	context_description = ""
	context_icon = null
	scale_lerp = SCALE_LERP_START
	alpha_lerp = ALPHA_LERP_START
	queue_redraw()

func _get_stable_inner_content_radius() -> float:
	var viewport_size = get_viewport_rect().size
	var global_scale_factor = (
		min(viewport_size.x, viewport_size.y)
		/ ((outer_ring_unit + ring_gap_unit + inner_ring_unit + menu_padding_unit) * 2.0)
		* global_scale_margin * scale_lerp
	)
	var actual_outer_ring_width = outer_ring_unit * global_scale_factor
	var actual_inner_ring_width = inner_ring_unit * global_scale_factor
	var actual_ring_gap_margin = ring_gap_unit * global_scale_factor
	var actual_menu_padding = menu_padding_unit * global_scale_factor
	var menu_outer_radius = (actual_outer_ring_width + actual_ring_gap_margin + actual_inner_ring_width) + actual_menu_padding
	var outer_ring_inner_edge = menu_outer_radius - actual_outer_ring_width
	var inner_ring_outer_edge = outer_ring_inner_edge - actual_ring_gap_margin
	var inner_ring_inner_edge = inner_ring_outer_edge - actual_inner_ring_width
	return max(0.0, inner_ring_inner_edge)

func _update_derived_radii() -> void:
	var viewport_size = get_viewport_rect().size
	if viewport_size.x <= 0 or viewport_size.y <= 0:
		_actual_outer_ring_width = MIN_RING_WIDTH
		_actual_inner_ring_width = MIN_RING_WIDTH
		_actual_ring_gap_margin = MIN_GAP_WIDTH
		_actual_menu_padding = 0.0
		_menu_outer_radius = MIN_RING_WIDTH
		_outer_ring_inner_edge = MIN_RING_WIDTH
		_inner_ring_outer_edge = MIN_RING_WIDTH
		_inner_ring_inner_edge = MIN_RING_WIDTH
		_current_outer_ring_outer_edge = MIN_RING_WIDTH
		_actual_icon_size = MIN_ICON_SIZE
		return

	var target_inner_ring_unit = inner_ring_unit
	if _current_menu_state == MenuState.INNER_RING_SELECTED:
		target_inner_ring_unit = inner_ring_unit * 0.5

	target_inner_ring_unit = max(MIN_RING_WIDTH, target_inner_ring_unit)

	if _current_inner_ring_unit_lerped == 0.0:
		_current_inner_ring_unit_lerped = target_inner_ring_unit

	var total_reference_radial_extent = outer_ring_unit + ring_gap_unit + _current_inner_ring_unit_lerped
	var total_reference_diameter = (total_reference_radial_extent + menu_padding_unit) * 2.0

	if total_reference_diameter <= 0:
		_actual_outer_ring_width = MIN_RING_WIDTH
		_actual_inner_ring_width = MIN_RING_WIDTH
		_actual_ring_gap_margin = MIN_GAP_WIDTH
		_actual_menu_padding = 0.0
		_menu_outer_radius = MIN_RING_WIDTH
		_outer_ring_inner_edge = MIN_RING_WIDTH
		_inner_ring_outer_edge = MIN_RING_WIDTH
		_inner_ring_inner_edge = MIN_RING_WIDTH
		_current_outer_ring_outer_edge = MIN_RING_WIDTH
		_actual_icon_size = MIN_ICON_SIZE
		return

	var actual_available_diameter = min(viewport_size.x, viewport_size.y)
	var global_scale_factor = actual_available_diameter / total_reference_diameter * global_scale_margin * scale_lerp

	_actual_outer_ring_width = outer_ring_unit * global_scale_factor
	_actual_inner_ring_width = _current_inner_ring_unit_lerped * global_scale_factor
	_actual_ring_gap_margin = ring_gap_unit * global_scale_factor
	_actual_menu_padding = menu_padding_unit * global_scale_factor
	_actual_icon_size = icon_unit * global_scale_factor

	_actual_outer_ring_width = max(MIN_RING_WIDTH, _actual_outer_ring_width)
	_actual_inner_ring_width = max(MIN_RING_WIDTH, _actual_inner_ring_width)
	_actual_ring_gap_margin = max(MIN_GAP_WIDTH, _actual_ring_gap_margin)
	_actual_menu_padding = max(0.0, _actual_menu_padding)
	_actual_icon_size = max(MIN_ICON_SIZE, _actual_icon_size)

	_menu_outer_radius = (_actual_outer_ring_width + _actual_ring_gap_margin + _actual_inner_ring_width) + _actual_menu_padding
	_menu_outer_radius = max(0.0, _menu_outer_radius)

	_outer_ring_inner_edge = _menu_outer_radius - _actual_outer_ring_width
	_outer_ring_inner_edge = max(0.0, _outer_ring_inner_edge)

	_inner_ring_outer_edge = _outer_ring_inner_edge - _actual_ring_gap_margin
	_inner_ring_outer_edge = max(0.0, _inner_ring_outer_edge)

	_inner_ring_inner_edge = _inner_ring_outer_edge - _actual_inner_ring_width
	_inner_ring_inner_edge = max(0.0, _inner_ring_inner_edge)

	_current_outer_ring_outer_edge = lerp(_outer_ring_inner_edge, _menu_outer_radius, _outer_ring_extrusion_factor)
	_current_outer_ring_outer_edge = max(_outer_ring_inner_edge, _current_outer_ring_outer_edge)

	_inner_ring_inner_edge = min(_inner_ring_inner_edge, _inner_ring_outer_edge)
	_outer_ring_inner_edge = min(_outer_ring_inner_edge, _current_outer_ring_outer_edge)

	queue_redraw()

func update_context_elements():
	if _current_menu_state == MenuState.INNER_RING_UNSELECTED:
		if _hovered_inner_segment_index >= 0:
			var key = _get_inner_segment_key(_hovered_inner_segment_index)
			context_title = key
			context_description = menu_construct[key].get("description", "")
			context_icon = _loaded_icon_textures.get(menu_construct[key].get("icon", ""), null)
		else:
			context_title = ""
			context_description = ""
			context_icon = null
	elif _current_menu_state == MenuState.INNER_RING_SELECTED:
		var mouse_local_position = get_local_mouse_position()
		var mouse_vector = mouse_local_position - center_position
		var mouse_distance = mouse_vector.length()
		var center_back_radius = _inner_ring_inner_edge * center_back_margin_fraction
		var is_mouse_in_center_back = mouse_distance <= center_back_radius
		if _hovered_outer_segment_index >= 0:
			var cat_key = _get_inner_segment_key(_selected_inner_segment_index)
			var out_key = _get_outer_segment_key(_hovered_outer_segment_index)
			context_title = out_key
			context_description = menu_construct[cat_key]["sub_items"][out_key].get("description", "")
			context_icon = _loaded_icon_textures.get(menu_construct[cat_key]["sub_items"][out_key].get("icon", ""), null)
		elif is_mouse_in_center_back:
			context_title = "Back"
			context_description = "Click here to return."
			context_icon = back_icon
		else:
			var key = _get_inner_segment_key(_selected_inner_segment_index)
			context_title = key
			context_description = menu_construct[key].get("description", "")
			context_icon = _loaded_icon_textures.get(menu_construct[key].get("icon", ""), null)

func draw_filled_circle(center: Vector2, radius: float, color: Color, num_segments: int = 64) -> void:
	draw_circle(center, radius, color)

func draw_radial_segment(center: Vector2, outer_rad: float, inner_rad: float, start_angle_rad: float, end_angle_rad: float, fill_color: Color, num_arc_segments: int = 32) -> void:
	var points: PackedVector2Array = []
	var colors: PackedColorArray = PackedColorArray()
	var angle_step_outer = (end_angle_rad - start_angle_rad) / num_arc_segments
	for i in range(num_arc_segments + 1):
		var angle = start_angle_rad + angle_step_outer * i
		points.append(center + Vector2(outer_rad * cos(angle), outer_rad * sin(angle)))
		colors.append(fill_color)
	var angle_step_inner = (end_angle_rad - start_angle_rad) / num_arc_segments
	for i in range(num_arc_segments, -1, -1):
		var angle = start_angle_rad + angle_step_inner * i
		points.append(center + Vector2(inner_rad * cos(angle), inner_rad * sin(angle)))
		colors.append(fill_color)
	draw_polygon(points, colors)

func get_segment_start_angle_rad(num_segments_in_ring: int) -> float:
	if num_segments_in_ring == 0:
		return 0.0
	var total_arc_angle = TAU / float(num_segments_in_ring)
	var segment_0_center_angle = PI / 2
	var segment_0_start_angle_ccw = segment_0_center_angle - (total_arc_angle / 2.0)
	return segment_0_start_angle_ccw

func _draw() -> void:
	draw_filled_circle(center_position, _current_outer_ring_outer_edge + _actual_ring_gap_margin, background_fill_color)
	var segment_gap_rad = deg_to_rad(segment_gap_degrees)

	var total_outer_segment_arc_angle = 0.0
	if _current_num_outer_segments > 0:
		total_outer_segment_arc_angle = TAU / float(_current_num_outer_segments)
	var outer_base_start_angle_ccw = get_segment_start_angle_rad(_current_num_outer_segments)
	if _current_outer_ring_outer_edge > _outer_ring_inner_edge + 0.1 and _current_num_outer_segments > 0:
		for i in range(_current_num_outer_segments):
			var segment_start_angle = outer_base_start_angle_ccw + i * total_outer_segment_arc_angle
			var segment_end_angle = segment_start_angle + total_outer_segment_arc_angle
			var draw_start_angle = segment_start_angle + segment_gap_rad / 2.0
			var draw_end_angle = segment_end_angle - segment_gap_rad / 2.0
			var current_segment_color = unselected_segment_color
			var extrude = 0.0
			if _current_menu_state == MenuState.INNER_RING_SELECTED and i == _extruding_outer_index and _highlighted_outer_extrusion > 0.0:
				current_segment_color = hovered_segment_color
				extrude = _highlighted_outer_extrusion
			if draw_start_angle < draw_end_angle:
				draw_radial_segment(center_position, _current_outer_ring_outer_edge + extrude, _outer_ring_inner_edge, draw_start_angle, draw_end_angle, current_segment_color)
			var outer_item_key = _get_outer_segment_key(i)
			var full_icon_path = ""
			if outer_item_key != "":
				var category_data = menu_construct.get(_get_inner_segment_key(_selected_inner_segment_index), {})
				var sub_items = category_data.get("sub_items", {})
				var item_data = sub_items.get(outer_item_key, {})
				full_icon_path = item_data.get("icon", "")
			if full_icon_path != "" and _loaded_icon_textures.has(full_icon_path):
				var icon_texture = _loaded_icon_textures[full_icon_path]
				var mid_angle = (draw_start_angle + draw_end_angle) / 2.0
				var mid_radius = (_outer_ring_inner_edge + _current_outer_ring_outer_edge + extrude) / 2.0
				var max_angular_icon_size = mid_radius * (draw_end_angle - draw_start_angle)
				var max_radial_icon_size = _actual_outer_ring_width + extrude
				var max_possible_icon_size_for_segment = min(max_angular_icon_size, max_radial_icon_size)
				var final_icon_draw_size = min(_actual_icon_size, max_possible_icon_size_for_segment) * icon_scale_margin
				var icon_center_pos_relative_to_menu_center = Vector2(mid_radius * cos(mid_angle), mid_radius * sin(mid_angle))
				var icon_top_left_pos = center_position + icon_center_pos_relative_to_menu_center - Vector2(final_icon_draw_size / 2.0, final_icon_draw_size / 2.0)
				var modulate_color = icon_unselected_color
				if _current_menu_state == MenuState.INNER_RING_SELECTED and i == _extruding_outer_index and _highlighted_outer_extrusion > 0.0:
					modulate_color = icon_selected_color
				draw_texture_rect(icon_texture, Rect2(icon_top_left_pos, Vector2(final_icon_draw_size, final_icon_draw_size)), false, modulate_color)

	var total_inner_segment_arc_angle = 0.0
	if num_inner_segments > 0:
		total_inner_segment_arc_angle = TAU / float(num_inner_segments)
	var inner_base_start_angle_ccw = get_segment_start_angle_rad(num_inner_segments)
	for i in range(num_inner_segments):
		var segment_start_angle = inner_base_start_angle_ccw + i * total_inner_segment_arc_angle
		var segment_end_angle = segment_start_angle + total_inner_segment_arc_angle
		var draw_start_angle = segment_start_angle + segment_gap_rad / 2.0
		var draw_end_angle = segment_end_angle - segment_gap_rad / 2.0
		var current_segment_color = unselected_segment_color
		var extrude = 0.0
		if i == _immediate_selected_inner_segment_index:
			current_segment_color = selected_segment_color
		elif i == _selected_inner_segment_index:
			current_segment_color = selected_segment_color
		elif _current_menu_state == MenuState.INNER_RING_UNSELECTED and i == _extruding_inner_index and _highlighted_inner_extrusion > 0.0:
			current_segment_color = hovered_segment_color
			extrude = _highlighted_inner_extrusion
		if _inner_ring_inner_edge < _inner_ring_outer_edge and draw_start_angle < draw_end_angle:
			draw_radial_segment(center_position, _inner_ring_outer_edge + extrude, _inner_ring_inner_edge, draw_start_angle, draw_end_angle, current_segment_color)
		var inner_item_key = _get_inner_segment_key(i)
		var full_icon_path = ""
		if inner_item_key != "":
			var item_data = menu_construct.get(inner_item_key, {})
			full_icon_path = item_data.get("icon", "")
		if full_icon_path != "" and _loaded_icon_textures.has(full_icon_path):
			var icon_texture = _loaded_icon_textures[full_icon_path]
			var mid_angle = (draw_start_angle + draw_end_angle) / 2.0
			var mid_radius = (_inner_ring_inner_edge + _inner_ring_outer_edge + extrude) / 2.0
			var max_angular_icon_size = mid_radius * (draw_end_angle - draw_start_angle)
			var max_radial_icon_size = _actual_inner_ring_width + extrude
			var max_possible_icon_size_for_segment = min(max_angular_icon_size, max_radial_icon_size)
			var final_icon_draw_size = min(_actual_icon_size, max_possible_icon_size_for_segment) * icon_scale_margin
			var icon_center_pos_relative_to_menu_center = Vector2(mid_radius * cos(mid_angle), mid_radius * sin(mid_angle))
			var icon_top_left_pos = center_position + icon_center_pos_relative_to_menu_center - Vector2(final_icon_draw_size / 2.0, final_icon_draw_size / 2.0)
			var modulate_color = icon_unselected_color
			if i == _immediate_selected_inner_segment_index or i == _selected_inner_segment_index or (_current_menu_state == MenuState.INNER_RING_UNSELECTED and i == _extruding_inner_index and _highlighted_inner_extrusion > 0.0):
				modulate_color = icon_selected_color
			draw_texture_rect(icon_texture, Rect2(icon_top_left_pos, Vector2(final_icon_draw_size, final_icon_draw_size)), false, modulate_color)

	_draw_inner_elements()

func _draw_inner_elements():
	var effective_scale = clamp(inner_content_scale_ratio, 0.1, 1.0)
	var stable_inner_radius = _get_stable_inner_content_radius()
	var radius = (stable_inner_radius - inner_radius_margin) * effective_scale
	var text_radius = max(0.0, radius - inner_font_size_margin)
	var box_width = text_radius * 2.0
	var title_font_size = 0
	var title_lines: Array = []
	if context_title != "" and title_font:
		title_font_size = _fit_text_font_size(context_title, title_font, box_width, int(12 * title_font_delta_scale * effective_scale), int(48 * title_font_delta_scale * effective_scale))
		title_lines = _wrap_text(context_title, title_font, box_width, title_font_size)
		var title_y = center_position.y - text_radius + title_vertical_offset
		var y = title_y + title_font.get_ascent(title_font_size)
		for line in title_lines:
			draw_string(title_font, Vector2(center_position.x - box_width/2, y), line, HORIZONTAL_ALIGNMENT_CENTER, box_width, title_font_size, title_color)
			y += title_font.get_height(title_font_size)
	var icon_max_size = (radius - inner_icon_size_margin) * effective_scale
	if context_icon:
		var icon_size = Vector2(icon_max_size, icon_max_size)
		var icon_y = center_position.y + radius - icon_size.y - inner_radius_margin
		var icon_pos = Vector2(center_position.x - icon_size.x/2, icon_y)
		draw_texture_rect(context_icon, Rect2(icon_pos, icon_size), false)
	if context_description != "" and hint_font:
		var hint_font_size = _fit_text_font_size(context_description, hint_font, box_width, int(9 * hint_font_delta_scale * effective_scale), int(32 * hint_font_delta_scale * effective_scale))
		var hint_lines = _wrap_text(context_description, hint_font, box_width, hint_font_size)
		var hint_height = hint_lines.size() * hint_font.get_height(hint_font_size)
		var top_y = center_position.y - text_radius + title_vertical_offset
		if title_lines.size() > 0:
			top_y += title_font.get_height(title_font_size) * title_lines.size()
		var bottom_y = center_position.y + radius - inner_radius_margin
		if context_icon:
			bottom_y -= icon_max_size
		var available_mid_height = (bottom_y - top_y)
		var hint_y = top_y + available_mid_height/2 - hint_height/2
		var y = hint_y + hint_font.get_ascent(hint_font_size)
		for line in hint_lines:
			draw_string(hint_font, Vector2(center_position.x - box_width/2, y), line, HORIZONTAL_ALIGNMENT_CENTER, box_width, hint_font_size, hint_color)
			y += hint_font.get_height(hint_font_size)

func _fit_text_font_size(text: String, font: Font, max_width: float, min_size: int, max_size: int) -> int:
	for font_size in range(max_size, min_size - 1, -1):
		var lines = _wrap_text(text, font, max_width, font_size)
		var all_fit = true
		for line in lines:
			if font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > max_width:
				all_fit = false
				break
		if all_fit:
			return font_size
	return min_size

func _wrap_text(text: String, font: Font, max_width: float, font_size: int) -> Array:
	var lines = []
	for paragraph in text.split("\n"):
		var words = paragraph.split(" ")
		var current_line = ""
		for word in words:
			var test_line = current_line
			if test_line != "":
				test_line += " "
			test_line += word
			if font.get_string_size(test_line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x <= max_width:
				current_line = test_line
			else:
				if font.get_string_size(word, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > max_width:
					if current_line != "":
						lines.append(current_line)
						current_line = ""
					var split_word = ""
					for char in word:
						var test_split_word = split_word + char
						if font.get_string_size(test_split_word, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x <= max_width:
							split_word = test_split_word
						else:
							if split_word != "":
								lines.append(split_word)
							split_word = char
					if split_word != "":
						current_line = split_word
				else:
					if current_line != "":
						lines.append(current_line)
					current_line = word
		if current_line != "":
			lines.append(current_line)
	return lines

func _get_inner_segment_key(index: int) -> String:
	if index >= 0 and index < _inner_segment_keys.size():
		return _inner_segment_keys[index]
	return ""

func _get_outer_segment_key(index: int) -> String:
	if index >= 0 and index < _outer_segment_keys.size():
		return _outer_segment_keys[index]
	return ""

func _setup_menu_from_construct() -> void:
	_inner_segment_keys = menu_construct.keys()
	num_inner_segments = _inner_segment_keys.size()
	_loaded_icon_textures.clear()
	for category_key in _inner_segment_keys:
		var category_data = menu_construct[category_key]
		if category_data.has("icon"):
			var full_icon_path = category_data["icon"]
			if full_icon_path != "" and not _loaded_icon_textures.has(full_icon_path):
				var texture = load(full_icon_path)
				if texture:
					_loaded_icon_textures[full_icon_path] = texture
		if category_data.has("sub_items"):
			for sub_item_key in category_data["sub_items"].keys():
				var sub_item_data = category_data["sub_items"][sub_item_key]
				if sub_item_data.has("icon"):
					var full_icon_path = sub_item_data["icon"]
					if full_icon_path != "" and not _loaded_icon_textures.has(full_icon_path):
						var texture = load(full_icon_path)
						if texture:
							_loaded_icon_textures[full_icon_path] = texture
	_update_outer_segment_keys()
	_update_derived_radii()
	queue_redraw()

func _update_outer_segment_keys() -> void:
	_outer_segment_keys.clear()
	if _selected_inner_segment_index != -1 and _selected_inner_segment_index < _inner_segment_keys.size():
		var selected_category_key = _inner_segment_keys[_selected_inner_segment_index]
		var category_data = menu_construct.get(selected_category_key, {})
		if category_data.has("sub_items"):
			_outer_segment_keys = category_data["sub_items"].keys()
	_current_num_outer_segments = _outer_segment_keys.size()

func set_menu_construct(construct: Dictionary) -> void:
	menu_construct = construct
	_setup_menu_from_construct()
	queue_redraw()
	_reset_menu_state()

func set_menu_construct_editor_example():
	menu_construct = menu_construct_example

func _ready() -> void:
	set_menu_construct(MenuBus.menu_construct_test)
	prep_state()

func start_menubus():
	MenuBus.set_process(true)
	pass

func prep_state():
	if Engine.is_editor_hint():
		set_menu_construct_editor_example()
	start_menubus()
	center_position = size / 2.0
	_setup_menu_from_construct()
	queue_redraw()
	set_mouse_filter(MOUSE_FILTER_STOP)
	set_process(true)

func _notification(what):
	if what == NOTIFICATION_ENTER_TREE:
		prep_state()
	if what == NOTIFICATION_RESIZED:
		center_position = size / 2.0
		_update_derived_radii()
		queue_redraw()
	elif what == NOTIFICATION_VISIBILITY_CHANGED:
		if self.visible:
			scale_lerp = SCALE_LERP_START
			alpha_lerp = ALPHA_LERP_START
		else:
			_reset_menu_state()
			queue_redraw()

func exp_lerp(current, target, delta, time_to_target):
	var scl = max(0.001, Engine.time_scale)
	var t = 1.0 - pow(0.0001, delta / (time_to_target * scl))
	var clamped_motion_speed_scale = clamp(motion_speed_scale,0.25,4.0)
	return lerp(current, target, t * 0.375*clamped_motion_speed_scale)

func _process(delta: float) -> void:
	if not is_visible_in_tree():
		return
	
	if abs(scale_lerp - SCALE_LERP_END) > 0.01:
		scale_lerp = exp_lerp(scale_lerp, SCALE_LERP_END, delta, SCALE_LERP_TIME_TO_TARGET)
		if abs(scale_lerp - SCALE_LERP_END) < 0.01:
			scale_lerp = SCALE_LERP_END
		queue_redraw()
	else:
		scale_lerp = SCALE_LERP_END

	if abs(alpha_lerp - ALPHA_LERP_END) > 0.01:
		alpha_lerp = exp_lerp(alpha_lerp, ALPHA_LERP_END, delta, ALPHA_LERP_TIME_TO_TARGET)
		if abs(alpha_lerp - ALPHA_LERP_END) < 0.01:
			alpha_lerp = ALPHA_LERP_END
		queue_redraw()
	else:
		alpha_lerp = ALPHA_LERP_END

	self.modulate.a = alpha_lerp

	var target_inner_ring_unit = inner_ring_unit
	if _immediate_selected_inner_segment_index != -1:
		_current_menu_state = MenuState.INNER_RING_IMMEDIATE_SELECTED
		_target_extrusion_factor = 1.0
	elif _selected_inner_segment_index != -1:
		_current_menu_state = MenuState.INNER_RING_SELECTED
		_target_extrusion_factor = 1.0
		target_inner_ring_unit = inner_ring_unit * 0.5
	else:
		_current_menu_state = MenuState.INNER_RING_UNSELECTED
		_target_extrusion_factor = 0.0

	if abs(_current_inner_ring_unit_lerped - target_inner_ring_unit) > 0.01:
		_current_inner_ring_unit_lerped = exp_lerp(_current_inner_ring_unit_lerped, target_inner_ring_unit, delta, inner_ring_lerp_time_to_target)
		if abs(_current_inner_ring_unit_lerped - target_inner_ring_unit) < 0.01:
			_current_inner_ring_unit_lerped = target_inner_ring_unit
	else:
		_current_inner_ring_unit_lerped = target_inner_ring_unit

	_update_outer_segment_keys()
	_update_derived_radii()

	if abs(_outer_ring_extrusion_factor - _target_extrusion_factor) > 0.01:
		_outer_ring_extrusion_factor = exp_lerp(_outer_ring_extrusion_factor, _target_extrusion_factor, delta, extrusion_lerp_time_to_target)
		if abs(_outer_ring_extrusion_factor - _target_extrusion_factor) < 0.01:
			_outer_ring_extrusion_factor = _target_extrusion_factor
	else:
		_outer_ring_extrusion_factor = _target_extrusion_factor

	if _current_menu_state == MenuState.INNER_RING_UNSELECTED:
		if _hovered_inner_segment_index != _extruding_inner_index:
			_highlighted_inner_extrusion = 0.0
			_extruding_inner_index = _hovered_inner_segment_index
	if _current_menu_state == MenuState.INNER_RING_SELECTED:
		if _hovered_outer_segment_index != _extruding_outer_index:
			_highlighted_outer_extrusion = 0.0
			_extruding_outer_index = _hovered_outer_segment_index

	var target_inner_extrude = 0.0
	var target_outer_extrude = 0.0
	if _current_menu_state == MenuState.INNER_RING_UNSELECTED and _hovered_inner_segment_index != -1:
		target_inner_extrude = highlight_extrusion
	if _current_menu_state == MenuState.INNER_RING_SELECTED and _hovered_outer_segment_index != -1:
		target_outer_extrude = highlight_extrusion

	if abs(_highlighted_inner_extrusion - target_inner_extrude) > 0.01:
		_highlighted_inner_extrusion = exp_lerp(_highlighted_inner_extrusion, target_inner_extrude, delta, highlight_extrusion_time_to_target)
		if abs(_highlighted_inner_extrusion - target_inner_extrude) < 0.01:
			_highlighted_inner_extrusion = target_inner_extrude
	else:
		_highlighted_inner_extrusion = target_inner_extrude

	if abs(_highlighted_outer_extrusion - target_outer_extrude) > 0.01:
		_highlighted_outer_extrusion = exp_lerp(_highlighted_outer_extrusion, target_outer_extrude, delta, highlight_extrusion_time_to_target)
		if abs(_highlighted_outer_extrusion - target_outer_extrude) < 0.01:
			_highlighted_outer_extrusion = target_outer_extrude
	else:
		_highlighted_outer_extrusion = target_outer_extrude

	var mouse_local_position = get_local_mouse_position()
	var mouse_vector = mouse_local_position - center_position
	var mouse_distance = mouse_vector.length()
	var center_back_radius = _inner_ring_inner_edge * center_back_margin_fraction
	var hover_updated = false

	var mouse_angle_rad = mouse_vector.angle()
	var mouse_angle_normalized_0_to_TAU = fmod(mouse_angle_rad + TAU, TAU)

	if _current_menu_state == MenuState.INNER_RING_UNSELECTED:
		if mouse_distance >= center_back_radius:
			var total_inner_segment_arc_angle = 0.0
			if num_inner_segments > 0:
				total_inner_segment_arc_angle = TAU / float(num_inner_segments)
			var inner_base_start_angle_ccw = get_segment_start_angle_rad(num_inner_segments)
			var normalized_inner_base_start_angle_ccw = fmod(inner_base_start_angle_ccw + TAU, TAU)
			var angle_relative_to_ring_start = fmod(mouse_angle_normalized_0_to_TAU - normalized_inner_base_start_angle_ccw + TAU, TAU)
			var potential_hover_index = -1
			if total_inner_segment_arc_angle > 0:
				potential_hover_index = floor(angle_relative_to_ring_start / total_inner_segment_arc_angle)
			if potential_hover_index >= 0 and potential_hover_index < num_inner_segments:
				_hovered_inner_segment_index = potential_hover_index
				_hovered_outer_segment_index = -1
				hover_updated = true
			else:
				_hovered_inner_segment_index = -1
				_hovered_outer_segment_index = -1
				hover_updated = true
		else:
			_hovered_inner_segment_index = -1
			_hovered_outer_segment_index = -1
			hover_updated = true

	elif _current_menu_state == MenuState.INNER_RING_SELECTED:
		if mouse_distance <= center_back_radius:
			_hovered_inner_segment_index = -1
			_hovered_outer_segment_index = -1
			hover_updated = true
		elif mouse_distance > _inner_ring_outer_edge:
			var total_outer_segment_arc_angle = 0.0
			if _current_num_outer_segments > 0:
				total_outer_segment_arc_angle = TAU / float(_current_num_outer_segments)
			var outer_base_start_angle_ccw = get_segment_start_angle_rad(_current_num_outer_segments)
			var normalized_outer_base_start_angle_ccw = fmod(outer_base_start_angle_ccw + TAU, TAU)
			var angle_relative_to_ring_start = fmod(mouse_angle_normalized_0_to_TAU - normalized_outer_base_start_angle_ccw + TAU, TAU)
			var potential_hover_index = -1
			if total_outer_segment_arc_angle > 0:
				potential_hover_index = floor(angle_relative_to_ring_start / total_outer_segment_arc_angle)
			if potential_hover_index >= 0 and potential_hover_index < _current_num_outer_segments:
				_hovered_outer_segment_index = potential_hover_index
				_hovered_inner_segment_index = -1
				hover_updated = true
			else:
				_hovered_outer_segment_index = -1
				_hovered_inner_segment_index = -1
				hover_updated = true
		else:
			var total_inner_segment_arc_angle = 0.0
			if num_inner_segments > 0:
				total_inner_segment_arc_angle = TAU / float(num_inner_segments)
			var inner_base_start_angle_ccw = get_segment_start_angle_rad(num_inner_segments)
			var normalized_inner_base_start_angle_ccw = fmod(inner_base_start_angle_ccw + TAU, TAU)
			var angle_relative_to_ring_start = fmod(mouse_angle_normalized_0_to_TAU - normalized_inner_base_start_angle_ccw + TAU, TAU)
			var potential_hover_index = -1
			if total_inner_segment_arc_angle > 0:
				potential_hover_index = floor(angle_relative_to_ring_start / total_inner_segment_arc_angle)
			if potential_hover_index >= 0 and potential_hover_index < num_inner_segments:
				_hovered_inner_segment_index = potential_hover_index
				_hovered_outer_segment_index = -1
				hover_updated = true
			else:
				_hovered_inner_segment_index = -1
				_hovered_outer_segment_index = -1
				hover_updated = true
	else:
		_hovered_inner_segment_index = -1
		_hovered_outer_segment_index = -1
		hover_updated = true

	if hover_updated:
		update_context_elements()

	var is_mouse_in_center_back = mouse_distance <= center_back_radius

	if Input.is_action_just_pressed("ui_accept"):
		_immediate_selected_inner_segment_index = -1

		if _current_menu_state == MenuState.INNER_RING_UNSELECTED:
			if _hovered_inner_segment_index != -1:
				var inner_item_key = _get_inner_segment_key(_hovered_inner_segment_index)
				var item_data = menu_construct.get(inner_item_key, {})
				if item_data.has("sub_items") and item_data["sub_items"].size() > 0:
					_selected_inner_segment_index = _hovered_inner_segment_index
				elif item_data.has("command") and item_data["command"] != "":
					var meta_source = null
					var meta_input = null
					if item_data.has("meta_source") and item_data["meta_source"] != null:
						meta_source = item_data["meta_source"]
					if item_data.has("meta_input") and item_data["meta_input"] != null:
						meta_input = item_data["meta_input"]
					_execute_command(
						item_data["command"],
						{"ring": "inner", "key": inner_item_key, "index": _hovered_inner_segment_index},
						meta_source,
						meta_input
					)
					_selected_inner_segment_index = -1
					_selected_outer_segment_index = -1
					_update_outer_segment_keys()
					queue_redraw()
				else:
					_selected_inner_segment_index = -1
					_selected_outer_segment_index = -1
					_update_outer_segment_keys()
					queue_redraw()
			else:
				_selected_inner_segment_index = -1
				_selected_outer_segment_index = -1
				_update_outer_segment_keys()
				queue_redraw()
		elif _current_menu_state == MenuState.INNER_RING_SELECTED:
			if _hovered_inner_segment_index != -1:
				var inner_item_key = _get_inner_segment_key(_hovered_inner_segment_index)
				var item_data = menu_construct.get(inner_item_key, {})
				if ((not item_data.has("sub_items") or item_data["sub_items"].size() == 0) and item_data.has("command") and item_data["command"] != ""):
					var meta_source = null
					var meta_input = null
					if item_data.has("meta_source") and item_data["meta_source"] != null:
						meta_source = item_data["meta_source"]
					if item_data.has("meta_input") and item_data["meta_input"] != null:
						meta_input = item_data["meta_input"]
					_execute_command(
						item_data["command"],
						{"ring": "inner", "key": inner_item_key, "index": _hovered_inner_segment_index},
						meta_source,
						meta_input
					)
					_selected_inner_segment_index = -1
					_selected_outer_segment_index = -1
					_update_outer_segment_keys()
					queue_redraw()
				elif _hovered_inner_segment_index == _selected_inner_segment_index:
					_selected_inner_segment_index = -1
					_selected_outer_segment_index = -1
					_update_outer_segment_keys()
					queue_redraw()
				else:
					_selected_inner_segment_index = _hovered_inner_segment_index
					_selected_outer_segment_index = -1
					_update_outer_segment_keys()
					queue_redraw()
			elif _hovered_outer_segment_index != -1:
				_selected_outer_segment_index = _hovered_outer_segment_index
				var outer_item_key = _get_outer_segment_key(_selected_outer_segment_index)
				var category_data = menu_construct.get(_get_inner_segment_key(_selected_inner_segment_index), {})
				var sub_items = category_data.get("sub_items", {})
				var item_data = sub_items.get(outer_item_key, {})
				var command_method_name = item_data.get("command", "")
				if command_method_name != "":
					var meta_source = null
					var meta_input = null
					if item_data.has("meta_source") and item_data["meta_source"] != null:
						meta_source = item_data["meta_source"]
					if item_data.has("meta_input") and item_data["meta_input"] != null:
						meta_input = item_data["meta_input"]
					_execute_command(
						command_method_name,
						{
							"ring": "outer",
							"category_key": _get_inner_segment_key(_selected_inner_segment_index),
							"key": outer_item_key,
							"index": _selected_outer_segment_index
						},
						meta_source,
						meta_input
					)
				_update_outer_segment_keys()
				queue_redraw()
			elif is_mouse_in_center_back:
				_selected_inner_segment_index = -1
				_selected_outer_segment_index = -1
				_update_outer_segment_keys()
				queue_redraw()

func _execute_command(method_name: String, data: Dictionary = {}, meta_source = null, meta_input = null) -> void:
	var global_commands = MenuBus
	if not (global_commands and global_commands.has_method(method_name)):
		return
	# Only two valid cases
	if meta_source != null and meta_input != null:
		global_commands.call(method_name, meta_source, meta_input)
	elif meta_source == null and meta_input == null:
		global_commands.call(method_name)
	else:
		push_warning("Not calling %s: meta_source and meta_input must both be null or both be filled (meta_source: %s, meta_input: %s)" % [method_name, str(meta_source), str(meta_input)])
