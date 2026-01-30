extends CharacterBody2D

@export var speed: float = 220.0
@export var energy_max: float = 100.0
@export var collect_range: float = 48.0 # max distance to collect
@export var collect_cost: float = 5.0
@export var energy_regen_per_second: float = 4.0

var energy: float
var inventory := {}

signal energy_changed(value: float)
signal inventory_changed(inventory: Dictionary)
signal notify(message: String)

func _ready() -> void:
	energy = energy_max
	add_to_group("player")

func _process(delta: float) -> void:
	# Passive energy regeneration
	if energy < energy_max:
		_change_energy(energy_regen_per_second * delta)

func _physics_process(delta: float) -> void:
	var input_vector: Vector2 = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
	velocity = input_vector * speed
	move_and_slide()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_try_collect_at(get_global_mouse_position())

func _try_collect_at(mouse_pos: Vector2) -> void:
	# Find the closest resource to the cursor among available resources
	var nodes := get_tree().get_nodes_in_group("resources")
	var target = null
	var min_dist_mouse := 1e9
	
	for resource in nodes:
		if not resource is Node2D:
			continue
		var distance_to_mouse := resource.global_position.distance_to(mouse_pos)
		if distance_to_mouse < min_dist_mouse:
			min_dist_mouse = distance_to_mouse
			target = resource

	# Improvement: Must be reasonably close to mouse cursor (32px)
	if not target or min_dist_mouse > 32.0:
		return # Clicked nothing

	# Check player proximity to the resource
	var dist_to_player := global_position.distance_to(target.global_position)
	if dist_to_player > collect_range:
		_notify("Demasiado lejos")
		return

	# Check for enough energy
	if energy < collect_cost:
		_notify("No tienes energia suficiente")
		return

	# Collect resource
	if target.has_method("collect"):
		target.collect(self)
		_change_energy(-collect_cost)

func add_to_inventory(item: String, qty: int = 1) -> void:
	if not inventory.has(item):
		inventory[item] = 0
	inventory[item] += qty
	_emit_inventory_changed()
	_notify("+%d %s" % [qty, item])

func consume_item(item_name: String, amount: int) -> void:
	if not inventory.has(item_name):
		return
	inventory[item_name] -= amount
	if inventory[item_name] <= 0:
		inventory.erase(item_name)
	_emit_inventory_changed()

func _change_energy(delta: float) -> void:
	var prev := energy
	energy = clamp(energy + delta, 0, energy_max)
	if energy != prev:
		energy_changed.emit(energy)
		if delta < 0:
			# _notify("Energia %+.0f" % [delta])
			pass

func _emit_inventory_changed() -> void:
	inventory_changed.emit(inventory.duplicate(true))

func _notify(message: String) -> void:
	notify.emit(message)
	if GameManager and GameManager.has_method("notify_ui"):
		GameManager.notify_ui(message)
		
# Persistence Help
func get_data() -> Dictionary:
	return {
		"energy": energy,
		"inventory": inventory.duplicate()
	}

func set_data(data: Dictionary) -> void:
	if data.has("energy"):
		energy = data["energy"]
		energy_changed.emit(energy)
	if data.has("inventory"):
		inventory = data["inventory"]
		_emit_inventory_changed()
