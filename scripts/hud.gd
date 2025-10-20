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
        player.connect("energy_changed", Callable(self, "_on_energy_changed"))
        player.connect("inventory_changed", Callable(self, "_on_inventory_changed"))
        player.connect("notify", Callable(self, "_on_notify"))
        _on_energy_changed(player.energy)
        _on_inventory_changed("", 0)

func _on_energy_changed(value: float) -> void:
    energy_bar.value = value

func _on_inventory_changed(item: String, count: int) -> void:
    # Limpiar grid y repoblar con slots por cada item
    for child in inventory_grid.get_children():
        child.queue_free()

    var root = get_tree().get_current_scene()
    if not root or not root.has_node("Player"):
        return
    var player = root.get_node("Player")
    for k in player.inventory.keys():
        var slot = slot_template.duplicate()
        slot.visible = true
        # intentar cargar icon por nombre de recurso (assets/<name>_icon.png)
        var path = "res://assets/%s_icon.png" % [k.to_lower()]
        if ResourceLoader.exists(path):
            slot.texture = load(path)
        slot.tooltip_text = "%s: %d" % [k, player.inventory[k]]
        # Label con cantidad
        var lbl = Label.new()
        lbl.text = str(player.inventory[k])
        lbl.rect_min_size = Vector2(24, 12)
        slot.add_child(lbl)
        inventory_grid.add_child(slot)

func _on_notify(message: String) -> void:
    # Mostrar notificación temporal
    var lbl = Label.new()
    lbl.text = message
    notifications.add_child(lbl)
    audio.play()
    active_notifications.append(lbl)
    # Programar borrado en 2.0s
    var t = Timer.new()
    t.wait_time = 2.0
    t.one_shot = true
    t.connect("timeout", Callable(self, "_clear_notification"), [lbl, t])
    add_child(t)
    t.start()

func _clear_notification(lbl: Label, t: Timer) -> void:
    if is_instance_valid(lbl):
        lbl.queue_free()
    if is_instance_valid(t):
        t.queue_free()
