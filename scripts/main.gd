extends Node2D

const SAVE_PATH := "user://savegame.json"

func _ready() -> void:
    # Intentar cargar estado guardado
    var player = $Player if has_node("Player") else null
    if player:
        _load_player_state(player)
        # Conectar cambios para autoguardar
        player.connect("inventory_changed", Callable(self, "_on_player_changed"))
        player.connect("energy_changed", Callable(self, "_on_player_changed"))

    # Guardar al salir de la escena
    get_tree().connect("quit_requested", Callable(self, "_on_quit_requested"))

func _on_player_changed(...):
    var player = $Player if has_node("Player") else null
    if player:
        _save_player_state(player)

func _on_quit_requested() -> bool:
    var player = $Player if has_node("Player") else null
    if player:
        _save_player_state(player)
    # devolver false para indicar que no cancelamos el quit
    return false

func _save_player_state(player) -> void:
    var data = {
        "energy": player.energy,
        "inventory": player.inventory
    }
    var file = File.new()
    var err = file.open(SAVE_PATH, File.WRITE)
    if err == OK:
        file.store_string(to_json(data))
        file.close()

func _load_player_state(player) -> void:
    var file = File.new()
    if not file.file_exists(SAVE_PATH):
        return
    var err = file.open(SAVE_PATH, File.READ)
    if err != OK:
        return
    var txt = file.get_as_text()
    file.close()
    var parsed = JSON.parse_string(txt)
    if parsed.error != OK:
        return
    var data = parsed.result
    if data.has("energy"):
        player.energy = data["energy"]
        player.emit_signal("energy_changed", player.energy)
    if data.has("inventory"):
        player.inventory = data["inventory"]
        # emitir signals por cada item para que HUD se actualice
        for k in player.inventory.keys():
            player.emit_signal("inventory_changed", k, player.inventory[k])
