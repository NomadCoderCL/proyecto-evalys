extends CanvasLayer

@onready var energy_bar = $Control/EnergyBar
@onready var inventory_grid = $Control/InventoryGrid
@onready var slot_template = $Control/ItemSlotTemplate
@onready var notifications = $Control/Notifications
@onready var audio = $AudioPlayer

var active_notifications := []

func _ready() -> void:
	# Conectar con el Player en la escena actual
	var root = get_tree().get_current_scene()
	if root and root.has_node("Player"):
		var player = root.get_node("Player")
		# Godot 4 signal connection syntax
		if not player.energy_changed.is_connected(_on_energy_changed):
			player.energy_changed.connect(_on_energy_changed)
		if not player.inventory_changed.is_connected(_on_inventory_changed):
			player.inventory_changed.connect(_on_inventory_changed)
		if not player.notify.is_connected(_on_notify):
			player.notify.connect(_on_notify)
		
		# Initial update
		_on_energy_changed(player.energy)
		_on_inventory_changed(player.inventory)

func _on_energy_changed(value: float) -> void:
	energy_bar.value = value

func _on_inventory_changed(inventory: Dictionary) -> void:
	# Limpiar grid y repoblar con slots por cada item
	for child in inventory_grid.get_children():
		child.queue_free()

	for k in inventory.keys():
		var slot = slot_template.duplicate()
		slot.visible = true
		# intentar cargar icon por nombre de recurso (assets/<name>_icon.png)
		var path = "res://assets/%s_icon.png" % [k.to_lower()]
		if ResourceLoader.exists(path):
			slot.texture = load(path)
		slot.tooltip_text = "%s: %d" % [k, inventory[k]]
		
		# Label con cantidad
		var lbl = Label.new()
		lbl.text = str(inventory[k])
		# Godot 4 property for min size
		lbl.custom_minimum_size = Vector2(24, 12)
		slot.add_child(lbl)
		inventory_grid.add_child(slot)

func _on_notify(message: String) -> void:
	# Mostrar notificación temporal
	var lbl = Label.new()
	lbl.text = message
	notifications.add_child(lbl)
	if audio.stream:
		audio.play()
	active_notifications.append(lbl)
	# Programar borrado en 2.0s
	var t = Timer.new()
	t.wait_time = 2.0
	t.one_shot = true
	t.timeout.connect(_clear_notification.bind(lbl, t))
	add_child(t)
	t.start()

func _clear_notification(lbl: Label, t: Timer) -> void:
	if is_instance_valid(lbl):
		lbl.queue_free()
	if is_instance_valid(t):
		t.queue_free()
