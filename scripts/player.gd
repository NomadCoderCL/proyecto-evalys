extends CharacterBody2D

@export var speed: float = 220.0
@export var energy_max: float = 100.0
@export var collect_range: float = 48.0 # distancia máxima para recolectar
@export var collect_cost: float = 5.0
@export var energy_regen_per_second: float = 4.0

var energy: float
var inventory := {}

# Señales
signal energy_changed(value)
signal inventory_changed(item, count)
signal notify(message)

func _ready() -> void:
    energy = energy_max

func _process(delta: float) -> void:
    # regeneración pasiva de energía
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
    # Buscar el recurso más cercano a la posición del mouse entre los recursos dentro del rango de clic
    var nodes := get_tree().get_nodes_in_group("resources")
    var target := null
    var min_dist_mouse := 1e9
    for r in nodes:
        if not r is Node2D:
            continue
        var d_mouse = r.global_position.distance_to(mouse_pos)
        if d_mouse < min_dist_mouse:
            min_dist_mouse = d_mouse
            target = r

    if not target:
        return

    # Comprobar distancia entre jugador y recurso (proximidad)
    var dist_to_player = global_position.distance_to(target.global_position)
    if dist_to_player > collect_range:
        # demasiado lejos para recolectar
        emit_signal("notify", "Demasiado lejos")
        return

    # Comprobar energía suficiente
    if energy < collect_cost:
        emit_signal("notify", "No tienes energía suficiente")
        return

    # Recolectar
    if target.has_method("collect"):
        target.collect(self)
        _change_energy(-collect_cost)

func add_to_inventory(item: String, qty: int=1) -> void:
    # Añade al inventario y notifica al HUD
    if not inventory.has(item):
        inventory[item] = 0
    inventory[item] += qty
    emit_signal("inventory_changed", item, inventory[item])
    emit_signal("notify", "+%d %s" % [qty, item])

func _change_energy(delta: float) -> void:
    # Cambios de energía centralizados
    var prev = energy
    energy = clamp(energy + delta, 0, energy_max)
    if energy != prev:
        emit_signal("energy_changed", energy)
        # Feedback de cambio de energía
        if delta < 0:
            emit_signal("notify", "Energía %+.0f" % [delta])
