extends Area2D

@export var resource_type: String = "Wood"
@export var amount: int = 1
@export var restores_energy: bool = false
@export var restore_amount: int = 20

func _ready() -> void:
    add_to_group("resources")

func collect(by_player: Node) -> void:
    # Si el recurso regenera energía, aplicarlo al jugador
    if restores_energy and by_player and by_player.has_method("_change_energy"):
        by_player._change_energy(restore_amount)
        # Notificar y eliminar
        queue_free()
        return

    if by_player and by_player.has_method("add_to_inventory"):
        by_player.add_to_inventory(resource_type, amount)
    queue_free()
