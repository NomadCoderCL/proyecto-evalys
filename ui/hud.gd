extends CanvasLayer

@onready var energy_bar = $Control/EnergyBar
@onready var inventory_grid = $Control/InventoryGrid
@onready var slot_template = $Control/ItemSlotTemplate
@onready var notifications = $Control/Notifications
@onready var audio = $AudioPlayer
@onready var use_audio = $UseAudio

const Items = preload("res://scripts/items.gd")

var active_notifications := []

func _ready() -> void:
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
    # Repoblar grid con slots clicables
    for child in inventory_grid.get_children():
        child.queue_free()

    var root = get_tree().get_current_scene()
    if not root or not root.has_node("Player"):
        return
    var player = root.get_node("Player")
    for k in player.inventory.keys():
        var slot = slot_template.duplicate()
        slot.visible = true
        # icon por metadata o por convención
        var meta = Items.get(k)
        if meta and meta.has("icon") and ResourceLoader.exists(meta.icon):
            slot.texture_normal = load(meta.icon)
        slot.name = str(k)
        # mostrar cantidad con Label dentro del slot
        var lbl = Label.new()
        lbl.text = str(player.inventory[k])
        lbl.add_theme_color_override("font_color", Color.white)
        lbl.rect_position = Vector2(2, 28)
        slot.add_child(lbl)
        # conectar pressed para usar el ítem
        slot.connect("pressed", Callable(self, "_on_slot_pressed"), [k])
        inventory_grid.add_child(slot)

func _on_slot_pressed(item_name: String) -> void:
    # Intentar usar el item desde el Player
    var root = get_tree().get_current_scene()
    if not root or not root.has_node("Player"):
        _on_notify("No hay jugador")
        return
    var player = root.get_node("Player")
    if not player.inventory.has(item_name):
        _on_notify("No tienes %s" % item_name)
        return

    var meta = Items.get(item_name)
    if meta and meta.get("restores_energy", false):
        var amount = int(meta.get("restore_amount", 0))
        # reducir cantidad
        player.inventory[item_name] -= 1
        if player.inventory[item_name] <= 0:
            player.inventory.erase(item_name)
        player._change_energy(amount)
        emit_signal_to_player_notify(player, "Consumiste %s (+%d energía)" % [item_name, amount])
        use_audio.play()
        # notificar cambio de inventario
        player.emit_signal("inventory_changed", item_name, player.inventory.get(item_name, 0))
    else:
        emit_signal_to_player_notify(player, "Nada que hacer con %s" % item_name)

func emit_signal_to_player_notify(player, message: String) -> void:
    # Usar signal notify del player para mantener un solo punto de notificación
    if player:
        player.emit_signal("notify", message)
    else:
        _on_notify(message)

func _on_notify(message: String) -> void:
    var lbl = Label.new()
    lbl.text = message
    notifications.add_child(lbl)
    audio.play()
    active_notifications.append(lbl)
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
